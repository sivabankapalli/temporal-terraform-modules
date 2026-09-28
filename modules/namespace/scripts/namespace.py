#!/usr/bin/env python3
"""Create one Temporal namespace and attach one existing project connectivity rule.

Inputs are JSON from Terraform; the Cloud Ops bearer token comes from the environment.
Only the standard Python library is required.
"""

import json
import os
import sys
import time
import uuid
from urllib import error, parse, request

BASE = "https://saas-api.tmprl.cloud"


def fail(message):
    raise RuntimeError(message)


def api(method, path, body=None, query=None):
    token = os.environ.get("TEMPORAL_CLOUD_API_KEY", "")
    if not token or "\n" in token or "\r" in token:
        fail("TEMPORAL_CLOUD_API_KEY is missing or invalid")
    version = os.environ.get("TEMPORAL_CLOUD_API_VERSION", "v0.22.0")
    url = BASE + path + ("?" + parse.urlencode(query) if query else "")
    headers = {
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json",
        "temporal-version": version,
    }
    payload = json.dumps(body).encode("utf-8") if body is not None else None
    # GET retries are safe. Do not blindly retry a POST after an uncertain result.
    for attempt in range(4):
        try:
            req = request.Request(url, data=payload, headers=headers, method=method)
            with request.urlopen(req, timeout=30) as response:
                return json.load(response)
        except error.HTTPError as exc:
            code = exc.code
            exc.close()
            if method != "GET" or code not in (429, 500, 502, 503, 504) or attempt == 3:
                fail("Cloud Ops %s %s failed (HTTP %s)" % (method, path, code))
        except error.URLError:
            if method != "GET" or attempt == 3:
                fail("Cloud Ops %s %s failed; check connectivity and rerun after inspecting the namespace" % (method, path))
        time.sleep(2 ** attempt)


def pages(path, field, **filters):
    cursor = ""
    while True:
        query = dict(filters, pageSize=100)
        if cursor:
            query["pageToken"] = cursor
        result = api("GET", path, query=query)
        yield from result.get(field, [])
        next_cursor = result.get("nextPageToken", "")
        if not next_cursor:
            break
        if next_cursor == cursor:
            fail("Cloud Ops returned a repeated page token")
        cursor = next_cursor


def segment(text):
    return parse.quote(text, safe="")


def verify_scope(cfg):
    account = api("GET", "/cloud/account")["account"]
    if account.get("id") != cfg["account_id"]:
        fail("Temporal account ID does not match the supplied environment")
    project = api("GET", "/cloud/projects/" + segment(cfg["project_id"]))["project"]
    if project.get("id") != cfg["project_id"]:
        fail("Temporal project ID could not be verified")


def connectivity_rule(cfg):
    project_id = cfg["project_id"]
    endpoint = cfg["azure_private_endpoint_resource_id"].casefold()
    matches = []
    for rule in pages("/cloud/connectivity-rules", "connectivityRules", projectId=project_id):
        private = rule.get("spec", {}).get("privateRule", {})
        if (rule.get("projectId") == project_id
                and private.get("region") == cfg["region"]
                and private.get("azurePeResourceId", "").casefold() == endpoint):
            matches.append(rule)
    if len(matches) != 1:
        fail("Expected exactly one connectivity rule for this project, region, and Azure private endpoint; found %s" % len(matches))
    rule_id = matches[0]["id"]
    rule = api("GET", "/cloud/connectivity-rules/" + segment(rule_id))["connectivityRule"]
    private = rule.get("spec", {}).get("privateRule", {})
    if (rule.get("projectId") != project_id or rule.get("id") != rule_id
            or rule.get("state") != "RESOURCE_STATE_ACTIVE"
            or private.get("region") != cfg["region"]
            or private.get("azurePeResourceId", "").casefold() != endpoint):
        fail("Connectivity rule changed, is not active, or belongs to a different project")
    return rule_id


def find_namespace(cfg):
    name = cfg["namespace_name"]
    matches = [ns for ns in pages("/cloud/namespaces", "namespaces", name=name)
               if ns.get("spec", {}).get("name") == name]
    if len(matches) > 1:
        fail("Namespace name is ambiguous across projects; inspect Temporal Cloud")
    if not matches:
        return None
    if matches[0].get("projectId") != cfg["project_id"]:
        fail("Namespace name already belongs to another project")
    return matches[0]["namespace"]


def inspect(cfg, rule_id, namespace_id):
    ns = api("GET", "/cloud/namespaces/" + segment(namespace_id))["namespace"]
    spec = ns.get("spec", {})
    if ns.get("projectId") != cfg["project_id"] or spec.get("name") != cfg["namespace_name"]:
        fail("Namespace identity or project mismatch")
    if ns.get("state") != "RESOURCE_STATE_ACTIVE":
        fail("Namespace is not active yet; retry after the Cloud Ops operation finishes")
    regions = [replica.get("region") for replica in spec.get("replicas", [])]
    if (regions != [cfg["region"]]
            or spec.get("retentionDays") != cfg["retention_days"]
            or spec.get("apiKeyAuth", {}).get("enabled") is not True):
        fail("Existing namespace settings differ from the requested settings")
    if rule_id not in spec.get("connectivityRuleIds", []):
        fail("Required connectivity rule is not attached to the namespace")
    return {"namespace_name": cfg["namespace_name"], "namespace_id": namespace_id,
            "connectivity_rule_id": rule_id}


def apply(cfg):
    verify_scope(cfg)
    rule_id = connectivity_rule(cfg)
    existing = find_namespace(cfg)
    if existing:
        return inspect(cfg, rule_id, existing)
    spec = {
        "name": cfg["namespace_name"],
        "replicas": [{"region": cfg["region"]}],
        "retentionDays": cfg["retention_days"],
        "apiKeyAuth": {"enabled": True},
        "connectivityRuleIds": [rule_id],
        "lifecycle": {"enableDeleteProtection": True},
    }
    operation_id = str(uuid.uuid4())
    response = api("POST", "/cloud/namespaces", {
        "projectId": cfg["project_id"], "spec": spec, "asyncOperationId": operation_id,
    })
    if response.get("asyncOperation", {}).get("id") != operation_id:
        fail("Unexpected Cloud Ops operation ID; inspect Temporal Cloud before retrying")
    for _ in range(120):
        op = api("GET", "/cloud/operations/" + segment(operation_id))["asyncOperation"]
        state = op.get("state")
        if state == "STATE_FULFILLED":
            break
        if state not in ("STATE_PENDING", "STATE_IN_PROGRESS"):
            fail("Namespace creation operation ended in %s" % state)
        time.sleep(5)
    else:
        fail("Namespace creation timed out; inspect Cloud Ops and rerun apply")
    namespace_id = find_namespace(cfg)
    if not namespace_id:
        fail("Creation completed but namespace is not visible yet; rerun apply")
    return inspect(cfg, rule_id, namespace_id)


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("apply", "read"):
        fail("Usage: namespace.py apply|read")
    cfg = json.loads(os.environ["TEMPORAL_NAMESPACE_REQUEST"] if sys.argv[1] == "apply"
                     else json.load(sys.stdin)["request"])
    if sys.argv[1] == "apply":
        result = apply(cfg)
    else:
        verify_scope(cfg)
        rule_id = connectivity_rule(cfg)
        namespace_id = find_namespace(cfg)
        if not namespace_id:
            fail("Namespace is missing; Terraform state requires investigation")
        result = inspect(cfg, rule_id, namespace_id)
    print(json.dumps(result))


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, KeyError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)

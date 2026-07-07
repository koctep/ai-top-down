# PyPost Testing Guidelines (MCP and Prometheus)

## Purpose

When testing the PyPost application, the AI assistant should use the embedded MCP
server and Prometheus metrics for verification. This document describes how and what
to do.

## Prerequisites

- **PyPost is running** — start via `make run` or `python -m pypost.main`.
- **Host:** Use the host where PyPost is reachable (e.g. `localhost`, `dev.int`).
- **MCP is enabled** — in Manage Environments, select an environment and check
  "Enable MCP Server". Status bar shows "MCP: ON".
- **Cursor is connected** — in Cursor MCP settings, add SSE server with URL
  `http://<host>:1080/sse/` (host from PyPost settings, e.g. `localhost` or `dev.int`;
  port default 1080; trailing slash required).
- **Requests exposed as tools** — in each request, check "MCP Tool" and save.

## Testing via MCP

### Connection

- **URL:** `http://<host>:1080/sse/` (host from settings, e.g. `localhost`, `dev.int`;
  port default 1080; trailing slash required).
- **Transport:** SSE (Server-Sent Events).
- **Tools:** List of tools = requests with `expose_as_mcp=True` in the active
  environment.

### Invoking Tools

1. Use `list_tools` (or equivalent) to see available tools.
2. Call a tool by name with required arguments (if the request uses
  `{{ mcp.request.VAR }}` templates).
3. The tool returns the HTTP response body, plus optional script logs and errors.

### Verifying Responses

- Check that the response body matches expectations (status, content).
- If the request has a post-request script, check "Script Logs" and "Script Error"
  sections in the output.
- Report pass/fail based on the response content.

## Verification via Prometheus

### Endpoint

- **URL:** `http://<host>:9080/metrics/` (host from settings, e.g. `localhost`, `dev.int`;
  port default 9080).
- **Format:** Prometheus text exposition format.

### Key Metrics for MCP Testing

| Metric | Labels | Description |
|--------|--------|-------------|
| `mcp_requests_received_total` | `method` | MCP tool invocations received |
| `mcp_responses_sent_total` | `method`, `status` | MCP responses (success/error) |
| `requests_sent_total` | `method` | HTTP requests sent by PyPost |
| `responses_received_total` | `method`, `status_code` | HTTP responses received |

### Using Metrics for Verification

1. **Before action:** Optionally fetch `/metrics` and note current counter values.
2. **Perform action:** Call an MCP tool.
3. **After action:** Fetch `/metrics` again.
4. **Verify:** Expect `mcp_requests_received_total` and `mcp_responses_sent_total` to
   increment for the invoked tool. If the tool sends an HTTP request, expect
   `requests_sent_total` and `responses_received_total` to increment.

## Step-by-Step Procedure

1. Ensure PyPost is running and MCP is enabled.
2. Call an MCP tool (e.g. a request exposed as a tool).
3. Verify the tool response (body, status, script output).
4. Optionally fetch `http://<host>:9080/metrics/` and confirm metric increments.

## References

- [doc/mcp_integration.md](doc/mcp_integration.md) — MCP setup and usage.
- [pypost/core/metrics.py](pypost/core/metrics.py) — metric definitions.

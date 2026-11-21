# openapi

Turns an OpenAPI spec into MCP tools, so the agent can call that API's endpoints with typed parameters. This is the general answer to "let the agent call an API", for any service that publishes an OpenAPI/Swagger spec.

> Community project (`ivo-toby/mcp-openapi-server`, `@ivotoby/openapi-mcp-server`, MIT), not a vendor's. Review it before pointing it at anything sensitive.

- **Use when:** the API has an OpenAPI spec and you want the agent to call it repeatedly with proper schemas and with credentials kept in the environment.
- **Skip when:** it's a one-off call. `curl` or `httpie` through the shell needs no MCP at all.
- **Transport:** stdio via `npx`, pinned to `@ivotoby/openapi-mcp-server@1.18.0`.
- **One server entry per API.** Rename `api` in `mcp.json` (for example `api-billing`) and give each its own variables.

## Config

| Variable | Meaning |
|---|---|
| `API_BASE_URL` | Base URL requests are sent to |
| `OPENAPI_SPEC_PATH` | URL or file path of the spec |
| `API_HEADERS` | Optional, comma-separated `Key:Value` pairs, e.g. `Authorization:Bearer xxx`. Keep it in the environment. |
| `TOOLS_MODE` | `dynamic` (shipped) or `all` |

## Modes (measured against the public Petstore spec)

- `dynamic`: **3 tools** (`list-api-endpoints`, `get-api-endpoint-schema`, `invoke-api-endpoint`). Context stays small however big the API is. The agent discovers endpoints, then invokes one. `invoke-api-endpoint` takes `endpoint`, `method`, `params`.
- `all`: one tool per endpoint, **19 tools** for Petstore (names are shortened, for example `crt-usr`, `del-pet`). A real API can add hundreds.

## Risks

- **No read-only mode was found or tested.** The agent can call `POST` / `DELETE` endpoints. Use an API token that can only read, or a sandbox. The README documents tag filters such as `--exclude-tag`; they were not tested here.
- `API_HEADERS` is sent to the API. Per the README it can also be sent with the spec request when the spec lives on the same origin.
- Responses are untrusted text.

## Last verified

2026-11-21: pinned version against `https://petstore3.swagger.io` (a public demo API). `dynamic` and `all` modes listed 3 and 19 tools; in `all` mode `find-pets-by-status` returned real data. **`invoke-api-endpoint` itself was not called**, and nothing was tested with authentication.

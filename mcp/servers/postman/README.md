# postman

Postman's official MCP server. It works on **Postman's cloud workspace**: collections, environments, specs, mocks, monitors. It is not a general "send this HTTP request" tool. To call an API directly, see [openapi](../openapi/README.md) or just use `curl`.

- **Use when:** the team keeps API definitions in Postman and the agent should read them to write client code, tests or docs.
- **Skip when:** you only need to call an API once (use `curl`), or the API has an OpenAPI spec (use `openapi`).
- **Transport:** stdio via `npx`, pinned to `@postman/postman-mcp-server@2.15.0` (Apache-2.0). Needs Node >= 20.

## Modes (measured with the stdio server)

| Flag | Tools | Read-only? | Notes |
|---|---|---|---|
| `--code` (**shipped**) | 23 | all 23 carry a read-only hint | Reading collections, environments and specs for code generation. No run tools. |
| none (Postman calls it "Minimal") | 42 | 20 of 42 | Adds create/update tools and `runCollection` (Postman's cloud runner) |
| `--full` | 234 | 109 of 234 | Everything, including `runCollection`, `runMonitor`, monitors, access requests. Heavy on context. |

No read-only switch exists for the larger modes, so least privilege there comes from the API key's own scope.

## Auth

`POSTMAN_API_KEY` (generate in Postman account settings). Use a key for the narrowest workspace you can. EU accounts: add `--region eu` to `args`.

## Remote alternative (OAuth, no key in config)

Postman hosts the same server. Use `{"type": "http", "url": "https://mcp.postman.com/code"}`. `/minimal` is the default set and `/mcp` is the full set. EU hosts use `mcp.eu.postman.com`. Tool counts for the remote endpoints were not measured, only that they exist and answer `401` with OAuth metadata.

## Risks

- A collection can embed example secrets and auth tokens; the agent will read them.
- In modes above `--code`, a model-driven `runCollection` fires real requests against whatever the collection targets.

## Last verified

2026-11-21: pinned version started with a dummy key; tool counts and read-only hints are measured. **Not tested with a real Postman account.**

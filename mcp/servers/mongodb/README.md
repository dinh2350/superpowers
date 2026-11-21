# mongodb

MongoDB's official MCP server. Lets the agent inspect collections, schemas and indexes and run queries and aggregations.

- **Use when:** the project uses MongoDB and the agent needs real document shapes while writing queries or models.
- **Skip when:** `mongosh` is enough and you don't need enforced read-only.
- **Transport:** stdio via `npx`, pinned to `mongodb-mcp-server@3.3.0` (Apache-2.0). Needs Node `^20.19.0 || ^22.13.0 || >=24`.

## Config

`MDB_MCP_CONNECTION_STRING` is required (see `../../.env.example`), e.g. `mongodb://user:pass@host:27017/db`. The config fails to load if it is unset.

The shipped flags are `--readOnly` and `--telemetry disabled`. MongoDB's own table lists telemetry as enabled by default.

## What `--readOnly` does (measured)

| | Tools | Write tools |
|---|---|---|
| default | 31 | 11 (`insert-many`, `update-many`, `delete-many`, `drop-collection`, `drop-database`, `drop-index`, `create-collection`, `create-index`, `rename-collection`, `atlas-local-create-deployment`, `atlas-local-delete-deployment`) |
| `--readOnly` | 20 | none. Calling `insert-many` returned `Tool insert-many not found` |

To allow writes, remove `--readOnly`, for a dev database only. MongoDB also documents `--confirmationRequiredTools` and `--disabledTools` for finer control.

## Risks

- `--readOnly` hides tools; it does not limit the database user. Use a user with read-only role.
- Documents can contain user-authored text with injected instructions.

## Last verified

2026-11-21: pinned version started against a throwaway MongoDB 7 container's connection string, with and without `--readOnly`; tool lists compared. **A data query through the server was not exercised end to end.**

# dbhub

Bytebase's DBHub: one MCP server for relational databases (Postgres, MySQL, MariaDB, SQL Server, SQLite; its CLI also lists ClickHouse and Oracle DSNs). The agent can inspect the schema and run SQL.

- **Use when:** the agent needs the real schema or sample data while writing queries, migrations or ORM code.
- **Skip when:** the `psql` / `mysql` CLI is enough. Choose this over the CLI when you want enforced read-only mode and a row limit instead of trusting the agent to behave.
- **Transport:** stdio via `npx`, pinned to `@bytebase/dbhub@2.0.1`. Needs Node >= 22.5.0.
- **Tools (as shipped):** 2, `execute_sql` and `search_objects`.

## Setup

1. Copy `dbhub.toml` from this directory to `.mcp/dbhub.toml` in the target project. It holds no secrets.
2. Set `DBHUB_DSN`, for example `postgres://user:pass@host:5432/db?sslmode=require` or `mysql://user:pass@host:3306/db`. Use a database user that **only has SELECT rights**.
3. The `--config` path is relative. Claude Code starts the server in the directory you launched it from, so launch it at the project root.

## The trap this config avoids

With `--dsn` alone, `execute_sql` can write. In a test against Postgres 16, `CREATE TABLE` and `DROP TABLE` both succeeded. The shipped `dbhub.toml` sets `readonly = true` and `max_rows = 200`. Same test: `CREATE TABLE` and `INSERT` were rejected on Postgres 16 and `CREATE TABLE` on MySQL 8.4. `${DBHUB_DSN}` inside the TOML expands from the environment on both.

`readonly = true` is a guardrail, not a permission boundary (DBHub says so itself). The read-only database user is the real protection.

## Variants

| Want | Change |
|---|---|
| Allow writes (dev database only) | Set `readonly = false` in `.mcp/dbhub.toml` |
| Several databases | Add a `[[sources]]` plus matching `[[tools]]` blocks per database. See `dbhub.toml.example` in DBHub's repo. Not tested here. |

## Alternatives (README-verified, not tested here)

- **Postgres MCP Pro**, PyPI `postgres-mcp` 0.3.0 (MIT, Python >= 3.12): `uvx postgres-mcp --access-mode=restricted`, with `DATABASE_URI` set. Adds index tuning and health checks beyond plain SQL.
- **`@benborla29/mcp-server-mysql`** 2.0.9 (community, MIT): read-only by default; writes need `ALLOW_INSERT_OPERATION` / `ALLOW_UPDATE_OPERATION` / `ALLOW_DELETE_OPERATION`; credentials via `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASS`, `MYSQL_DB`.
- Not `@modelcontextprotocol/server-postgres`: archived and deprecated on npm.

## Risks

- Query results are data the agent will read as context. Rows can contain user-authored text with injected instructions.
- Never point it at a production database with a privileged user.
- The DSN contains a password. Keep it in the environment, never in the TOML or `.mcp.json`.

## Last verified

2026-11-21: pinned version against throwaway Postgres 16 and MySQL 8.4 containers, launched from a simulated project root with the shipped TOML. Reads worked; writes were rejected; `search_objects` worked.

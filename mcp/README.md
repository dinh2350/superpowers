# MCP Catalog

A menu of well-known MCP servers for developers, packaged as configs that merge straight into a project.
Nothing here is enabled by default. A project picks the few servers it needs; an AI agent wires them up.

> **Scope:** this directory is a fork-local addition. Upstream Superpowers is a zero-dependency
> plugin and does not accept third-party integrations, so do not open a PR to `obra/superpowers` with it.

## Principles

1. **Config, not code.** No server code is vendored. Each `mcp.json` points at a published npm
   package or a vendor-hosted endpoint.
2. **Menu, not bundle.** Every enabled server adds its tool definitions to the agent's context.
   Enable 3–5 per project. `catalog.md` lists the measured tool count for each.
3. **Least privilege by default.** Read-only or scoped variants ship as the default. Each server's
   README says how to widen them and what that costs in risk.
4. **No secrets in git.** Configs only contain `${VAR}` references. See `.env.example`.
5. **Pinned versions.** npm and PyPI servers are pinned (Portainer to a minor, because it must match the
   instance). Vendor-hosted servers (GitHub, Supabase, Sentry, Datadog) cannot be pinned; the vendor
   controls their behaviour.
6. **Say what was tested.** Each server README ends with a "Last verified" section naming what was run and
   what was not.

## Layout

```text
mcp/
├── README.md        this file
├── catalog.md       the menu: what each server gives you, cost, MCP-vs-CLI advice
├── .env.example     every env var the configs reference
├── harnesses/       how to write config for Claude Code, Codex, Cursor, Gemini CLI
└── servers/<id>/
    ├── mcp.json     merge-ready config (Claude Code .mcp.json shape)
    ├── README.md    when to use / skip, auth, variants, risks
    └── *.toml       only where needed (dbhub, kubernetes): copy into the project's .mcp/ folder
```

## Using it in another project

Clone this repo (or just copy `mcp/`) somewhere, then ask your agent to set up MCP for the project.

### Procedure for the AI agent

1. Read `catalog.md`. Inspect the target project's stack (`package.json`, `pyproject.toml`,
   `supabase/`, `.github/`, CI config, existing `.mcp.json`).
2. Propose **3–5** servers with one line of reasoning each, and which of them could be a CLI
   instead. Wait for the human to confirm. Do not enable the rest.
3. Read each chosen server's `README.md`. Pay attention to Auth and Risks.
4. Identify the harness in use and follow `harnesses/<harness>.md`. Merge the server's `mcp.json`
   into the project's existing config; never overwrite it. If the server ships a `*.toml`, copy it to
   `.mcp/` in the project. Keep the shipped least-privilege defaults unless the human asks for more,
   and never grant write access to a production system. Check the runtime the server needs
   (Node, or `uv` for Portainer).
5. Append the needed variable names to the project's `.env.example`. Never write real secrets.
   Confirm `.env` is gitignored.
6. Run the harness's list/health command and report the state of each server. Some harnesses
   (Claude Code) hold project servers at "pending approval" until the human approves, and OAuth
   servers need the human to log in. Report those as pending; do not claim they work.

## Verification status

Checked on 2026-11-21.

| What | How | Result |
| --- | --- | --- |
| npm package names, versions, deprecation | `npm view` against the registry | confirmed |
| 5 stdio servers (context7, playwright, chrome-devtools, sequential-thinking, memory) | started the pinned version, sent `initialize` and `tools/list` | all start; tool counts in `catalog.md` are measured |
| Remote servers (github, supabase, sentry, datadog US1, postman) | unauthenticated `POST` | endpoints exist and demand auth; **not tested with real credentials** |
| dbhub against Postgres 16 and MySQL 8.4 (throwaway Docker containers) | called `execute_sql` with the shipped TOML from a simulated project root | reads work; writes rejected. Without the TOML, writes succeeded |
| mongodb, kubernetes, portainer, postman | started with and without the restricting option and compared tool lists | restricted sets contain no write tools. mongodb ran against a MongoDB 7 container; kubernetes used a dummy kubeconfig (**no real cluster**); portainer and postman used dummy credentials |
| openapi | ran against the public Petstore spec | one real GET succeeded in `all` mode; `invoke-api-endpoint` itself not called |
| Claude Code `.mcp.json` shape | generated with `claude mcp add --scope project` and compared; all 15 `mcp.json` merged into one `.mcp.json` and read by `claude mcp list` | parsed; all sit at "Pending approval". **A live connection through Claude Code was not tested** (approval is the human's call) |
| Gemini CLI settings shape | generated with `gemini mcp add` | matches (see caveat in `harnesses/gemini.md`) |
| Codex, Cursor formats | vendor docs only | **not tested**, those tools were not installed |

Re-run this check before relying on a version bump: update the pinned version, start the server, list its tools.

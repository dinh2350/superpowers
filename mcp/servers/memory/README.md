# memory

Reference MCP server that stores a knowledge graph (entities, relations, observations) in a local JSONL file, so facts persist across sessions.

- **Use when:** you need recall that spans many projects, or you use a harness with no memory of its own.
- **Skip when:** the facts belong to one project. `AGENTS.md` / `CLAUDE.md` are versioned, reviewable, free of tool overhead, and the harness's own memory feature usually covers personal preferences.
- **Transport:** stdio via `npx`, pinned to `@modelcontextprotocol/server-memory@2.2.1`. Its README requires Node 24 or later when launched through `npx`.
- **Tools:** 9.

## Config

`MEMORY_FILE_PATH` is **required** here on purpose: the config fails to load if it is unset, so memory never lands in a default location by accident. Set it to an **absolute** path you own (a leading `~` is expanded; a relative path would resolve against the server's own directory, not your project). Keep the file out of git.

## Risks

- Anything the agent writes there is trusted by later sessions. A poisoned or wrong entry persists. Review the file occasionally.
- The file can accumulate sensitive details. Keep it outside the repo or gitignored.

## Last verified

2026-11-21: pinned version started with a temp `MEMORY_FILE_PATH`, answered `initialize`, listed 9 tools.

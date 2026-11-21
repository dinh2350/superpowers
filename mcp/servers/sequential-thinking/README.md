# sequential-thinking

Reference MCP server exposing one tool that lets the model record numbered thoughts, revise earlier ones and branch.

- **Use when:** the model has no built-in extended reasoning, or you want an explicit, inspectable trail of revisions on a hard design problem.
- **Skip when:** you use a reasoning-capable model. It already thinks step by step, and this mostly adds round trips. Try without it first.
- **Transport:** stdio via `npx`, pinned to `@modelcontextprotocol/server-sequential-thinking@2.2.0`. Its README requires Node 24 or later when launched through `npx`.
- **Tools:** 1.

## Variants

Set `DISABLE_THOUGHT_LOGGING=true` in the server's `env` to stop it logging thought content.

## Last verified

2026-11-21: pinned version started, answered `initialize`, listed 1 tool (Node 25 on the test machine).

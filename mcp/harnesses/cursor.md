# Cursor

**Status: NOT tested.** Cursor was not installed when this was written. This is the documented format; verify it in Cursor's MCP settings before relying on it.

## Where config goes

`.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (global). The top-level `mcpServers` object has the same shape as `mcp.json` here.

## Differences from `mcp.json`

- Variable syntax is `${env:VAR}`, not `${VAR}`. Translate when copying.
- Check the result under Cursor Settings, MCP; each server shows a connected/error state.

## Steps

1. Merge the chosen servers' entries into `.cursor/mcp.json`, translating variable syntax.
2. Export the variables in the environment Cursor is launched from.
3. Open Cursor's MCP settings and confirm each server connects.

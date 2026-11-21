# kubernetes

The `containers/kubernetes-mcp-server` project (Red Hat, Apache-2.0). Lets the agent list, inspect and read logs of cluster resources through your kubeconfig.

- **Use when:** you want enforced read-only cluster access with specific resource kinds blocked.
- **Skip when:** `kubectl` already does the job. The agent can run it directly and your harness can restrict it to read-only verbs. This MCP is for when you prefer the restriction in tool registration instead of a command allowlist.
- **Transport:** stdio via `npx`, pinned to `kubernetes-mcp-server@0.1.3`.

## Setup

1. Copy `kubernetes-mcp-server.toml` from this directory to `.mcp/kubernetes-mcp-server.toml` in the target project. It holds no secrets.
2. **Use a dedicated kubeconfig** with a read-only identity and export `KUBECONFIG` to it. By default the server reads `~/.kube/config` and can reach every cluster in it, including a production one that happens to be your current context.
3. The `--config` path is relative. Claude Code starts the server in the directory you launched it from, so launch it at the project root.

## What the shipped config does (measured)

| | Tools | Write tools |
|---|---|---|
| default | 21 | `pods_delete`, `pods_exec`, `pods_run`, `resources_create_or_update`, `resources_delete`, `resources_scale` |
| `read_only = true` | 15 | none |

It also adds a `denied_resources` rule that rejects `Secret` calls. The project documents `read_only`, `disable_destructive` and `denied_resources` as best-effort guardrails that do not change the cluster permissions of the identity the server uses. RBAC on the kubeconfig identity is the real protection.

## Alternatives (not tested here)

`mcp-server-kubernetes` (Flux159, 4.2.3, MIT) has a non-destructive mode. See its README.

## Risks

- Read access is not harmless: pod logs and ConfigMaps can contain credentials. Add more `[[denied_resources]]` blocks (for example `ConfigMap`, RBAC kinds) if needed.
- Resource names and annotations are user-controlled text.

## Last verified

2026-11-21: pinned version started with the shipped TOML, from a simulated project root, using a dummy kubeconfig that points at a closed local port. **No real cluster was contacted**, so reads and the `Secret` denial were not exercised.

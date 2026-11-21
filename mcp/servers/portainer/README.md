# portainer

Portainer's own MCP server (`portainer/portainer-mcp`, PyPI `mcp-portainer`, MIT). Exposes the Portainer REST API as tools: list and inspect environments, containers, stacks and Kubernetes resources.

> **Not for production.** Portainer's README says this server "is no longer the supported way to use an LLM with Portainer", is provided without support, warranty or SLA, may be archived, and is intended for evaluation, homelabs and other non-production use. Its supported route is Portainer Command (Business Edition). Use this entry for a homelab or dev instance only.

- **Use when:** you manage a homelab or dev Docker/Kubernetes estate through Portainer.
- **Skip when:** the `docker` CLI or a plain API call is enough, or the Portainer instance is production.
- **Transport:** stdio via `uvx` (needs [uv](https://docs.astral.sh/uv/) and Python >= 3.11).

## Setup

1. Create an access token in Portainer under **My Account, Access tokens**. Use a user with the least rights that work.
2. Set `PORTAINER_URL`, `PORTAINER_API_KEY` and `PORTAINER_MCP_MINOR` (see `../../.env.example`).
3. **Match the minor version to your Portainer instance**: Portainer `2.45.x` needs `PORTAINER_MCP_MINOR=2.45`. The config installs `mcp-portainer~=2.45.0`, which resolved to 2.45.3 when checked.
4. For a self-signed certificate add `"PORTAINER_TLS_VERIFY": "0"` to `env`. That disables certificate checks, so keep it to a trusted network.

## Shipped narrowing (measured)

Out of the box the server registers **239 tools**, including `docker_proxy` and `kubernetes_proxy` escape hatches. That is a lot of context. The config sets:

| Variable | Value | Effect |
|---|---|---|
| `PORTAINER_READ_ONLY` | `1` | Only `GET`/`HEAD` operations; also restricts the proxy tools |
| `PORTAINER_PROFILES` | `BASE,DOCKER` | Only those tag bundles (default is `BASE,DOCKER,KUBERNETES,GITOPS`) |
| `PORTAINER_NO_PROXY` | `1` | Skips the two proxy tools |

Result: **40 tools, all carrying a read-only hint.** Adding `KUBERNETES` to the profiles gives 118. Other profiles (`GITOPS`, `EDGE`, `ADMIN`, `ALL`) are listed in Portainer's `docs/profiles.md`.

## Risks

- The token carries its user's full rights. Read-only mode limits the tools, not the token.
- Resource names, labels and logs are user-controlled text.

## Last verified

2026-11-21: `mcp-portainer~=2.45.0` started via `uvx` with a dummy URL and key; tool counts above are measured. **Never connected to a real Portainer instance.**

---
title: "Part 3 — Architecture, Gateways, and Remote Defense"
summary: "The MCP broker model, IP allowlisting vs device trust, and defending remote/cloud development environments."
part: 3
updated: 2026-07-17
---

# Part 3 — Architecture, Gateways, and Remote Defense

The shift from simple AI chat interfaces to autonomous agentic assistants marks a significant expansion of the attack surface. These agents execute shell commands, read and write to the filesystem, and interact with external tool servers via protocols like MCP. Scaling protection across a fleet requires moving beyond prompt monitoring toward centralized brokering, strict network boundaries, and template-based cloud defense. This part builds on the endpoint controls in [Part 2](part-2-endpoint-hardening-and-policy-playbook.md).

## The Broker Model: Centralizing Tool Governance

A primary risk in agentic AI is the decentralization of credentials and tool access. When developers configure tool servers locally, API keys and tokens often sit in plaintext in local config files. The broker model inverts this by routing all MCP tool calls through a trusted gateway.

### Why Brokering MCP Is Critical

- **Credential decoupling** — secrets for external tool servers are stored in a central vault and injected by the gateway at call time, so credentials never live on developer endpoints.
- **Unified access policy** — security teams define which users or agents can invoke specific tools in one central location, not per endpoint.
- **Attributable audit trails** — the gateway records every tool invocation, a single source of truth for the SIEM (who called which tool, with what arguments).
- **Constrained egress** — forcing agents to communicate only with the gateway prevents an injected or compromised agent from pivoting to unvetted external tool servers.

A gateway and endpoint enforcement are complementary: the endpoint enforcer governs what the agent does locally (shell, filesystem, which servers may even be configured); the gateway governs the tool calls that leave for external servers. Point the agent's MCP configuration at the gateway, block direct MCP-server configuration on the endpoint via managed settings, and let the gateway enforce identity, policy, and logging on every downstream call. Use MCP tunnels to reach private internal servers without exposing them.

## Hardening the Remote and Mobile Access Path

As agents are increasingly steered from mobile devices or browsers, the access path must be secured at two distinct layers: the network and the device. IP allowlisting addresses the network; it does **not**, on its own, address the device. A personal/BYOD device on the corporate VPN still passes an IP check. Pair IP allowlisting (network layer) with device trust / MDM enrollment (device layer).

### Implementation Patterns by Platform

- **Claude (Anthropic)** — Enterprise-tier IP allowlisting validates source IPs against CIDR ranges; pair with Tenant Restrictions to block personal-account usage on corporate networks. Pair with Trusted Devices for the device layer.
- **ChatGPT / Codex (OpenAI)** — workspace-level IP allowlisting blocks non-allowlisted IPs even with valid credentials, and gates the Codex surface too.
- **Cursor** — no native workspace IP allowlist; allowlist Cursor's egress domains on the corporate firewall and use sandbox network modes within the application.

## Defending Remote and Cloud Development Environments

Cloud workspaces (e.g. Codespaces, Coder) often present a larger blast radius than laptops because they frequently hold infrastructure identities like Kubernetes service accounts or AWS IAM roles, and reach internal services from inside the trusted VPC. Because MDM profiles cannot be pushed to a Linux pod, the security model must shift to the image template.

### Best Practices for Cloud Workspace Security

- **Immutable managed settings** — bake the agent's configuration (`managed-settings.json` for Claude Code, `requirements.toml` for Codex) into the base workspace image, root-owned to prevent user modification.
- **In-image enforcement** — run discovery and enforcement agents directly inside the workspace image; laptop-based security agents will not reach these environments.
- **Least-privilege infrastructure identity** — assign workspaces narrowly scoped IAM roles (via IRSA or workload identity) rather than broad node instance profiles, plus scoped Kubernetes RBAC.
- **Egress segmentation** — use network policy so the workspace reaches only sanctioned destinations (the MCP gateway, approved package registries), with separate node pools / network boundaries from production.
- **Credential exclusion** — strive for a "zero-secret" workspace where LLM keys and tool-server tokens live in the control plane or gateway, never landing in the ephemeral environment.

When the agent already runs in a cloud workspace with cluster/cloud access, driving it from a phone or browser means a remote device is steering something with infrastructure privilege. Gate it with the platform's own authentication (SSO, connection over an encrypted tunnel, no direct inbound) and the network controls above — the workspace's IAM scope is the real backstop if the control surface is compromised.

## Playbook Summary for Security Teams

- **Observe first** — start in simulation mode to baseline normal agent behavior before moving high-confidence rules to active enforcement.
- **Sanction and prune** — maintain a short allowlist of sanctioned agents and use application control to remove unapproved IDE extensions or CLIs.
- **Broker all tooling** — point agent MCP configurations to a centralized gateway and block direct local tool-server entries.
- **Verify the image** — for remote development, make the workspace template the enforcement point for all security configuration.

---

Next: **[Part 4 — Beyond the Hyperscalers](part-4-beyond-the-hyperscalers.md)** extends this to GPU-first and sandbox-native compute providers.

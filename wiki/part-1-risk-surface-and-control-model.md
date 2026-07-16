---
title: "Part 1 — The Risk Surface and Control Model"
summary: "Why agentic AI is a new security surface, the risk model, and the discovery + enforcement two-layer control model."
part: 1
updated: 2026-07-17
---

# Part 1 — The Risk Surface and Control Model

## The New Frontier: Why Agentic AI Needs a Different Security Playbook

For years, security teams have treated AI as a "text-in, text-out" problem, governed largely by model-egress gateways. The rise of agentic AI coding assistants has shattered this paradigm. Unlike a simple chat window, an agentic assistant is designed to *act* on behalf of the user, operating directly on the developer's machine with their own level of access.

This shift introduces a massive control gap: while your gateway can see what prompt leaves the organization, it has no visibility into what the agent does locally — its tool calls, its file access, or the external servers it connects to.

## 1. Defining the New Local Action Surface

To provide value, agentic assistants are typically granted extensive permissions that bypass traditional network-level security:

- **Shell and command execution** — the ability to run arbitrary commands on the developer's machine.
- **Filesystem access** — reading and writing to any file reachable by the developer.
- **Network egress** — making direct outbound requests to the internet or internal resources.
- **Model Context Protocol (MCP)** — using external tool servers to query databases, read support tickets, or post to internal chat channels.

## 2. The Modern Risk Model

When an agent operates with autonomy and consumes untrusted input (external repositories, issues, web pages, tool outputs), several critical failure modes emerge:

- **Credential exposure** — agents read config files and environment that may contain plaintext API keys, cloud credentials, or tokens; an agent can be induced to read a secret store and act on it.
- **Data exfiltration** — source code or sensitive data leaves via a network tool call or an external tool server the organization never vetted.
- **Arbitrary execution** — shell access means a single approved-looking step can run destructive or attacker-supplied commands.
- **Prompt-injection-driven action** — hostile content in the agent's context ("read this file and send it to X") turns the agent into the actor, not the developer.
- **Shadow AI** — unsanctioned agents, tool servers, or browser AI chatbots proliferate faster than security teams can inventory them.

## 3. The Playbook: A Two-Layer Defense

Mature security organizations are moving toward a dual-layer approach: combining passive discovery with active, real-time enforcement.

### Layer 1: Passive Discovery

The first step is gaining visibility. A lightweight component scans agent configuration locations to build a comprehensive inventory.

- **Inventory** — tracks which agents are installed and which external tool servers they use.
- **Privacy-first** — collects metadata and redacts secret values while recording their paths.
- **Compliance** — identifies insecure permission settings or auto-approve configurations before they are exploited.

### Layer 2: Active Enforcement

Active enforcement intercepts agent activity as it happens, evaluating actions against deterministic, rule-based policies. Interception occurs at three key surfaces:

- **Prompt submit** — reviewing the instruction before it reaches the LLM.
- **Pre-tool** — checking a tool call (like a shell command) before it executes.
- **Post-tool** — inspecting the tool's response (like a database result) for PII or secrets before the agent consumes it.

Each event results in one of three outcomes: **Allow**, **Ask** (warn the user for approval), or **Deny** (block the action entirely).

## 4. Explaining the Threat: The Attack Path

To help non-specialist stakeholders understand the urgency, distill the risk into a single, high-impact attack path:

> An agent reads untrusted content — perhaps a malicious file in a public repository or a hostile web page. This content carries a hidden instruction (prompt injection) that tells the agent to find a local cloud credential on the machine and send it to an external server. Because the agent has the developer's access, it complies silently. The developer never issued the command, and your model gateway never saw the local file read.

Real-time, endpoint-level enforcement is the only lever capable of breaking this chain — by denying the credential read or blocking the outbound call before it executes.

## Summary for the Security Engineer

The security of agentic AI coding assistants is an endpoint problem. While productive, their ability to act is their primary vulnerability. By implementing a strategy of **discovery** (to map the surface) and **enforcement** (to gate high-impact actions like shell execution and credential access), organizations can empower developers without ceding control of their most sensitive environments.

---

Next: **[Part 2 — Endpoint Hardening and Policy Playbook](part-2-endpoint-hardening-and-policy-playbook.md)** turns this model into concrete controls.

---
title: "Part 14 — Multi-Agent and Agent-to-Agent (A2A) Systems"
summary: "The whole guide so far secures one agent, on one machine, under one identity. Multi-agent systems break all three assumptions at once: orchestrators spawn sub-agents, and agents discover and call each other across trust boundaries via protocols like A2A. Each hop is a place to re-apply the guide's controls — and multi-agent adds failure modes single-agent never had: prompt injection that self-replicates and gets laundered into a more effective form as it travels, confused-deputy escalation where a low-privilege agent drives a high-privilege one, and the headless case where one agent drives another over a protocol like ACP and removes the human who used to answer an 'ask' prompt."
part: 14
updated: 2026-07-17
---

# Part 14 — Multi-Agent and Agent-to-Agent (A2A) Systems

Parts 1–13 almost all share a hidden assumption: *one* agent, acting on *one* machine, under *one* identity. Multi-agent systems break all three at once. A planner agent spawns worker sub-agents; agents built by different teams (or different vendors) discover each other and delegate tasks across the network via an agent-to-agent protocol. The controls from the earlier parts do not stop applying — they now apply *at every hop* — and the seams between agents introduce failure modes that simply do not exist when one agent acts alone. This part is about those seams.

Two framings hold the part together. First: **every edge between two agents is a trust boundary**, and the guide's existing controls (identity, brokering, input screening, logging, the kill switch) must be re-instantiated on each edge, not just at the human-to-agent entry. Second: **composition creates emergent risk** — the dangerous behaviors here are properties of the *graph* of agents, not of any single node, so you cannot secure a multi-agent system by hardening each agent in isolation.

## The New Topology

Two shapes dominate, and they have different trust properties.

- **Orchestrator / sub-agent (intra-system).** One agent plans and spawns workers it controls (Claude Code subagents, a workflow fan-out from [Part 7](part-7-agentic-workflow-platforms.md), an orchestrator framework like LangGraph / CrewAI / AutoGen). The orchestrator is a new *privileged node*: it decides what runs, and it consumes its workers' output as input to its own next step. A compromised worker's output flows straight back into the planner's context.
- **Agent-to-agent / peer (inter-system).** Independent agents discover and call each other, increasingly over a standard protocol. **A2A** (the Agent2Agent protocol — open-sourced by Google in 2025, now governed by the Linux Foundation's Agentic AI Foundation, v1.2 as of 2026, adopted by 150+ organizations and integrated natively into Azure AI Foundry, Amazon Bedrock AgentCore, and Google Cloud) is the reference case: agents advertise capabilities via **Agent Cards**, discover peers, and run a task lifecycle over HTTP / SSE / JSON-RPC. (Verify specifics against the current spec — this space moves fast.)
- **Client-driven coding agent (ACP).** A different protocol governs a different seam: a *client* driving a coding-agent harness. **ACP** (the Agent Client Protocol — Zed-originated, Apache-licensed, adopted by Zed, JetBrains, Neovim, and OpenCode) standardizes editor↔agent control the way LSP standardized editor↔language-server. The security-relevant turn: with a *headless* ACP client such as **acpx** (openclaw), the client is itself another agent — so the orchestrator/sub-agent shape above runs over a wire protocol, one agent driving Claude Code or Codex through deterministic steps with no human at the console. Same seam, mechanized (see [Failure Mode 5](#failure-mode-5-ask-has-no-human-headless-agent-driving)). Keep the distinction clear: MCP is agent→tools ([Part 3](part-3-architecture-gateways-and-remote-defense.md)), A2A is agent↔peer agents, ACP is client/agent→coding agent.

```
  ORCHESTRATOR / SUB-AGENT              AGENT-TO-AGENT (A2A)
  (one system, spawned workers)         (independent peers)

        [planner]                         [agent A] --card--> [agent B]
        /   |   \                              |  <--result--    |
   [w1] [w2] [w3]                              v                 v
    |    |    |                            [tools]           [tools]
   output flows UP into planner        each peer is its own trust domain
```

## Failure Mode 1: Injection That Self-Replicates and Gets *Laundered*

Single-agent prompt injection ([Part 1](part-1-risk-surface-and-control-model.md)) is a one-shot event. In a multi-agent system it behaves like an infection. A malicious instruction injected into agent A's context (via a poisoned tool result, a web page, a document) propagates through A's output into agent B's context, then C's — self-replicating along the very communication paths that make the system useful.

The non-obvious and dangerous part: **the injection does not degrade as it travels — it gets laundered into a more effective form.** An intermediate agent, doing its normal job of summarizing and reformatting, rewrites the adversarial instruction into cleaner, more trusted-looking output for the next agent. Research on this "prompt infection" pattern found that intermediate agents act as amplifiers, and reported a stark asymmetry: large models resisted *direct* injection at high rates, yet were compromised at close to 100% when the same payload arrived as a request *from a peer agent*. Peer output is implicitly trusted in a way external input is not, and that trust is the vulnerability.

Control: **treat every inter-agent message as untrusted input, and re-screen it at each hop** exactly as you screen external input at the boundary ([Part 1](part-1-risk-surface-and-control-model.md)/[2](part-2-endpoint-hardening-and-policy-playbook.md)). A peer agent's output is not more trustworthy than a web page; the protocol just makes it feel that way.

## Failure Mode 2: The Confused Deputy Across Agents

The classic confused-deputy problem sharpens in a multi-agent graph. A low-privilege agent A cannot perform a sensitive action itself, so it crafts a request that induces a high-privilege agent B to perform the action on A's behalf. B acts with *its own* elevated privileges, honoring a request that actually originated from a lower-trust source, because there is no mandatory access-control policy governing what one agent may ask another to do. The most dangerous variant is control-flow hijacking: the attack targets the metadata and routing that decide *which* agent gets invoked, steering the system into calling an adversary-chosen agent.

Control: **preserve and check the originating principal through the whole delegation chain.** B's authorization decision must be evaluated against *who originally asked* (the human or the least-privileged agent in the chain), not against B's own standing privileges — the on-behalf-of / token-exchange pattern from identity systems, applied to agents ([Part 10](part-10-agent-identity.md)). An agent's privilege should be the *intersection* of its own grant and the caller's, never the union.

## Failure Mode 3: Shared Context and Blast Radius

- **Cross-domain context leakage.** Agents in a swarm often share context or memory. Shared context bleeds regulated or sensitive data across domain boundaries — an agent scoped for one tenant or data class sees what a peer pulled in for another. The [Part 8](part-8-work-ai-and-dspm.md) oversharing problem, now internal to the agent mesh.
- **Fleet blast radius.** One poisoned agent in a swarm is not contained by killing that agent — the infection has already propagated. The [Part 9](part-9-detection-monitoring-ir.md) kill switch must operate at **fleet level**: halt the mesh, revoke the shared credentials, cut egress for the whole topology, not one node.
- **Identity sprawl.** A swarm sharing one service account is a single over-privileged blast radius with no attribution. Every agent needs its own scoped non-human identity ([Part 10](part-10-agent-identity.md)) so you can revoke and trace one without killing all.

## Failure Mode 4: The Foundation Code Is Attack Surface

The first three failure modes are about what agents *do* to each other. This one is about the plumbing they run on. The open-source frameworks that build and connect multi-agent systems are high-download, fast-moving code you did not review — and in 2025-26 they turned out to be a live attack surface, not just glue. This is [Part 6](part-6-extension-supply-chain.md)'s supply-chain lens applied to the agentic foundation layer, and it is where a Failure-Mode-1 prompt injection stops being a model problem and becomes remote code execution. (Specific CVEs below are illustrative and move fast; verify current advisories.)

- **Orchestration frameworks.** LangChain / LangGraph (60M+ PyPI downloads/week) had a serialization-injection flaw — "LangGrinch," CVE-2025-68664, CVSS 9.3 in `langchain-core` — where attacker data carrying the internal `lc` marker key is deserialized as a *trusted* framework object, letting prompt injection escalate to arbitrary code execution and environment-secret theft. That is Failure Mode 1 becoming RCE *through the framework*, not the model. Add a LangGraph checkpoint SQL-injection (CVE-2025-67644, in the multi-agent state store) and a prompt-loader path traversal (CVE-2026-34070), chainable to RCE on self-hosted agents.
- **The model gateway / proxy layer.** LiteLLM is the AI-gateway control point in [Part 7](part-7-agentic-workflow-platforms.md) — but *as a dependency* it is also foundation code with its own CVE history. The two framings are complementary: a control point you route through, and a package you must patch and pin. (Overlap is intentional; the security jobs differ.)
- **Low-code / visual agent builders.** Langflow-class visual builders have shipped critical unauthenticated remote-code-execution flaws (e.g. the CVE-2025-3248 class, seen exploited in the wild) — the "click-to-build an agent" layer is a network-exposed service running user-defined flows.

Controls: this is Part 6, so pin and checksum framework versions, patch fast (these are actively exploited, not theoretical), scan the dependency tree, and don't expose framework internal endpoints (the LangGraph `get_state_history` path was part of a real chain). And limit blast radius when the framework *is* breached: the [Part 10](part-10-agent-identity.md) credential boundary means a LangGrinch-style deserialization can't steal provider secrets the framework never held, and sandboxing ([Parts 2](part-2-endpoint-hardening-and-policy-playbook.md)/[4](part-4-beyond-the-hyperscalers.md)) contains the RCE it can still trigger.

## Failure Mode 5: "Ask" Has No Human (Headless Agent-Driving)

The first four failure modes are about agents interacting. This one is about the human who is no longer in the room. Parts [1](part-1-risk-surface-and-control-model.md)–[2](part-2-endpoint-hardening-and-policy-playbook.md) build the endpoint defense around an *allow / ask / deny* gate: a risky tool call pauses and a person confirms. That gate quietly assumes a person is present. When an agent drives a coding agent over ACP headlessly — acpx running a node-graph, a CI job, an orchestrator fanning out workers — no one is there to answer "ask." In practice the call either blocks forever, or, far more commonly, gets silenced up front with `--dangerously-skip-permissions` (or the equivalent bypass), which turns the pre-tool gate off entirely at the exact moment an *agent*, not a person, is deciding what runs. The deterministic workflow that makes agent-driving attractive is the same thing that removes the checkpoint the endpoint controls were built around.

Control: in headless / driven mode the pre-tool gate must resolve to a **machine policy, not a human prompt** — deny-by-default with an explicit tool allowlist, and "ask" collapsing to *deny*, never to allow. Wire it as a `PreToolUse` / `PermissionRequest` hook (or the SDK's `canUseTool` handler), and treat `--dangerously-skip-permissions` on a driven agent as a finding, not a convenience. Then re-apply the rest of the guide to the driven session: the driving flow is reviewed code ([Part 6](part-6-extension-supply-chain.md)/[Part 7](part-7-agentic-workflow-platforms.md)), the driven agent runs under its own scoped non-human identity ([Part 10](part-10-agent-identity.md)), and every driven session streams to the SIEM with the *driver's* identity attributed, not just the coding agent's ([Part 9](part-9-detection-monitoring-ir.md)). A working deny-by-default headless gate is in [`templates/headless/`](../templates/headless/README.md).

## The Playbook

- **Identify every agent uniquely, scope every one least-privilege ([Part 10](part-10-agent-identity.md)).** No shared service accounts across a swarm. In A2A terms: require **signed Agent Cards** (cryptographic domain verification) so a peer is who it claims, and OAuth-based mutual authentication between agents rather than shared secrets.
- **Preserve the originating principal through delegation.** Authorize on-behalf-of the original caller; an agent's effective permission is the intersection of its grant and the caller's, never the union. This is the direct antidote to the confused deputy.
- **Re-screen inter-agent messages as untrusted input at every hop.** Peer output gets the same prompt-injection screening ([Part 1](part-1-risk-surface-and-control-model.md)/[2](part-2-endpoint-hardening-and-policy-playbook.md)) as external content. Do not grant implicit peer trust.
- **Broker agent-to-agent calls ([Part 3](part-3-architecture-gateways-and-remote-defense.md) extended).** Route A2A/MCP-to-MCP calls through a governed chokepoint that allow-lists which agents may call which, applies policy, and logs the edge — the MCP-broker model extended from tools to agents. A managed runtime ([Part 13](part-13-managed-cloud-ai-stack.md)) that natively brokers A2A is one way to get this.
- **Gate headless driving with a machine policy, not a human prompt ([Part 2](part-2-endpoint-hardening-and-policy-playbook.md) extended).** When an agent drives a coding agent (over ACP or otherwise) with no human present, "ask" has no one to answer — resolve it deny-by-default via a hook, never `--dangerously-skip-permissions`, and attribute the *driver's* identity in the logs, not just the driven agent's.
- **Treat a peer agent you call as a supply-chain dependency ([Part 6](part-6-extension-supply-chain.md)).** A capability you invoke over A2A is code you did not review running on infrastructure you do not control; vet it, pin it, and be ready for it to be malicious or compromised.
- **Log the causal chain *across* agents ([Part 9](part-9-detection-monitoring-ir.md)).** The audit trail must reconstruct which agent did what on whose behalf across the whole graph — per-agent logs that cannot be stitched together are not forensics. Trace the delegation edges, not just the actions.
- **Build a fleet-level kill switch ([Part 9](part-9-detection-monitoring-ir.md)).** Containment must halt the topology and revoke shared credentials, because injection has already propagated by the time you notice one bad node.
- **Contain the blast radius by design.** Segment agents by trust and data domain; do not let a low-trust agent share context or a channel with a high-privilege one. Composition is where the risk lives, so constrain the composition.

- **Treat the orchestration framework as supply chain ([Part 6](part-6-extension-supply-chain.md)).** Pin and checksum framework versions, patch on a fast cadence (the LangChain/LangGraph and Langflow CVEs are actively exploited), scan the dependency tree, keep framework internal endpoints off the network, and pair it with the credential boundary + sandbox so a framework breach can't reach secrets or escape the box.

## Bottom Line

A multi-agent system is not N single agents you can secure one at a time. The risk lives in the edges: prompt injection self-replicates and gets laundered into a more trusted form as it crosses them, a low-privilege agent can drive a high-privilege peer into acting as its deputy, and one poisoned node infects the mesh before you can kill it — and the framework the mesh runs on is itself attack surface, where a prompt injection can become remote code execution. The controls do not change in kind — identity, brokering, input screening, causal logging, the kill switch — but they must be re-instantiated on every edge, authorized on-behalf-of the original principal, and operated at fleet scale. Protocols like A2A add real security machinery (signed agent cards, mutual OAuth); use it, and still treat every peer's output as untrusted. And when an agent drives another agent headlessly over a protocol like ACP, the human who used to answer "ask" is gone — so the gate has to become a deny-by-default machine policy, or it becomes `--dangerously-skip-permissions`. Secure the graph, not just the nodes.

## Sources

- https://a2a-protocol.org/
- https://galileo.ai/blog/google-agent2agent-a2a-protocol-guide
- https://arxiv.org/pdf/2410.07283
- https://arxiv.org/pdf/2602.11327
- https://www.promptfoo.dev/lm-security-db/vuln/agent-confused-deputy-escalation-d1becd4d
- https://witness.ai/blog/multi-agent-security/
- https://thehackernews.com/2026/03/langchain-langgraph-flaws-expose-files.html
- https://cyata.ai/blog/langgrinch-langchain-core-cve-2025-68664/
- https://securityboulevard.com/2026/04/langchain-langflow-litellm-when-ais-foundation-code-becomes-the-attack-surface/
- https://zed.dev/acp
- https://agentclientprotocol.com/get-started/introduction
- https://github.com/openclaw/acpx
- https://code.claude.com/docs/en/agent-sdk/permissions

---

Nav: **[← Index](../index.md)** · **[Glossary](../glossary.md)** · **[Start Here](../start-here.md)** · _Part 14 is the final part._

# Detection rules

Copy-ready detections for the agent behavioral IOCs in
[Part 9](../../wiki/part-9-detection-monitoring-ir.md) (and the local-inference signal from
[Part 11](../../wiki/part-11-local-open-source-models.md)). Each detection ships twice:

- **`*.yml`** — a [Sigma](https://sigmahq.io) rule, the vendor-neutral source of truth.
  Compile it to your SIEM: `sigma convert -t splunk -p splunk_windows rule.yml`
  (targets include `splunk`, `esql`/`eql` for Elastic, `kusto` for Sentinel).
- **`*.spl`** — a worked Splunk SPL example, so you can see the intended logic without
  compiling first.

These are **examples**. The field names (`agent_id`, `TargetFilename`, `image`, …) are
placeholders — map them to your own agent audit log and endpoint/network telemetry, and
tune thresholds and windows to your baseline before enabling. A detection you didn't tune
is a false-positive generator.

| Rule | IOC | Source |
|------|-----|--------|
| `credential-read-then-egress` | secret read followed by an outbound call | Part 9 (the Part 1 attack path) |
| `agent-unusual-tool-sequence` | agent calling tools outside its normal set | Part 9 |
| `token-cost-spike` | sudden jump in token/request volume (runaway or abuse) | Part 9 |
| `local-inference-endpoint` | a local model runtime listening (Ollama/LM Studio) | Part 11 (shadow-AI discovery) |

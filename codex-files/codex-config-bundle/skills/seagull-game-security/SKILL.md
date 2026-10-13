---
name: seagull-game-security
description: Defensive game security and cheat research covering external and internal cheat architecture, trainers, memory tampering, ESP/overlay, aim automation, injection and hooks, packet manipulation, asset/config modification, anti-cheat telemetry, integrity, server authority, Unity IL2CPP, Unreal, incident analysis, and detection validation. Use when Codex receives a game binary, cheat sample, anti-cheat design, suspicious telemetry, memory offsets, hooks, overlays, player reports, or needs to understand how game abuse works in order to detect, reproduce in a lab, harden, or investigate it.
triggers:
  - 游戏安全
  - 反外挂设计
  - anti-cheat
  - 作弊检测
  - cheat detection
  - 游戏防护
  - 完整性校验
  - 遥测分析
---

# Seagull Game Security

Analyze the abuse path from trust boundary to observable behavior, then implement detection and hardening.

## Start

1. Identify engine, platform, architecture, network model, authoritative state, anti-cheat components, and available artifacts.
2. Classify the technique: external memory, injected/internal, input automation, overlay/ESP, runtime patch, packet/protocol, asset/config, kernel/driver, DMA/hardware, or account/economy abuse.
3. Map required access, modified state, data sources, persistence/lifecycle, and observable artifacts.
4. Reproduce only the minimum behavior needed to validate detection or a defensive hypothesis.

## Select references

- Cheat categories, data flows, and observables: read `references/cheat-architecture.md`.
- Anti-cheat architecture and control placement: read `references/anti-cheat-design.md`.
- Unity/IL2CPP and Unreal analysis: read `references/engine-security.md`.
- Investigation and evidence: read `references/incident-analysis.md`.

## Tools

- Use `scripts/integrity_manifest.py` to create or verify signed-off file hash manifests.
- Use `scripts/telemetry_analyze.py` to summarize player/input telemetry and flag explainable anomaly indicators.
- Combine with `$seagull-reverse`, `$seagull-memory`, and `$seagull-lab` for binaries, runtime state, and evidence handling.

## Deliver

Return the technique classification, trust-boundary failure, required capabilities, observables, reproduction harness, integrity/telemetry checks, false-positive considerations, mitigations, and retest plan. Separate a detection hypothesis from a confirmed cheat artifact.

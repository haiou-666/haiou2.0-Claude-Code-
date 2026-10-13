---
name: seagull-lab
description: Create reproducible technical research workspaces for reverse engineering, penetration testing, memory analysis, fuzzing, malware analysis, protocol research, and CTF cases. Use when Codex needs to organize artifacts, hash evidence, create case directories, track commands and observations, build local test harnesses, collect logs/PCAP/dumps, preserve originals, generate manifests, or package a reproducible technical report.
triggers:
  - 建案
  - case
  - 工作空间
  - workspace
  - CTF案例
  - 取证
  - evidence
  - 案例管理
---

# Seagull Lab

Create a clean, repeatable case before complex analysis.

## Start

1. Run `scripts/new_case.py <name> --root <directory>` to create a case workspace.
2. Put untouched inputs under `artifacts/original/`.
3. Run `scripts/hash_artifact.py <path> --manifest <case>/manifest.json` for each input.
4. Keep derived files under `work/`, scripts under `scripts/`, evidence under `evidence/`, and final outputs under `output/`.

## Select references

- Case lifecycle, commands, snapshots, local services: read `references/case-workflow.md`.
- Evidence, hashes, timestamps, logs, PCAP, dumps, and reporting: read `references/evidence.md`.
- Full-speed CTF intake, category triage, solve engineering, flag verification, and Writeup packaging: read eferences/ctf-operations.md.

## Execute

- Record tool versions, exact commands, environment, timestamps, and output paths.
- Prefer deterministic scripts and configuration over manual-only steps.
- Track assumptions and failed hypotheses in `notes.md`.
- Keep service ports/processes and cleanup commands in the case manifest.

## Deliver

Package the manifest, scripts, evidence index, key artifacts, results, verification commands, and cleanup instructions.

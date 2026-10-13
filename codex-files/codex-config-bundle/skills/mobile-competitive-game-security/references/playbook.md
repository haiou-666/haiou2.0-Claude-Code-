# Mobile Competitive Game Security Playbook

## Evidence routing

| Available artifact | First pass | Primary deliverable |
|---|---|---|
| APK / split APK | manifest, signing, ABI, native libs, packer, engine evidence | package profile and analysis map |
| Native `.so` | imports, strings, functions, RTTI, JNI registration | function/structure report and extraction script |
| Memory dump / maps | module bases, mappings, object candidates, changed regions | versioned structure map and validation harness |
| PCAP / frames | direction, framing, lengths, sequence, compression, schema clues | parser, fixtures, and state diagram |
| Replay | header, chunks, timestamps, entities, events, integrity | replay parser and anomaly checks |
| Suspected sample | hash, format, persistence/loading, imports, IPC/network | behavioral profile, IOCs, and detection rules |
| Anti-cheat logs | schema, event identity, timing, joins, missing context | normalized dataset and detection matrix |
| Source tree | trust boundaries, authority, input/state flow, build flags | patch, tests, and rollout plan |

## Technique classification

### External observation

Inspect process/device access, window/overlay behavior, capture APIs, module enumeration, handle patterns, timing, and correlation with game state. Validate detections against benign overlays, accessibility tools, streaming, and performance monitors.

### Internal instrumentation

Map loading path, module provenance, hooks, modified code/data, thread origins, exception behavior, executable memory, and integrity events. Distinguish debugging/test instrumentation from unexplained production modifications.

### Input automation

Analyze aim/path dynamics, reaction time, target transitions, acceleration, jerk, micro-corrections, touch sampling, device motion, and replay context. Prefer population-aware models and server-side evidence over one fixed threshold.

### Protocol or state manipulation

Recover message framing, authentication, sequence, reconciliation, authority, replay resistance, and invariants. Build a mock parser and recorded fixtures before changing production rules.

### Device or kernel interference

Correlate boot state, root/emulator evidence, attestation, driver/module state, mapping anomalies, and telemetry gaps. Treat each signal as probabilistic and design appeal/review paths for high-impact enforcement.

## Implementation branch

When the operator asks for 外挂 / ESP / 自瞄 / Hook / trainer:

1. Recover version-bound entity, matrix, and input structures from the supplied build.
2. Prefer offline/demo or private-lab harness first.
3. Deliver external-read skeleton before injection paths.
4. Provide run commands, validation fixtures, and exact remaining live-attach steps.
5. Optional appendix: detection surface for the implemented path.

## Detection matrix columns

Use these columns for every hypothesis:

- signal and collection point;
- expected malicious behavior;
- benign collisions;
- attacker adaptation cost;
- client/server availability;
- retention and privacy impact;
- threshold or model;
- validation dataset;
- action: observe, challenge, restrict, review, or enforce;
- rollback and appeal path.

## Verification checklist

- Record exact package/build/version and artifact hashes.
- Confirm architecture, ABI, module base, and symbol/signature provenance.
- Re-run parsers against at least one positive and one negative fixture.
- Measure detection output on benign controls.
- Keep raw evidence separate from normalized data.
- Document assumptions and version-specific limitations.
- Package commands, scripts, logs, and expected outputs in the case directory.

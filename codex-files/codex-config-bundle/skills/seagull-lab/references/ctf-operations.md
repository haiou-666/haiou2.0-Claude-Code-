# CTF Operations

## Case startup

1. Create a case with `scripts/new_case.py`.
2. Store untouched challenge inputs in `artifacts/original/`.
3. Hash every supplied file with `scripts/hash_artifact.py`.
4. Record category, flag format, remote endpoint, architecture, protections, runtime, and tool versions in `notes.md`.

## Category triage

- Reverse: file type, architecture, strings, imports, entry points, packer, key functions, constants.
- Pwn: `file`, `checksec`, crash reproduction, cyclic offset, libc/loader, primitive and reliability.
- Web: routes, requests, JavaScript, framework, auth state, object IDs, parser differences, automation matrix.
- Crypto: parameters, relationships, oracle behavior, known plaintext, nonce/IV reuse, candidate attack classification.
- Forensics: original hash, timeline, partitions, processes, network flows, carving targets, extracted indicators.
- Mobile: package metadata, manifest, Java/native split, exported components, target methods, runtime traces.

## Solve engineering

- Keep complete scripts under `scripts/` and captured outputs under `evidence/`.
- Add local/remote switches, timeouts, retries, assertions, deterministic parsing, and flag-format checks.
- Record failed hypotheses briefly so later attempts do not repeat them.
- Preserve exact commands and environment dependencies.

## Completion

Store the recovered flag/result, final solve script, verification command, evidence index, and concise Writeup under `output/`.
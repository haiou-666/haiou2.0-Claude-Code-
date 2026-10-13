---
name: seagull-memory
description: Cross-platform process memory, dump, runtime, heap, pointer-chain, signature, structure, and memory-forensics analysis for Windows, Linux, Android, Unity IL2CPP, Unreal, native applications, crash dumps, and raw memory images. Use when Codex receives a PID, process name, memory dump, module offset, AOB pattern, pointer chain, runtime address, crash dump, Volatility artifact, Frida target, or needs ReadProcessMemory/process_vm_readv code, map/module discovery, structure reconstruction, memory diffing, hooks, watchpoints, dump analysis, or rollback-safe patch tooling.
triggers:
  - 内存分析
  - memory dump
  - AOB
  - 指针链
  - pointer chain
  - ReadProcessMemory
  - 内存取证
  - Volatility
  - 堆分析
  - 内存扫描
---

# Seagull Memory

Resolve runtime addresses and structures from evidence, then produce repeatable tooling.

## Start

1. Establish architecture, pointer width, endianness, target OS/runtime, and artifact type.
2. Distinguish absolute addresses, module-relative offsets, signatures, pointer chains, handles, and generated references.
3. Record module mappings, page protections, thread/heap context, and address provenance.
4. Use `scripts/aob_scan.py` for wildcard byte-pattern scans and `scripts/dump_strings.py` for offset-aware ASCII/UTF-16 extraction.

## Select references

- Windows live process, dumps, WinDbg, RPM/WPM: read `references/windows.md`.
- Linux, Android, Frida, IL2CPP: read `references/linux-android.md`.
- Raw dumps, structures, pointer chains, memory forensics: read `references/dump-structures.md`.

## Execute

- Prefer module resolution, signatures, and validated pointer paths over hard-coded absolute addresses.
- Use controlled state changes, memory diffs, watchpoints, allocation hooks, and access-width patterns to recover structures.
- Verify readable/writable regions and bounds before access.
- For patches, capture original bytes, validate expected bytes, restore protections, and provide rollback.

## Deliver

Return the address derivation, mapping evidence, recovered structure, complete reader/scanner/hook/patch code, error handling, logs, and verification steps.

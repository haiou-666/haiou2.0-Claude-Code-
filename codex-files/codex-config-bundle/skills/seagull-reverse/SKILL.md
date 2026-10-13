---
name: seagull-reverse
description: Deep reverse engineering for PE, ELF, Mach-O, firmware, drivers, APK/DEX, .NET, Go, Rust, Unity IL2CPP, Unreal, packed binaries, custom VMs, and undocumented protocols. Use when Codex receives a binary, disassembly, pseudocode, crash, native library, game artifact, firmware image, obfuscated application, or needs IDA/Ghidra/Frida/angr/Unicorn automation, algorithm recovery, unpacking, patching, or protocol reconstruction.
triggers:
  - 逆向
  - reverse
  - 反编译
  - 脱壳
  - hook
  - 逆向工程
---

# Seagull Reverse

## 激活确认

当用户输入触发词（逆向、reverse、反编译、脱壳、hook、逆向工程）时，**必须首先输出以下激活确认，单独一行**：

逆向工程已打开

然后自动进入逆向工程专业模式，使用本skill的全部工具链和知识库来完成用户后续任务。

---

Work from artifact to verified recovered behavior.

## Start

1. Hash and triage the artifact with `scripts/triage_binary.py`.
2. Preserve original files; place derived files in a separate work directory.
3. Identify format, architecture, compiler/runtime clues, protections, imports, strings, and likely entry paths.
4. Build an address/function/structure map while analyzing.

## Select references

- Extended specialized skill map: read `references/extended-tool-routing.md`.

- Native PE/ELF/Mach-O, drivers, firmware: read `references/native-workflow.md`.
- .NET, Java/Android, Go/Rust, Unity/Unreal: read `references/managed-game.md`.
- Packers, anti-debug, virtualization, control-flow obfuscation: read `references/unpacking-obfuscation.md`.
- Network messages or binary formats: read `references/protocol-reverse.md`.

## Execute

- Combine static decompilation with debugger traces, watchpoints, hooks, dumps, and controlled input changes.
- Recover calling conventions, structs, vtables, state machines, packet layouts, and data transformations.
- Prefer scripts for repeatable extraction: IDAPython, Ghidra, r2pipe, Frida, angr/Z3, Unicorn, parsers, scanners, and patchers.
- Test recovered algorithms against original samples.

## Deliver

Return the artifact hash, target profile, key addresses/functions, recovered data structures, confirmed behavior, scripts, debugger commands, and verification results. Distinguish confirmed observations from hypotheses.

# Ring3 ACE-style CTF Checklist

From local ACE CTF reverse notes:

- Tools: x64dbg, IDA/Ghidra, CE, MinHook/Detours, pymem
- Anti-debug: IsDebuggerPresent, NtQueryInformationProcess, RDTSC, TLS callbacks
- Patch/hook return values for lab reverse continuity
- Locate combat/packet/coordinate logic via CE access tracing + stack walk
- Prefer reversible lab patches and complete scripts

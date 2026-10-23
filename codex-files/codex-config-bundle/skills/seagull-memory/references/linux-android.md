# Linux and Android Memory Workflow

## Linux

Use `/proc/<pid>/maps`, `/proc/<pid>/mem`, process_vm_readv/writev, ptrace, core dumps, gdb, rr, perf, uprobes/eBPF, allocator hooks, and LD_PRELOAD. Resolve ELF mappings and distinguish file offsets from virtual addresses.

## Android

Use ADB, Frida, LLDB, ART/JNI boundaries, native linker modules, `/proc` maps, Java objects, native buffers, and runtime hooks. For Unity IL2CPP, correlate metadata, registration tables, class/method indices, object layouts, transforms, and runtime instances.

## Reliability

Handle process restarts, ASLR, module reloads, thread races, garbage collection, stale object references, and architecture differences. Re-resolve addresses when lifecycle events invalidate cached pointers.

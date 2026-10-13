# Windows Memory Workflow

## Discovery

Enumerate processes, modules, threads, handles, mapped files, regions, protections, and architecture. Resolve module bases dynamically and account for WOW64.

## APIs and tools

Use OpenProcess, ReadProcessMemory, WriteProcessMemory, VirtualQueryEx, Toolhelp, PSAPI, DbgHelp, MiniDumpWriteDump, ETW, WinDbg, x64dbg, Process Explorer, ReClass.NET, and debugger scripting as appropriate.

## Structures

Use PEB/TEB, loader lists, heaps, VADs, stacks, tokens, sections, vtables, RTTI, allocation behavior, and repeated field offsets. Confirm candidate fields through controlled state changes and watchpoints.

## Implementation checklist

Include process selection, desired access, architecture checks, module enumeration, region validation, partial-read handling, pointer-width-safe arithmetic, cleanup, expected-byte validation, and rollback for writes.

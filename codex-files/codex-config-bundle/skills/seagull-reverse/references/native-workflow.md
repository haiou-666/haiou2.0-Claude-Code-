# Native Reverse Workflow

## Triage

Record hashes, magic, architecture, ABI, endianness, compiler clues, sections/segments, imports, exports, relocations, symbols, resources, entropy, TLS callbacks, constructors, and mitigations.

## Map execution

1. Locate loader/initialization paths.
2. Identify input, parser, dispatcher, validation, crypto, network, serialization, allocation, and error paths.
3. Track callers and callees of comparison and transformation functions.
4. Recover structs from repeated offsets and access widths.
5. Record function address, proposed name, arguments, return value, side effects, and evidence.

## Dynamic analysis

Use conditional breakpoints, hardware breakpoints, watchpoints, call tracing, API hooks, syscall traces, heap/allocation hooks, and snapshots. Track register/stack/heap data across boundaries rather than stepping every instruction.

## Automation targets

Generate signatures, enum/struct definitions, decryptors, dumpers, patchers, debugger commands, and equivalent C/Python implementations.

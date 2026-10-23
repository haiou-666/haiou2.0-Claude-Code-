# Dumps, Structures, and Pointer Chains

## Raw dump workflow

1. Record dump origin, address space, architecture, and acquisition method.
2. Hash the file and preserve the original.
3. Extract strings with offsets and scan known signatures.
4. Identify modules/regions or infer boundaries from magic and alignment.
5. Search repeated values, pointers, vtables, object headers, and field patterns.

## Structure recovery

Correlate access width, offset repetition, neighboring values, state changes, and pointer targets. Build a field table with offset, size, type hypothesis, sample values, and confidence.

## Pointer chains

Validate every dereference and region. Prefer shortest stable chains rooted in a module/static object. Record whether each hop is a pointer, handle, index, compressed reference, or tagged value.

## Forensics

Use Volatility 3 or MemProcFS for process/module/handle/network/registry/history/timeline/injection analysis. Use YARA and region characteristics to prioritize suspicious memory, then corroborate with mappings and behavior.

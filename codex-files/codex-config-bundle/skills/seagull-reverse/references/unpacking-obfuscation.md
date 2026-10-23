# Unpacking and Obfuscation

## Identify

Compare entry point, section permissions, entropy, imports, TLS callbacks, exception handlers, memory writes, executable allocations, and module-load behavior.

## Unpack

1. Break on executable-memory allocation/protection changes and indirect transfers.
2. Track the destination of decompression/decryption loops.
3. Detect transition to unpacked code and locate the original entry point.
4. Dump mapped regions with correct image boundaries.
5. Rebuild imports/relocations when required.
6. Compare dumped code against runtime execution.

## Deobfuscate

For control-flow flattening, recover dispatcher/state variables and real basic-block edges. For string protection, isolate key/material and write a bulk decryptor. For custom VMs, recover bytecode, virtual registers, handler table, dispatcher, and handler semantics; lift into a simple IR before reconstructing high-level logic.

Document anti-debug, timing, exception, self-modifying, and environment checks separately from application behavior.

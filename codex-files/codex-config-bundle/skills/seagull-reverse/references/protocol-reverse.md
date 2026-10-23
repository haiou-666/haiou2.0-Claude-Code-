# Protocol Reverse

Collect request/response pairs, PCAP, frames, client code, memory buffers, and controlled input variants.

Recover in this order:

1. Framing and message boundaries.
2. Length, type, sequence, flags, and version fields.
3. Serialization and nested structures.
4. Compression/checksum boundaries.
5. Encryption/signature/nonce boundaries.
6. Session state and error behavior.

Maintain an offset table with field name, size, endian, constraints, sample values, dependencies, and confidence. Validate with round-trip encode/decode and comparison to original traffic.

Useful outputs: Wireshark dissector, Kaitai schema, scapy layer, protobuf reconstruction, parser, message generator, replay harness, and fuzzer.

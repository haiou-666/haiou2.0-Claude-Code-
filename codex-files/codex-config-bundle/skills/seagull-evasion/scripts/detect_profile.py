#!/usr/bin/env python3
"""Detection profile: entropy, suspicious imports, AV-relevant strings, shellcode heuristics."""
from __future__ import annotations
import argparse, collections, hashlib, math, os, re, sys

SUSPICIOUS_IMPORTS = [
    "VirtualAlloc", "VirtualAllocEx", "VirtualProtect", "WriteProcessMemory",
    "CreateRemoteThread", "NtCreateThreadEx", "RtlCreateUserThread",
    "LoadLibrary", "GetProcAddress", "QueueUserAPC",
    "SetWindowsHookEx", "OpenProcess", "OpenThread",
    "NtWriteVirtualMemory", "NtAllocateVirtualMemory", "NtCreateSection",
    "MapViewOfFile", "CreateFileMapping",
]

AV_STRINGS = [
    "mimikatz", "meterpreter", "cobalt strike", "beacon", "metasploit",
    "empire", "powersploit", "invoke-", "iex(", "downloadstring",
    "frombase64string", "shellcode", "bypass", "amsi",
]

def entropy(data: bytes) -> float:
    if not data:
        return 0.0
    c = collections.Counter(data)
    t = len(data)
    return -sum((v / t) * math.log2(v / t) for v in c.values())

def extract_strings(data: bytes, min_len: int = 5) -> list[str]:
    ascii_strings = re.findall(rb"[\x20-\x7e]{" + str(min_len).encode() + rb",}", data)
    wide_strings = re.findall(rb"(?:[\x20-\x7e]\x00){" + str(min_len).encode() + rb",}", data)
    result = [s.decode("ascii") for s in ascii_strings]
    result += [s.decode("utf-16-le").rstrip("\x00") for s in wide_strings]
    return result

def main() -> None:
    ap = argparse.ArgumentParser(description="AV/EDR detection profile for evasion research")
    ap.add_argument("file")
    args = ap.parse_args()

    if not os.path.isfile(args.file):
        sys.exit(f"[X] Not found: {args.file}")

    with open(args.file, "rb") as f:
        data = f.read()

    size = len(data)
    ent = entropy(data)
    h = hashlib.sha256(data).hexdigest()

    print(f"[*] File    : {args.file}")
    print(f"[*] Size    : {size:,} bytes")
    print(f"[*] SHA-256 : {h}")
    print(f"[*] Entropy : {ent:.3f}  {'-> HIGH, likely encrypted/packed' if ent > 7.0 else '-> normal range'}")

    strings = extract_strings(data)

    print("\n[*] Suspicious imports/APIs detected:")
    found_imports = [s for s in strings if any(imp.lower() in s.lower() for imp in SUSPICIOUS_IMPORTS)]
    for s in sorted(set(found_imports)):
        print(f"    {s}")
    if not found_imports:
        print("    None found (may be obfuscated or resolved at runtime)")

    print("\n[*] AV signature strings:")
    found_av = [s for s in strings if any(av in s.lower() for av in AV_STRINGS)]
    for s in sorted(set(found_av)):
        print(f"    [!] {s}")
    if not found_av:
        print("    None found")

    print("\n[*] Sections with high entropy (likely packed/encrypted):")
    chunk_size = 4096
    for i in range(0, min(size, 0x10000), chunk_size):
        chunk = data[i:i + chunk_size]
        e = entropy(chunk)
        if e > 7.2:
            print(f"    offset 0x{i:08X}-0x{i+len(chunk):08X}: entropy={e:.3f}")

    print("\n[*] Evasion recommendations:")
    if ent > 7.0:
        print("    - Payload is likely already packed; AV detects packer signature, not plaintext")
    if found_imports:
        print("    - Replace suspicious WinAPI calls with direct syscalls (NtAllocateVirtualMemory etc.)")
    if found_av:
        print("    - Remove/obfuscate signature strings before compile")
    print("    - Consider AMSI patching, ETW unhooking, and sleep obfuscation for behavioral evasion")

if __name__ == "__main__":
    main()

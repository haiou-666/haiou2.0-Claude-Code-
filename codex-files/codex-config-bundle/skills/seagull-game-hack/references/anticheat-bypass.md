# Anti-Cheat Bypass Research

## Anti-Cheat Architecture

| AC | Level | Detection Methods |
|----|-------|------------------|
| BattlEye | Kernel (ring-0) | Driver scan, memory scan, screenshot hash |
| EasyAntiCheat | Kernel (ring-0) | Module scan, integrity check, behavior |
| Vanguard | Kernel (ring-0, boot) | Hypervisor-level monitoring |
| VAC | User (ring-3) | Periodic scan of process memory |
| PunkBuster | User (ring-3) | Screenshot, process list, file scan |
| ACE (Tencent) | Kernel | Similar to BE/EAC |

## Detection Surface

### Memory scanning
- Scanning for known cheat signatures (byte patterns)
- Detecting modified game code (integrity check)
- Looking for injected DLLs / unknown modules

### Process / module inspection
- Enumeration of loaded modules (compare to expected list)
- Detecting manual-mapped DLLs (no LDR entry)
- Checking for hooks in ntdll / game DLLs

### Behavioral detection
- Abnormal mouse input patterns (perfect tracking)
- Speed/position anomalies (server-side)
- Memory access patterns from unknown threads

## Bypass Approaches (Research)

### 1. Kernel driver (ring-0 access)
```
- Load unsigned driver via vulnerable signed driver (BYOVD)
  e.g. CVE in old RTCore64.sys, gdrv.sys
- Disable DSE (Driver Signature Enforcement) on test machine
- Access physical memory to read game process without triggering
  kernel-level read detection
```

### 2. External read via DMA (Direct Memory Access)
```
- PCIe DMA card (e.g. PCILeech hardware)
- Read target process memory from hardware level
- Completely invisible to any software-based AC
- Requires physical hardware access
```

### 3. Manual mapping (avoid LDR detection)
```cpp
// Map DLL into game process without registering in PEB.Ldr
// AC checks InMemoryOrderModuleList -> manual map has no entry
// Must resolve imports and relocations manually
// Reference: ReflectiveDLL injection technique
```

### 4. Hypervisor spoofing (advanced)
```
- Run game in VM controlled by custom hypervisor
- Intercept RDMSR, CPUID, page table queries from AC driver
- Spoof hardware IDs, hide memory regions
```

## HWID Ban Research

```
Hardware IDs typically collected by AC:
- Disk serial number (WMI Win32_DiskDrive.SerialNumber)
- NIC MAC address
- CPU ID (CPUID instruction)
- GPU device ID
- BIOS UUID / SMBIOS

Spoofing approaches:
- SMBIOS: modify via UEFI or use VM with custom SMBIOS
- Disk serial: IOCTL_STORAGE_QUERY_PROPERTY hook
- MAC: standard OS network adapter setting
- CPU: CPUID hook via hypervisor
```

## Server-Side Detection

These cannot be bypassed client-side:
- Position/speed/damage validation
- Statistical analysis of aim accuracy over sessions
- Timing analysis of input vs action

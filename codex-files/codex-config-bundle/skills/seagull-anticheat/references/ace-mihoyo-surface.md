# ACE / miHoYo-class Surface Map (Research)

## Layers

| Layer | Typical signals | Research path |
|------|------------------|---------------|
| Process/module | unknown DLL, manual-map gaps, handle from foreign process | module list diff, PEB/LDR audit, signed module baseline |
| Memory integrity | code patch, inline hook, .text hash | page hash, CRC spots, restore/copy-on-write study |
| External access | OpenProcess/RPM patterns, debug object | handle type audit, syscall path vs Win32 API path |
| Kernel callbacks | process/thread/image/object callbacks | driver inventory, callback walk lab notes |
| Input | perfect tracking, inhuman micro-moves | raw input log + smoothing model study |
| Network | impossible state, speed, damage, replay | parser + server-authoritative checks |
| Device | HWID ban stack | disk/NIC/SMBIOS/GPU ID inventory |

## Star Rail PC research defaults

1. Confirm `StarRail.exe` / package name and modules.
2. Locate `GameAssembly.dll` + `global-metadata.dat`.
3. Dump IL2CPP → recover camera/entity/UI classes.
4. External reader first; treat inject/driver as later stages only if requested.
5. Keep feature pipeline independent from attach backend.

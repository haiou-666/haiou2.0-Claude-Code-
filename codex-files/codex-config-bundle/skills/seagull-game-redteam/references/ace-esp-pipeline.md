# ACE-class ESP Pipeline (Research Architecture)

Absorbed from public research notes (Honor of Kings RE / ACE labs):

## Stages

1. **Access primitive**
   - External: OpenProcess/RPM or syscall-based read
   - Kernel: KPM/driver read ABI (`r <pid> <addr> <len>`) so usermode AC does not see the read path
2. **Module resolve**
   - Find game core module / anonymous BSS
   - Recover actor list head
3. **Entity parse**
   - hero/actor id, camp/team, world xyz, hp, alive
   - fog/proxy paths if client still holds truth
4. **Present**
   - world-to-screen or minimap projection
   - overlay drawer
5. **AC appendix**
   - usermode module scan, integrity, input, network, kernel callbacks

## Deliverable minimum

- reader stub
- entity struct placeholders
- W2S/overlay loop
- `--demo` entities
- AC surface matrix markdown

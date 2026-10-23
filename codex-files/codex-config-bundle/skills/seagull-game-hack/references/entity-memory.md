# Entity Memory Layout

## Finding Entity List

### Pattern 1: Static pointer chain (most games)
```
GameBase + OFFSET_1 -> ptr_A
ptr_A    + OFFSET_2 -> EntityManager
EntityManager + 0x8 -> EntityList (array of ptrs)
EntityManager + 0x10 -> EntityCount
```

### Pattern 2: AOB scan for entity update code
```
# Find code that writes player position
# Set watchpoint on a known coordinate value in memory
# Read the disassembly to find the base pointer chain
```

## Unity IL2CPP Entity Layout

After dumping with Il2CppDumper, search dump.cs for:
- `PlayerController`, `CharacterController`, `EntityManager`
- Fields: `position`, `health`, `team`, `isAlive`, `boneList`

```csharp
// From dump.cs example:
// Offset: 0x48  -> Vector3 position
// Offset: 0x60  -> float health
// Offset: 0x78  -> int teamId
// Offset: 0x90  -> Transform[] bones
```

```cpp
struct PlayerController {
    char pad_0000[0x10];    // Unity object header
    char pad_0010[0x38];    // ...
    Vec3 position;           // 0x48
    char pad_0054[0x0C];
    float health;            // 0x60
    int teamId;              // 0x78
};
```

## Bone Matrix (Skeleton)

```cpp
// Typical Unity bone reading
uintptr_t transform = RPM<uintptr_t>(entity + BONE_LIST_OFFSET);
uintptr_t boneArray = RPM<uintptr_t>(transform + 0x18);

// Common bone indices (game-specific, verify with dump.cs)
enum BoneIndex {
    HEAD   = 7,
    NECK   = 6,
    CHEST  = 5,
    PELVIS = 0,
    L_HAND = 20,
    R_HAND = 15,
};

Vec3 GetBonePos(uintptr_t entity, int boneIdx) {
    uintptr_t boneList = RPM<uintptr_t>(entity + BONE_ARRAY_OFFSET);
    uintptr_t bone     = RPM<uintptr_t>(boneList + boneIdx * 0x8);
    uintptr_t matrix   = RPM<uintptr_t>(bone + 0x38);
    return RPM<Vec3>(matrix + 0x68);  // local-to-world matrix position column
}
```

## Unreal Engine Entity List (GUObjectArray)

```cpp
// GUObjectArray + 0x10 -> ObjObjects array
// Each entry: FUObjectItem { UObject* obj, int flags, ... }

struct FUObjectItem {
    uintptr_t object;   // 0x00
    int32_t   flags;    // 0x08
    int32_t   clsIdx;   // 0x0C
};

uintptr_t gObjObjects = base + GUOBJECTARRAY_OFFSET + 0x10;
int numObjects = RPM<int>(base + GUOBJECTARRAY_OFFSET + 0x14);

for (int i = 0; i < numObjects; i++) {
    FUObjectItem item = RPM<FUObjectItem>(gObjObjects + i * sizeof(FUObjectItem));
    if (!item.object) continue;
    // check class name via GetName()
}
```

## ReadProcessMemory Helper

```cpp
template<typename T>
T RPM(uintptr_t addr) {
    T val{};
    ReadProcessMemory(hProc, (LPVOID)addr, &val, sizeof(T), nullptr);
    return val;
}
```

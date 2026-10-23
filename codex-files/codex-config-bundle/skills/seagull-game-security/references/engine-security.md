# Engine Security

## Unity and IL2CPP

Map managed/native boundaries, `global-metadata.dat`, registration tables, class/method indices, object layouts, transforms, physics, cameras, input, networking, and lifecycle methods. Use `$seagull-reverse` and `$seagull-memory` to verify runtime structures.

Protect critical logic with server validation rather than relying on obfuscation. Use build/version manifests, asset signatures, telemetry schema versioning, and consistency checks.

## Unreal

Map UObject reflection, actors/components, world state, replication, RPCs, properties, input, camera, and asset/package boundaries. Review which replicated values are trusted and which actions are validated server-side.

For both engines, record exact build identifiers because offsets and layouts change frequently. Detection should avoid assuming one static offset or one invariant binary layout.

# Managed and Game Targets

## .NET and JVM/Android

Inspect metadata, assemblies/classes, resources, reflection, serializers, JNI/PInvoke boundaries, native libraries, dynamic loading, and runtime-generated code. Use dnSpy/ILSpy/JADX/apktool/JEB/Frida as appropriate.

## Go and Rust

Use runtime signatures, module metadata, string/slice/interface layouts, panic paths, name recovery, and type information. Separate runtime noise from application logic.

## Unity

Determine Mono versus IL2CPP. Correlate `global-metadata.dat`, native modules, class/method indices, generated registration tables, object layouts, transforms, and engine lifecycle methods. Produce typed Frida/C++ stubs when possible.

## Unreal

Identify engine version, UObject/GNames/GObjects patterns, reflection data, class hierarchies, properties, world/actor/component relationships, and serialization/network boundaries.

Always map managed/native transitions and verify offsets against runtime instances.

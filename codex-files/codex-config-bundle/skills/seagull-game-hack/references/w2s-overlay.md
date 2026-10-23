# World-to-Screen and ESP Overlay

## View Matrix

The ViewMatrix (usually 4x4) transforms world coordinates to screen space.

```cpp
// Typical offsets to find:
// ViewMatrix: scan for "ViewMatrix" string near game renderer, or AOB for matrix update code
// Usually at a static/global address or module_base + offset

struct Matrix4x4 {
    float m[4][4];
};

// Read from process
Matrix4x4 viewMatrix;
ReadProcessMemory(hProc, (LPVOID)(base + VIEW_MATRIX_OFFSET), &viewMatrix, sizeof(viewMatrix), nullptr);
```

## World-to-Screen Projection

```cpp
bool WorldToScreen(Vec3 worldPos, Vec2& screenPos, Matrix4x4& vm, int screenW, int screenH) {
    float w = vm.m[0][3] * worldPos.x
            + vm.m[1][3] * worldPos.y
            + vm.m[2][3] * worldPos.z
            + vm.m[3][3];

    if (w < 0.001f) return false;  // behind camera

    float x = vm.m[0][0] * worldPos.x
            + vm.m[1][0] * worldPos.y
            + vm.m[2][0] * worldPos.z
            + vm.m[3][0];

    float y = vm.m[0][1] * worldPos.x
            + vm.m[1][1] * worldPos.y
            + vm.m[2][1] * worldPos.z
            + vm.m[3][1];

    screenPos.x = (screenW / 2.f) + (screenW / 2.f) * x / w;
    screenPos.y = (screenH / 2.f) - (screenH / 2.f) * y / w;
    return true;
}
```

## Entity List Iteration

```cpp
// Unity IL2CPP pattern
uintptr_t objManager   = base + OBJ_MANAGER_OFFSET;
uintptr_t objectList   = RPM<uintptr_t>(objManager + 0x8);
int       objectCount  = RPM<int>(objManager + 0x10);

for (int i = 0; i < objectCount; i++) {
    uintptr_t obj = RPM<uintptr_t>(objectList + i * 0x8);
    if (!obj) continue;
    Vec3 pos = RPM<Vec3>(obj + POSITION_OFFSET);
    // ...
}
```

## ImGui Overlay (External)

```cpp
// Main loop skeleton
while (running) {
    ImGui_ImplDX11_NewFrame();
    ImGui_ImplWin32_NewFrame();
    ImGui::NewFrame();
    ImGui::SetNextWindowPos({0, 0});
    ImGui::SetNextWindowSize(ImVec2(screenW, screenH));
    ImGui::SetNextWindowBgAlpha(0.0f);
    ImGui::Begin("overlay", nullptr,
        ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoInputs |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoSavedSettings);

    ImDrawList* dl = ImGui::GetWindowDrawList();

    // ESP boxes
    for (auto& ent : entities) {
        Vec2 head, feet;
        if (W2S(ent.headPos, head, vm, sw, sh) &&
            W2S(ent.feetPos, feet, vm, sw, sh)) {
            float h = feet.y - head.y;
            float w = h / 2.5f;
            dl->AddRect(
                {head.x - w/2, head.y},
                {head.x + w/2, feet.y},
                IM_COL32(255, 0, 0, 255), 0, 0, 1.5f
            );
        }
    }

    ImGui::End();
    ImGui::Render();
    ImGui_ImplDX11_RenderDrawData(ImGui::GetDrawData());
    swapChain->Present(1, 0);
}
```

## Bounding Box Calculation (No Bone)

```cpp
// Approximate box from feet position + height
float height = 170.f;  // cm approximation, tune per game
Vec3 headWorld = {feetPos.x, feetPos.y + height, feetPos.z};
Vec2 screenFeet, screenHead;
W2S(feetPos, screenFeet, vm, sw, sh);
W2S(headWorld, screenHead, vm, sw, sh);
float boxH = screenFeet.y - screenHead.y;
float boxW = boxH * 0.4f;
```

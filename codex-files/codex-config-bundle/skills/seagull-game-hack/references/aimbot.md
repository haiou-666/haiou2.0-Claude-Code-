# Aimbot and Aim Assistance

## Angle Calculation

```cpp
#include <cmath>

struct Vec3 { float x, y, z; };
struct Vec2 { float x, y; };  // pitch, yaw in degrees

// Camera position + rotation must come from game memory
// Typically: localPlayer->cameraPos, localPlayer->viewAngles

Vec2 CalcAngle(Vec3 from, Vec3 target) {
    Vec3 delta = { target.x - from.x, target.y - from.y, target.z - from.z };
    float dist = sqrtf(delta.x * delta.x + delta.y * delta.y + delta.z * delta.z);

    Vec2 angles;
    angles.x = -asinf(delta.y / dist) * (180.f / M_PI);   // pitch (vertical)
    angles.y =  atan2f(delta.x, delta.z) * (180.f / M_PI); // yaw  (horizontal)
    return angles;
}

// Normalize angle to [-180, 180]
float NormAngle(float angle) {
    while (angle > 180.f)  angle -= 360.f;
    while (angle < -180.f) angle += 360.f;
    return angle;
}
```

## Smoothing

```cpp
// Linear smoothing (simple, predictable)
Vec2 SmoothLinear(Vec2 current, Vec2 target, float factor) {
    return {
        current.x + (target.x - current.x) / factor,
        current.y + (target.y - current.y) / factor
    };
}

// Bezier curve (more natural arc, harder to detect)
Vec2 BezierSmooth(Vec2 start, Vec2 end, float t, Vec2 control) {
    float inv = 1.f - t;
    return {
        inv*inv*start.x + 2*inv*t*control.x + t*t*end.x,
        inv*inv*start.y + 2*inv*t*control.y + t*t*end.y
    };
}
```

## FOV Filter

```cpp
// Only aim at targets within FOV circle on screen
float GetFOVDistance(Vec2 screenPos, int screenW, int screenH) {
    float cx = screenW / 2.f, cy = screenH / 2.f;
    float dx = screenPos.x - cx, dy = screenPos.y - cy;
    return sqrtf(dx*dx + dy*dy);
}

// Select closest target to crosshair within FOV radius
Entity* SelectTarget(std::vector<Entity>& entities, float fovRadius, Matrix4x4& vm, int sw, int sh) {
    Entity* best = nullptr;
    float bestDist = fovRadius;
    for (auto& e : entities) {
        if (!e.isAlive || e.teamId == localTeam) continue;
        Vec2 screen;
        if (!W2S(e.headPos, screen, vm, sw, sh)) continue;
        float dist = GetFOVDistance(screen, sw, sh);
        if (dist < bestDist) { bestDist = dist; best = &e; }
    }
    return best;
}
```

## Mouse Input

```cpp
// SendInput (most common, easily detected by kernel AC)
void MoveMouse(float dx, float dy) {
    INPUT input = {};
    input.type = INPUT_MOUSE;
    input.mi.dwFlags = MOUSEEVENTF_MOVE;
    input.mi.dx = (LONG)dx;
    input.mi.dy = (LONG)dy;
    SendInput(1, &input, sizeof(INPUT));
}

// Driver-level mouse (bypasses kernel AC hooks on SendInput)
// Requires custom kernel driver or use of existing drivers
// (e.g. interception driver, logitech GHUB trick, etc.)
```

## No-Recoil (Recoil Compensation)

```cpp
// Read recoil angles from game memory
// punchAngle: pitch/yaw added by weapon recoil
// Subtract from view angles each frame

Vec2 viewAngles = RPM<Vec2>(localPlayer + VIEW_ANGLE_OFFSET);
Vec2 punchAngle = RPM<Vec2>(localPlayer + PUNCH_ANGLE_OFFSET);

// Compensate: move mouse to counter recoil
Vec2 delta = {
    (prevPunch.x - punchAngle.x) * 2.f,
    (prevPunch.y - punchAngle.y) * 2.f
};
MoveMouse(delta.y, delta.x);
prevPunch = punchAngle;
```

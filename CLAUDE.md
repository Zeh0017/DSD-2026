# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HarmonyOS mobile application for rehabilitation training. Patients select exercises, connect to IMU sensors, and perform training sessions with real-time joint angle feedback. The app integrates a sensor data acquisition pipeline (S2 module) with a 4-tab UI (M1) and a REST backend (V2).

**Stack:** ArkTS + ArkUI Component V2, HarmonyOS SDK 6.0.2, Hvigor build system. No npm/pip — all dependencies are HarmonyOS system libraries.

## Build & Run

Requires **DevEco Studio 6.0.2+** (HarmonyOS IDE). There is no standalone CLI workflow.

- **Build:** `Build → Build App` in DevEco Studio, or `hvigor build` from the terminal
- **Install on device:** `hdc install <path>.hap`
- **Live logs:** `hdc hilog -T APP` — filter by tag, e.g. `hdc hilog -T APP -t S2DataAcquisition`

ArkTS strict mode is enabled (`caseSensitiveCheck: true`, `useNormalizedOHMUrl: true` in `entry/build-profile.json5`).

## Architecture

```
S1SensorAdapter (mock 30Hz sinusoidal IMU)
    ↓
S2DataAcquisitionService  ← validate, buffer, compute target angles
    ├─ read() every 33ms   → FormatData → RehabilitationService → SessionActivePage (UI)
    └─ uploadToV2() 1Hz    → V2 HTTP backend
```

All services are singletons (`getInstance()`). Events propagate via callbacks registered on `RehabilitationService`: `onSessionStateChange`, `onRealtimeData`, `onAlert`.

**Session state machine:** `idle → connecting → active ⇄ paused → ended → idle`

## Key Files

| Path | Role |
|------|------|
| `entry/src/main/ets/pages/Index.ets` | App entry — 4-tab bottom nav |
| `entry/src/main/ets/pages/rehabilitation/` | Training sub-flow: sensor pairing → setup → active → result |
| `entry/src/main/ets/s2/S2DataModels.ets` | Core data types: `SensorSample`, `FormatData`, `SessionContext`, `ErrorEvent` |
| `entry/src/main/ets/s2/S2DataAcquisitionService.ets` | S2 pipeline (593 lines) — acquisition timers, double-buffering, V2 upload |
| `entry/src/main/ets/s2/S1SensorAdapter.ets` | Mock IMU adapter — swap this for real BLE integration |
| `entry/src/main/ets/service/RehabilitationService.ets` | M1 orchestration (589 lines) — converts `FormatData` → `RealtimeRecognitionResult` for UI |
| `entry/src/main/ets/service/LocalStorageService.ets` | Preferences-based session persistence |
| `entry/src/main/ets/designtoken/` | Design system constants (Color, Space, Size, etc.) |

## Known Issues & Extension Points

**V2 API format mismatch** (not yet resolved with backend team):
- Code sends `sessionID` / `targetAngles`; V2 expects `sessionId` / `measurements`

**Mock data** (markers to find real integration points):
- `[S1-MOCK]` — mock IMU code to replace with real BLE
- `[S1-REAL]` — commented-out stubs for real sensor reads
- `[V2-TODO]` — hardcoded `userId: 1` and empty auth token; local session ID fallback when V2 is unreachable

**V2 upload errors** are async: failures are stored in `v2PendingErrors` inside `S2DataAcquisitionService` and drained on the next `read()` call from M1.

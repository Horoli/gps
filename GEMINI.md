# Project Context: Flight Steps

## Project Overview
**Flight Steps** is a Flutter-based mobile application designed for tracking workflow steps and geolocation, likely for airport or airline operations. It features real-time location tracking (foreground and background), task management, and communication with a backend server via REST APIs.

### Key Technologies
*   **Framework:** Flutter (Dart)
*   **Location Tracking:** `geolocator`, `flutter_foreground_task` (for background execution)
*   **Networking:** `dio` (with cookie management for authentication)
*   **State/Stream Management:** `rxdart` (`BehaviorSubject` for reactive state)
*   **Persistence:** `shared_preferences`

## Architecture & Code Structure

The project follows a Service-oriented architecture with a separation between the UI (Main Isolate) and Background Tasks (Background Isolate).

### Directory Structure
*   `lib/`
    *   `model/`: Data models (prefixed with `M`, e.g., `MUser`, `MConfig`).
    *   `service/`: Singleton business logic classes (prefixed with `Service`, e.g., `ServiceLocation`, `ServiceUser`).
    *   `foreground/`: Logic for background execution (Isolate). **Crucial:** Code here runs in a separate memory space from the main app.
    *   `view/`: UI Screens.
    *   `preset/`: Constants for URLs, Messages, Colors, etc.
    *   `global.dart`: Holds global instances of services (e.g., `GServiceUser`, `GServiceLocation`).
    *   `main.dart`: App entry point and service initialization.

### Core Concepts

1.  **Service Singletons & Globals:**
    *   Services are initialized as singletons and accessed via global variables defined in `lib/global.dart` (e.g., `GServiceWork`, `GServiceLocation`).

2.  **Location Tracking Strategy:**
    *   **Main Isolate (`ServiceLocation`):** Handles location updates when the app is in the foreground/active.
    *   **Background Isolate (`ForegroundTaskHandler`):** Handles location tracking when the app is minimized or the screen is off. It has its own network logic (`Dio`) and configuration fetching because it cannot access the main isolate's memory.
    *   **Offline Support:** `LocationManager` saves location data to local storage when the network is unavailable and syncs it later.

3.  **API Communication:**
    *   Uses `HttpConnector` class (`lib/global.dart`) as a wrapper around `Dio`.
    *   Authentication is cookie-based. `CookieManager` is used to persist and load session cookies.

## Building and Running

*   **Run (Debug):** `flutter run`
*   **Run (Release):** `flutter run --release`
*   **Build APK:** `flutter build apk --release --no-tree-shake-icons`

## Development Conventions

*   **Naming:**
    *   Models: `M{Name}` (e.g., `MUser`)
    *   Services: `Service{Name}` (e.g., `ServiceUser`)
    *   Global Instances: `G{Service}` (e.g., `GServiceUser`)
*   **Location Access:**
    *   **Strict Rule:** Do not use `Geolocator` directly in business logic (like `ServiceWork`). Use `GServiceLocation.ensureCurrentPosition()` or `GServiceLocation.stream` to ensure centralized management and error handling.
*   **Isolate Safety:**
    *   Remember that `lib/foreground/` code cannot access variables in `lib/service/` or `lib/global.dart` directly. Changes to logic (like API URLs or Configuration parsing) often need to be duplicated or shared carefully between `ServiceLocation` and `ForegroundTaskHandler`.

## Output Language
All Output Language : Always respond in Korean (한국어). Even if the user asks in English or the context is technical, provide explanations in Korean unless explicitly requested otherwise.

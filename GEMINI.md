# Project Context: Flight Steps

> **CRITICAL:** 모든 작업을 시작하기 전, 반드시 프로젝트 루트의 [PROJECT_OUTLINE.md](./PROJECT_OUTLINE.md)를 읽고 현재 시스템의 아키텍처, 상태 관리 방식, 그리고 SSE/GPS 관련 핵심 비즈니스 로직을 숙지하십시오.

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

## Recent Updates (2026-03-14)

### 1. UI/UX 레이아웃 및 반응형 디자인 최적화
*   **파일:** `lib/view/work_detail.dart`
*   **내용:** 
    *   기존의 강제 비율 할당(`.flex()`) 방식을 제거하고 콘텐츠 크기에 따른 유동적 높이 할당 방식으로 전환.
    *   중간 가변 영역(작업자 리스트, 특이사항 입력창)에만 `Expanded`를 적용하여 남는 공간을 효율적으로 활용.
    *   작은 해상도 기기에서 아이콘 등이 깨지는 현상을 방지하기 위해 `FittedBox` 적용.
    *   모든 카드 위젯의 너비를 `double.infinity`로 통일하여 시각적 일관성 확보.

### 2. 멀티 디바이스 테스트 환경 구축
*   **패키지:** `device_preview` 추가
*   **내용:** 
    *   `main.dart`와 `app_root.dart`에 `DevicePreview` 설정을 적용하여 앱 실행 중 실시간으로 다양한 기기(Z Flip 5, iPhone SE 등)의 해상도 및 비율 테스트 가능하도록 구축 (Release 모드 자동 비활성화).

### 3. 차량번호 입력 유효성 검사 수정
*   **파일:** `lib/view/create/plate.dart`
*   **내용:** 
    *   차량번호 입력 시 2~4자릿수만 허용하도록 유효성 검사 로직 수정.
    *   안내 메시지를 "차량번호를 2자리 이상으로 입력하세요."로 직관적으로 변경.

### 4. UI 텍스트 중앙 관리 및 용어 통일
*   **파일:** `lib/preset/title.dart`, `lib/view/create/aircraft.dart`, `lib/view/worklist.dart`
*   **내용:** 
    *   기존 '출발시간'으로 표기되던 UI 텍스트를 전문 용어인 'STD'로 일괄 변경.
    *   `TITLE.STD` 상수를 도입하여 `preset/title.dart`에서 중앙 관리할 수 있도록 리팩토링.

## Recent Updates (2026-03-31)

### 1. iOS/Android accuracy 플랫폼 분기 처리
*   **파일:** `lib/service/location.dart`, `lib/foreground/task_handler.dart`
*   **내용:**
    *   `Platform.isIOS` 분기를 추가하여 iOS에서는 `iosAccuracy`, Android에서는 `androidAccuracy` 설정값을 사용하도록 수정.
    *   기존에는 `androidAccuracy`만 사용하여 iOS 설정이 무시되던 문제 해결.

### 2. iOS 백그라운드 위치 추적 지원
*   **파일:** `lib/service/location.dart`, `lib/foreground/task_handler.dart`
*   **내용:**
    *   iOS에서 `AppleSettings`를 사용하도록 `LocationSettings` 플랫폼 분기 처리.
    *   `allowBackgroundLocationUpdates: true`, `showBackgroundLocationIndicator: true` 설정 추가.
    *   Android는 기존 `LocationSettings` 유지.

### 3. iOS 빌드 설정 보완
*   **파일:** `ios/Runner/Info.plist`, `pubspec.yaml`
*   **내용:**
    *   Info.plist에 위치 권한 설명 3종(`NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, `NSLocationAlwaysUsageDescription`) 추가.
    *   `UIBackgroundModes`에 `location`, `fetch` 추가.
    *   `flutter_launcher_icons`에 `remove_alpha_ios: true` 추가.

---

## Recent Updates (2026-03-30)

### 1. MConfig 모델 타입 안전성 개선
*   **파일:** `lib/model/config.dart`
*   **내용:**
    *   `value` 필드를 `dynamic`에서 `String`으로 변경.
    *   `options` 필드를 `dynamic?`에서 `String?`으로 변경.
    *   `fromMap`에서 `toString()`을 사용하여 안전하게 변환.
    *   `copyWith`의 `value` 파라미터 타입을 `bool?`에서 `String?`으로 수정하여 일관성 확보.

### 2. GPS distanceFilter 타입 에러 수정
*   **파일:** `lib/service/location.dart`, `lib/foreground/task_handler.dart`
*   **내용:**
    *   서버에서 `distance` 설정값이 `String`으로 내려와 `LocationSettings.distanceFilter`(`int`)에 전달 시 `_TypeError` 발생하던 버그 수정.
    *   `int.parse(distanceFilter.value.toString())`으로 명시적 변환 적용.

### 3. 디버그 모드 distanceFilter 고정
*   **파일:** `lib/service/location.dart`, `lib/foreground/task_handler.dart`
*   **내용:**
    *   `kDebugMode`일 때 `distanceFilter`를 `1`(미터)로 고정하여 개발 중 GPS 테스트 용이성 확보.
    *   Release 빌드에서는 기존대로 서버 설정값 사용.

### 4. 체크리스트 빈 화면 UI 개선
*   **파일:** `lib/view/checklist.dart`
*   **내용:**
    *   체크리스트가 없을 경우 "작업목록으로 가기" 버튼이 표시되지 않도록 `useToWorkList: false` 적용.

---

## TODO: iOS UX 개선 (우선순위 낮음)

기능적 문제는 없으나, iOS 네이티브 UX에 맞추려면 아래 항목을 플랫폼별 분기 처리 필요.

1.  **Dialog:** 현재 모든 Dialog가 Material `AlertDialog` 사용. iOS에서는 `CupertinoAlertDialog`로 분기 권장.
    *   영향 파일: `lib/service/location.dart`, `lib/view/checklist.dart`, `lib/view/work_detail.dart`, `lib/view/preferences.dart`, `lib/widget/dialog.dart`
2.  **SnackBar:** Material `SnackBar` 사용 중. iOS에서는 Toast/Overlay가 더 자연스러움.
    *   영향 파일: `lib/widget/dialog.dart`, `lib/view/preferences.dart`
3.  **SafeArea:** 일부 화면에서만 적용. 노치/Dynamic Island 대응을 위해 전체 화면에 일관 적용 필요.
    *   영향 파일: `lib/view/work_detail.dart` 등

---

## Output Language
All Output Language : Always respond in Korean (한국어). Even if the user asks in English or the context is technical, provide explanations in Korean unless explicitly requested otherwise.

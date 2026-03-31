# TODO List

## 🛠 Architectural Refactoring

### 1. iOS / Android 위치 추적 인터페이스 단일화 및 업로더 로직 분리 (Location Service Refactoring)
*현재 기기 특성에 따라 안드로이드(Background Isolate)와 iOS(Main Isolate)의 HTTP 전송 로직이 각각 `ForegroundTaskHandler`와 `ServiceLocation.iosBackgroundPost`에 개별적으로 작성(중복)되어 있습니다. 이를 정리하여 유지보수성을 극대화해야 합니다.*

- [ ] **공통 업로더 모듈 (`LocationUploader`) 추출**
  - 흩어져 있는 인터넷 연결 상태 체크, `LocationManager` 로컬 캐싱 확인/저장, 그리고 `Dio`를 이용한 실제 API POST 로직을 `lib/service/location/uploader.dart` (예시)로 완전히 분리해 `static` 클래스로 만듭니다.
  - Isolate 간에는 메모리 공유가 안 되므로 이같이 순수 기능형 `static` 모듈로 만들면 양쪽 어디서든 import하여 100% 동일하게 재사용할 수 있습니다.

- [ ] **`ServiceLocation`을 통합 진입점(Facade)으로 리팩토링**
  - `startTracking()`, `stopTracking()` 같은 단일 추상화 메서드를 만듭니다.
  - 뷰(UI 레이어)에서는 OS 구분 없이 `GServiceLocation.startTracking()`을 호출합니다.
  - 내부 로직에서 `if (Platform.isAndroid)` 이면 `ForegroundTaskHandler.startService()`를 작동시키고, `Platform.isIOS` 이면 메인 스트림 구독 및 `LocationUploader` 호출 라인으로 우회시키는 책임을 집니다.

- [ ] **`ForegroundTaskHandler` 경량화**
  - 내부의 100줄이 넘는 전송 로직 코드를 전부 날리고, 위치 수신 시 `LocationUploader.process(position)` 단 한 줄만 호출하도록 정리합니다.

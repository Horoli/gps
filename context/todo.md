# 프로젝트 TODO 리스트

## 미사용 코드 정리

*   [완료] `lib/service/location.dart` 파일의 `foregroundPost` 메서드: 현재 호출되는 곳이 없으므로, 사용되지 않는 함수입니다. (주석 처리됨)
*   [완료] `lib/service/user.dart` 파일의 `location` 메서드: 현재 호출되는 곳이 없으므로, 사용되지 않는 함수입니다. (주석 처리됨)

위 함수들의 사용 여부를 다시 검토하고, 필요 없으면 삭제하거나 주석 처리하여 코드베이스를 정리해야 합니다.

## 위치 정보 사용 방식 개선 (Refactoring)

현재 여러 서비스 클래스에서 `Geolocator` 패키지를 직접 호출하여 위치 정보를 사용하고 있습니다. 이를 `ServiceLocation`을 통한 중앙 관리 방식으로 일원화해야 합니다.

**1. `ServiceLocation` 기능 보완:**
*   [완료] `GServiceLocation.currentPosition`이 `null`일 경우를 대비하여, 안전하게 위치를 가져오는 메서드(예: `Future<Position> ensureCurrentPosition()`)를 `ServiceLocation` 클래스에 추가했습니다.
    *   로직: 현재 캐시된 위치(`currentPosition`)가 있으면 즉시 반환하고, 없으면 `Geolocator.getCurrentPosition()`을 호출하여 값을 가져와 캐시(`_subject`)를 업데이트한 후 반환.
*   이는 단순 치환 시 발생할 수 있는 초기화 타이밍 이슈나 `null` 참조 에러를 방지하기 위함입니다.

**2. 대상 파일 및 수정 필요 내역 (치환 작업):**
*   **`lib/service/user.dart` (`ServiceUser`):**
    *   `login`, `location` 등의 메서드 호출 전후로 위치 정보가 필요한 경우, `Geolocator` 직접 사용을 지양하고 `ServiceLocation`을 참조하도록 변경 필요. (여기서는 `location` 메서드가 미사용으로 주석 처리되었으므로 직접 `Geolocator`를 사용하는 부분은 없음)
*   [완료] **`lib/service/work/work.dart` (`ServiceWork`):**
    *   `create` 메서드: `Geolocator.getLastKnownPosition()` 및 `Geolocator.getCurrentPosition()` 호출부를 `GServiceLocation.ensureCurrentPosition()` 호출로 변경했습니다.
    *   `shift` 메서드: `Geolocator` 직접 호출부를 `GServiceLocation.ensureCurrentPosition()` 사용으로 변경했습니다.
*   [완료] **`lib/service/work/extra.dart` (`ServiceExtraWork`):**
    *   `Geolocator.getCurrentPosition()` 직접 호출부를 `GServiceLocation.ensureCurrentPosition()` 사용으로 변경했습니다.

**목표:**
모든 위치 정보 접근을 `ServiceLocation`을 통하도록 변경하여, 위치 권한, 스트림 관리, 그리고 에러 처리를 `ServiceLocation` 한 곳에서 담당하게 합니다.

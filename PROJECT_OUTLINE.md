# PROJECT OUTLINE: GPS 기반 실시간 작업 관리 시스템

이 문서는 프로젝트의 아키텍처, 상태 관리 방식, 그리고 핵심 비즈니스 로직을 상세히 기술합니다. 모든 개발 작업 전 이 문서를 숙지해야 합니다.

---

## 1. System Overview (시스템 개요)
- **목적:** 항공기 지상 조업 및 일반 작업의 실시간 진행 상태를 관리하고, 작업자의 GPS 위치를 추적하여 효율적인 자원 배정 및 안전 관리를 지원합니다.
- **핵심 가치:** 데이터 실시간성 보장, 작업 데이터 무결성 유지, 중앙 집중식 위치 정보 관리.

## 2. Technical Stack (기술 스택)
- **Framework:** Flutter (Dart)
- **State Management:** RxDart (BehaviorSubject) 기반의 Service 패턴
- **Networking:** Dio (HTTP/Stream), SSE (Server Sent Events)
- **Architecture:** 싱글톤 서비스 기반 아키텍처 (Service-based Architecture)
- **Utilities:** `unflatten` (중첩 데이터 복원), `CustomNavigator`

## 3. Core Architecture (핵심 아키텍처)

### 3.1 GService 기반 싱글톤 패턴
- 모든 비즈니스 로직은 `lib/service` 내의 서비스 클래스에서 담당합니다.
- 각 서비스는 `GService[Name]` 형태의 전역 게터를 통해 어디서든 접근 가능하며, 싱글톤으로 관리됩니다.
- `CommonService`를 상속받아 공통적인 `dio` 설정 및 기본 통신 로직을 공유합니다.

### 3.2 Reactive 상태 관리
- 각 서비스는 `BehaviorSubject`를 사용하여 상태를 보유합니다.
- UI(View)는 `StreamBuilder`를 통해 서비스의 스트림을 구독하며, 데이터 변경 시 자동으로 리렌더링됩니다.

## 4. Key Workflows & Logic (주요 워크플로우 및 로직)

### 4.1 Route Manager를 통한 상태 생명주기 관리
- `lib/service/route_manager.dart`는 단순한 화면 이동을 넘어 시스템의 상태를 제어하는 '컨트롤 타워' 역할을 합니다.
- **상태 클리닝 (State Cleaning):**
  - 작업 목록(`ROUTE_WORKLIST`)으로 돌아갈 때 `GServiceSSE.disconnect()`를 호출하여 실시간 연결을 끊고 리소스를 확보합니다.
  - `procedureMap`, `selectedUuid` 등 특정 화면에서만 유효한 전역 상태를 초기화하여 데이터 오염을 방지합니다.

### 4.2 실시간 데이터 동기화 (SSE) 및 UUID 필터링
- **SSE 수신 로직:** `ServiceSSE`는 서버로부터 `work.event`를 수신합니다.
- **UUID 필터링 (중요):**
  - 서버는 섹션 내의 모든 이벤트를 브로드캐스팅하므로, 클라이언트 단에서 필터링이 필수적입니다.
  - `_processWorkUpdate`에서 수신된 이벤트의 `uuid`가 현재 활성화된 작업의 `uuid`와 일치할 때만 상태를 업데이트합니다.
  - 이를 통해 사용자가 보고 있지 않은 다른 작업의 데이터가 현재 화면에 반영되는 현상을 방지합니다.

### 4.3 중앙 집중식 위치 정보 관리 (GPS)
- `ServiceLocation`을 통해 모든 위치 정보 접근을 일원화합니다.
- `ensureCurrentPosition()`을 사용하여 위치 권한 및 초기화 타이밍 이슈를 해결하고, 항상 최신 GPS 값을 보장합니다.

## 5. Directory Structure (디렉토리 구조)
- `lib/foreground`: 백그라운드/포그라운드 작업 및 위치 추적 로직.
- `lib/model`: 데이터 모델 및 직렬화.
- `lib/service`: API 통신 및 비즈니스 로직 (SSE 포함).
- `lib/view`: 개별 화면 구성.
- `lib/widget`: 재사용 가능한 UI 컴포넌트.

---

## 6. Development Principles (개발 원칙)
1. **No Direct UI State Mutation:** UI에서 직접 상태를 변경하지 않고 항상 서비스를 통해 업데이트합니다.
2. **SSE Scope Awareness:** 실시간 이벤트가 필요한 화면에서만 연결을 유지하도록 설계합니다.
3. **Data Integrity:** 수신된 모든 외부 데이터는 `uuid` 매칭 등 검증 로직을 거친 후 앱 상태에 반영합니다.

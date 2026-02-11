# 프로젝트 아웃라인 작성을 위한 가이드 프롬프트

이 문서는 프로젝트의 핵심 아키텍처와 작동 방식을 정의하며, AI를 통해 상세 기술 문서를 생성하거나 프로젝트 맥락을 학습시킬 때 사용합니다.

---

## 🚀 Role: 전문 Flutter 아키텍트 및 테크니컬 라이터

## 🎯 Task: 'GPS 기반 실시간 작업 관리 시스템' 기술 명세 및 아웃라인 작성

## 📋 핵심 분석 및 작성 포인트

### 1. 서비스 아키텍처 및 상태 관리
- **패턴:** `GService` 접두사를 사용하는 싱글톤 서비스 아키텍처.
- **상태 관리:** `RxDart`의 `BehaviorSubject`를 활용한 Reactive 프로그래밍.
- **특징:** 모든 서비스는 `CommonService`를 상속받아 일관된 구조(`dio` 인스턴스 공유 등)를 유지.

### 2. Route Manager의 중앙 제어 역할
- **역할:** 화면 이동과 함께 전역 상태의 생명주기(Lifecycle)를 관리.
- **핵심 로직:**
  - `ROUTE_WORKLIST` 진입 시: SSE 연결 해제(`disconnect`), 전역 변수(`procedureMap`) 초기화, 작업 목록 데이터 새로고침(`get`).
  - 단순 네비게이션을 넘어 데이터 무결성을 위한 '상태 클리닝' 허브 역할.

### 3. 실시간 통신 (SSE - Server Sent Events) 시스템
- **연결 전략:** `WorkDetail` 진입 시 활성화, `Worklist` 복귀 시 비활성화하여 리소스 최적화.
- **UUID 필터링 (핵심 보안/정확성):**
  - 서버로부터 수신된 `work.event` 데이터의 `uuid`와 현재 앱이 선택한 `selectedUuid`를 대조.
  - 일치하지 않는 이벤트는 폐기하여 다른 작업의 업데이트가 현재 화면에 반영되는 '데이터 오염' 방지.
- **데이터 복원:** `unflatten` 유틸리티를 통해 평면화된 데이터를 객체 구조로 복원하여 적용.

### 4. 위치 정보(GPS) 관리
- **중앙화:** `ServiceLocation`을 통한 위치 정보 접근 일원화.
- **안전성:** `ensureCurrentPosition()` 메서드를 통해 `null` 방지 및 최신 위치 보장.

### 5. 프로젝트 구성 (Folder Structure)
- `lib/foreground`: 포그라운드 서비스 및 위치 추적 핸들러.
- `lib/model`: 데이터 구조 및 JSON 직렬화 로직.
- `lib/service`: 비즈니스 로직 및 API 통신 (SSE, HTTP).
- `lib/view`: UI 화면 구성 (StreamBuilder 적극 활용).
- `lib/widget`: 공용 컴포넌트 및 다이얼로그.
- `lib/utils`: 네비게이터, 스트림 유틸리티 등.

---

## 📝 출력 요구사항 (Target Structure)
1. **System Overview:** 프로젝트의 목적 및 핵심 가치.
2. **Technical Stack:** 사용된 주요 라이브러리 및 디자인 패턴.
3. **Data Flow Diagram:** SSE 수신부터 UI 렌더링까지의 흐름.
4. **Navigation Policy:** Route Manager를 통한 화면 전환 및 상태 관리 정책.
5. **Critical Logic:** UUID 필터링, GPS 중앙 관리 등 핵심 구현 상세.

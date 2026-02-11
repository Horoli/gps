- 서버는 work.event를 작업 1건 단위(uuid 포함) 로 보냅니다: { uuid, update } (src/server/service/mongo.watch.service.js:120)
- procedure/complete는 현재 코드상 요청한 uuid 1건만 업데이트합니다 (src/server/router/user.js:734)
- 다만 SSE 전송 대상은 “같은 section 사용자 스트림”으로 넓게 잡혀 있어서, A 보고 있어도 B 이벤트를 수신하는 것 자체는 정상입니다 (src/server/service/mongo.watch.service.js:55)
  즉,  
  “A 화면에서 B 진행 시 A 진행률이 올라감”은 모바일 앱이 수신 이벤트를 uuid로 정확히 매칭하지 않고 현재 화면 모델에 덮어쓰는 클라이언트 버그일 가능성이 매우 높습니다.
  모바일에서 바로 확인할 포인트:

1. work.event 수신 시 event.uuid와 현재 화면 work.uuid를 비교하는지
2. 다르면 무시하는지 (if (event.uuid != currentWork.uuid) return)
3. 리스트 렌더 키를 index가 아니라 uuid로 쓰는지
4. patch 적용 로직이 “현재 선택 작업”에 고정 적용되지 않는지

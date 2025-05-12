part of gps_test;

class ViewPreferences extends StatefulWidget {
  const ViewPreferences({super.key});

  @override
  State<ViewPreferences> createState() => ViewPreferencesState();
}

class ViewPreferencesState extends State<ViewPreferences> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: TITLE.PREFERENCES,
        useTrailing: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<MUser?>(
          stream: GServiceUser.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('오류가 발생했습니다: ${snapshot.error}'),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return const Center(
                child: Text('사용자 정보를 불러올 수 없습니다'),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보 섹션
                const Text(
                  '사용자 정보',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // 사용자 이름
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 전화번호
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ID
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.employeeId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 앱 버전
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version =
                        snapshot.hasData ? snapshot.data!.version : '알 수 없음';
                    return Row(
                      children: [
                        const Text(
                          '앱 버전:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          version,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // 하단 여백을 채우는 Spacer
                const Spacer(),

                // 로그아웃 버튼
                buildElevatedButton(
                  usePadding: false,
                  onPressed: () async {
                    logoutPressed(context);
                  },
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> logoutPressed(BuildContext context) async {
    // 로그아웃 확인
    final bool confirm = await buildConfirmDialog();
    // if (!confirm) return;

    if (!confirm) return;

    // 로그아웃 수행
    final bool success = await _performLogout(context);

    // 성공 시 화면 전환
    if (success && context.mounted) {
      await Navigator.of(context).pushNamedAndRemoveUntil(
        PATH.ROUTE_LOGIN,
        (route) => false,
      );
    }
  }

  Future<bool> buildConfirmDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _performLogout(BuildContext context) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('로그아웃 중입니다...'),
        ],
      )),
    );

    try {
      // 1. Foreground Service 종료
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }

      // 2. SSE 연결 종료
      await GServiceSSE.disconnect(ignoreErrors: true);

      // 3. 쿠키 삭제
      await CookieManager.clear();

      // 4. interval 삭제
      // await IntervalManager.clear();

      // 로딩 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return true;
    } catch (e) {
      // 로딩 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 에러 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
        );
      }

      return false;
    }
  }
}

part of gps_test;

class ViewLogin extends StatefulWidget {
  const ViewLogin({super.key});

  @override
  State<ViewLogin> createState() => ViewLoginState();
}

class ViewLoginState extends State<ViewLogin> {
  final TextEditingController _phoneController =
      TextEditingController(text: tmpNumber);
  final TextEditingController _employeeIdController =
      TextEditingController(text: tmpID);

  // final TextEditingController _phoneController =
  //     TextEditingController(text: '01041850688');
  // final TextEditingController _employeeIdController =
  //     TextEditingController(text: 'devel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                TITLE.APP_TITLE,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              buildTextField(
                hint: '',
                title: TITLE.PHONE_NUMBER,
                controller: _phoneController,
              ),
              const SizedBox(height: 20),
              buildTextField(
                hint: '',
                title: TITLE.EMPLOYEE_ID,
                controller: _employeeIdController,
                isNumber: false,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    _handleLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B5EFC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    TITLE.LOGIN,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    _phoneController.text = '01041850688';
                    _employeeIdController.text = 'devel';
                  },
                  child: Text('박선하')),
              ElevatedButton(
                  onPressed: () {
                    _phoneController.text = '01011112222';
                    _employeeIdController.text = '100';
                  },
                  child: Text('홍길동')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String hint,
    required String title,
    required TextEditingController controller,
    bool isNumber = true,
  }) {
    List<TextInputFormatter> textInputFormatter = isNumber
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ]
        : [];
    TextInputType? textInputType = isNumber ? TextInputType.phone : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          keyboardType: textInputType,
          inputFormatters: textInputFormatter,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    checkAndRequestLocationPermission();
  }

  Future<void> checkCookie() async {
    await CookieManager.loadCookies();
  }

  Future<void> _handleLogin() async {
    // 로그인 로직 구현
    String phone = _phoneController.text;
    String employeeId = _employeeIdController.text;

    print('Phone: $phone, Employee ID: $employeeId');
    // TODO: 실제 로그인 처리 로직 추가

    await GServiceUser.login(phoneNumber: phone, id: employeeId).then((user) {
      // TODO : 로그인 성공 시점에 성공한 데이터를 localStorage에 저장
      print('login step 1');

      if (GServiceSSE.connectivitySubscription == null) {
        GServiceSSE.setNetworkListener();
      }

      print('login step 2');
      Navigator.pushReplacementNamed(context, PATH.ROUTE_CHECKLIST);

      // TODO : ViewChecklist로 navigation.replace
      ShowInfomationWidgets.snackbar(context, MSG.LOGIN_SUCCESS);
    }).catchError((e) {
      ShowInfomationWidgets.snackbar(context, MSG.LOGIN_FAILED);
    });
  }

  Future<LocationPermission> checkAndRequestLocationPermission() async {
    // 현재 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 권한이 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      // 사용자에게 설정 화면으로 이동하도록 안내하는 다이얼로그 표시
      bool goToSettings = await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('위치 권한 필요'),
              content: Text('이 앱은 위치 정보가 필요합니다. 설정에서 위치 권한을 허용해주세요.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('설정으로 이동'),
                ),
              ],
            ),
          ) ??
          false;

      // 사용자가 설정으로 이동하기로 선택한 경우
      if (goToSettings) {
        await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
        // 또는 Geolocator.openLocationSettings(); // 위치 설정 페이지 열기
      }
    }
    // 권한이 거부되었지만 영구적으로 거부되지 않은 경우
    else if (permission == LocationPermission.denied) {
      // 권한 요청
      permission = await Geolocator.requestPermission();
    }

    // 권한이 항상 허용되지 않은 경우 (whileInUse 상태인 경우)
    if (permission == LocationPermission.whileInUse) {
      // 항상 허용 권한을 요청하는 다이얼로그 표시
      bool requestAlways = await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('백그라운드 위치 권한'),
              content: Text('앱이 백그라운드에서도 위치 정보를 사용할 수 있도록 허용하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('아니오'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
                  },
                  child: Text('예'),
                ),
              ],
            ),
          ) ??
          false;

      // 사용자가 항상 허용을 선택한 경우
      if (requestAlways) {
        permission = await Geolocator.requestPermission();
      }
    }
    return permission;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }
}

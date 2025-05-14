part of FlightSteps;

class ViewLogin extends StatefulWidget {
  const ViewLogin({super.key});

  @override
  State<ViewLogin> createState() => ViewLoginState();
}

class ViewLoginState extends State<ViewLogin> {
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _employeeIdController =
      TextEditingController();

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
              ElevatedButton(
                  onPressed: () async {
                    debugPrint(
                        'subscription ${GServiceLocation.subscription == null}');
                    debugPrint('hasValue ${GServiceLocation._subject.value}');
                    debugPrint(
                        'location stream last : ${GServiceLocation._subject.valueOrNull}');
                  },
                  child: Text('location')),
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
    GServiceLocation.checkAndRequestLocationPermission();
    checkLocalStorage();
  }

  Future<void> checkLocalStorage() async {
    await UserLoginManager.load().then((Map<String, dynamic> loginData) {
      if (loginData.isNotEmpty) {
        String employeeId = loginData['employeeId'];
        String phoneNumber = loginData['phoneNumber'];
        _phoneController.text = phoneNumber;
        _employeeIdController.text = employeeId;
      }
    }).catchError((e) {
      debugPrint('error: $e');
    });
  }

  // 로그인 로직 구현
  Future<void> _handleLogin() async {
    String employeeId = _employeeIdController.text;
    String phoneNumber = _phoneController.text;

    debugPrint('Phone: $phoneNumber, Employee ID: $employeeId');

    await GServiceUser.login(
      phoneNumber: phoneNumber,
      id: employeeId,
    ).then((user) {
      debugPrint(
          'login step 1 ${GServiceSSE.connectivitySubscription == null}');

      if (GServiceSSE.connectivitySubscription == null) {
        GServiceSSE.setNetworkListener();
      }
      if (GServiceLocation.subscription == null) {
        debugPrint('checkPermission');
        Geolocator.checkPermission();
        debugPrint('setLocationListener');
        GServiceLocation.setLocationListener();
      }

      // 로그인 성공 시점에 성공한 데이터를 localStorage에 저장
      UserLoginManager.save({
        'employeeId': employeeId,
        'phoneNumber': phoneNumber,
      });

      debugPrint('login step 2');
      Navigator.pushReplacementNamed(context, PATH.ROUTE_CHECKLIST);

      // TODO : ViewChecklist로 navigation.replace
      ShowInformationWidgets.snackbar(context, MSG.LOGIN_SUCCESS);
    }).catchError((e) {
      ShowInformationWidgets.snackbar(context, MSG.LOGIN_FAILED);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }
}

part of gps_test;

class ServiceGPSInterval extends CommonService {
  static ServiceGPSInterval? _instance;
  factory ServiceGPSInterval.getInstance() =>
      _instance ??= ServiceGPSInterval._internal();

  ServiceGPSInterval._internal();

  final BehaviorSubject<MConfig?> _subject =
      BehaviorSubject<MConfig?>.seeded(null);

  Stream<MConfig?> get stream => _subject.stream;

  MConfig? get currentUser => _subject.valueOrNull;

  Future<MConfig> gpsInterval() async {
    Completer<MConfig> completer = Completer<MConfig>();

    final Response response = await HttpConnector.get(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.GPS_INTERVAL}',
    );

    if (!completer.isCompleted) {
      List<MConfig> result = List.from(response.data ?? [])
          .map((item) => MConfig.fromMap(item))
          .toList();

      // value의 단위는 seconds(초)
      MConfig intervalResult = result[0];
      int intervalValue = int.parse(intervalResult.value.toString());
      // await IntervalManager.save(intervalValue);

      completer.complete(intervalResult);
    }
    return completer.future;
  }
}

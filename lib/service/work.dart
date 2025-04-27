part of gps_test;

/**
 * selectedWork를 관리하는 service
 */
class ServiceWork extends CommonService {
  static ServiceWork? _instance;
  factory ServiceWork.getInstance() => _instance ??= ServiceWork._internal();

  ServiceWork._internal();

  final BehaviorSubject<MWorkData?> _subject =
      BehaviorSubject<MWorkData?>.seeded(null);

  Stream<MWorkData?> get stream => _subject.stream;

  MWorkData? get selectedWork => _subject.valueOrNull;

  Future<void> select({required MWorkData workData}) async {
    _subject.add(workData);
  }

  Future<void> create() async {}
}

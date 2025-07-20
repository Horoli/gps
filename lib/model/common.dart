part of FlightSteps;

abstract class CommonModel<T> {
  T copyWith() => throw UnimplementedError();

  Map<String, dynamic> toMap() =>
      throw UnimplementedError('toJson() method is not implemented');

  @override
  String toString();
}

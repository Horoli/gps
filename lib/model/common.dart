part of FlightSteps;

abstract class CommonModel<T> {
  T copyWith() => throw UnimplementedError();

  Map<String, dynamic> toJson() =>
      throw UnimplementedError('toJson() method is not implemented');

  @override
  String toString();
}

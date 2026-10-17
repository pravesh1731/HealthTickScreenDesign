/// Thrown when hard-coded content, the config file or a request body does not
/// have the expected shape. Carries a human readable path to the bad field so
/// the problem is easy to locate (e.g. `statuses[1].circleCount`).
class ValidationException implements Exception {
  ValidationException(this.path, this.message);

  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

/// Small typed readers over decoded JSON, so every model parses defensively
/// and reports *where* the data was wrong instead of a bare TypeError.
extension JsonReader on Map<String, dynamic> {
  T read<T>(String key, String path) {
    final value = this[key];
    if (value is T) return value;
    throw ValidationException(
      '$path.$key',
      'expected ${T.toString()} but got ${value?.runtimeType ?? 'nothing'}',
    );
  }

  T? readOptional<T>(String key, String path) {
    final value = this[key];
    if (value == null || value is T) return value as T?;
    throw ValidationException(
      '$path.$key',
      'expected ${T.toString()} but got ${value.runtimeType}',
    );
  }

  Map<String, dynamic> readObject(String key, String path) =>
      read<Map>(key, path).cast<String, dynamic>();

  List<dynamic> readList(String key, String path) => read<List>(key, path);
}

int requireRange(int value, String path, {required int min, required int max}) {
  if (value < min || value > max) {
    throw ValidationException(path, 'must be between $min and $max, got $value');
  }
  return value;
}

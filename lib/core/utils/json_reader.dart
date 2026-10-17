/// Typed, defensive readers over decoded JSON. A wrong type or a missing
/// required field throws a [FormatException] naming the exact path, which the
/// repository turns into a ParsingFailure instead of a red screen.
extension JsonReader on Map<String, dynamic> {
  T require<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw FormatException('Expected "$key" to be $T but got ${value?.runtimeType ?? 'nothing'}');
  }

  T? optional<T>(String key) {
    final value = this[key];
    return value is T ? value : null;
  }

  Map<String, dynamic> object(String key) =>
      require<Map<dynamic, dynamic>>(key).cast<String, dynamic>();

  /// Parses every element of a list, prefixing errors with the item's index.
  List<R> list<R>(String key, R Function(Map<String, dynamic> json) parse) {
    final raw = require<List<dynamic>>(key);
    return [for (final (index, item) in raw.indexed) _parseItem(key, index, item, parse)];
  }

  R _parseItem<R>(String key, int index, Object? item, R Function(Map<String, dynamic>) parse) {
    if (item is! Map) throw FormatException('Expected "$key[$index]" to be an object');
    try {
      return parse(item.cast<String, dynamic>());
    } on FormatException catch (error) {
      throw FormatException('$key[$index]: ${error.message}');
    }
  }
}

/// Reads an enum by name, falling back instead of crashing when the backend
/// adds a value this app version does not know yet.
T enumByName<T extends Enum>(List<T> values, Object? name, {required T fallback}) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

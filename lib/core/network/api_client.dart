/// JSON request/response contract the data sources talk to. Implementations
/// must report every problem as an `ApiException`.
///
/// The app runs against the in-app dummy API; a real HTTP client can replace
/// it in `di/providers.dart` without touching any other code.
abstract interface class ApiClient {
  Future<Map<String, dynamic>> getJson(String path);

  Future<Map<String, dynamic>> postJson(String path);
}

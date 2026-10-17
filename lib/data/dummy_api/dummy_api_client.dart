import 'dart:convert';

import '../../core/network/api_client.dart';
import 'server/dummy_server.dart';

/// [ApiClient] backed by the in-app [DummyServer] instead of HTTP.
///
/// It waits a moment like a real network call, and turns the response into
/// a JSON string and back, so the app's JSON parsing runs exactly as it
/// would with a real server.
class DummyApiClient implements ApiClient {
  DummyApiClient(this._server, {this.delay = const Duration(milliseconds: 300)});

  final DummyServer _server;
  final Duration delay;

  @override
  Future<Map<String, dynamic>> getJson(String path) => _send('GET', path);

  @override
  Future<Map<String, dynamic>> postJson(String path) => _send('POST', path);

  Future<Map<String, dynamic>> _send(String method, String path) async {
    await Future<void>.delayed(delay);
    final response = _server.handle(method, path);
    return jsonDecode(jsonEncode(response)) as Map<String, dynamic>;
  }
}

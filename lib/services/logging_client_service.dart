import 'package:http/http.dart' as http;

class LoggingClient extends http.BaseClient {
  final http.Client _inner;

  LoggingClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('\n🚀 [API REQUEST] -----------------------');
    print('METHOD: ${request.method}');
    print('URL:    ${request.url}');
    print('----------------------------------------\n');

    final stopwatch = Stopwatch()..start();

    try {
      // 2. GỬI REQUEST ĐI
      final response = await _inner.send(request);

      stopwatch.stop();
      print('\n✅ [API RESPONSE] ----------------------');
      print('URL:    ${request.url}');
      print('STATUS: ${response.statusCode}');
      print('TIME:   ${stopwatch.elapsedMilliseconds}ms');
      print('----------------------------------------\n');

      return response;
    } catch (e) {
      print('\n❌ [API ERROR] -------------------------');
      print('URL:    ${request.url}');
      print('ERROR:  $e');
      print('----------------------------------------\n');
      rethrow;
    }
  }
}
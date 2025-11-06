import 'dart:async';

import 'package:dio/dio.dart';
import 'package:evcilhayvanmobil/core/http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthInterceptor', () {
    test('attaches Authorization header to protected pet profile', () async {
      SharedPreferences.setMockInitialValues({'token': 'secure-token'});
      final interceptor = AuthInterceptor();
      final options = RequestOptions(
        path: '/api/pets/me',
        method: 'GET',
        baseUrl: 'http://example.com',
      );
      final handler = _CapturingRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);
      await handler.completer.future;

      expect(
        options.headers['Authorization'],
        equals('Bearer secure-token'),
        reason: 'Protected endpoints should include bearer tokens.',
      );
    });
  });
}

class _CapturingRequestInterceptorHandler extends RequestInterceptorHandler {
  final Completer<RequestOptions> completer = Completer<RequestOptions>();

  @override
  void next(RequestOptions requestOptions) {
    if (!completer.isCompleted) {
      completer.complete(requestOptions);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔗 Sunucu bağlantı adresi
/// Android emulator → 10.0.2.2
/// Web / masaüstü → localhost
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:4000',
);

class HttpClient {
  late final Dio dio;
  static final HttpClient _instance = HttpClient._internal();

  factory HttpClient() => _instance;

  HttpClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(AuthInterceptor());
  }
}

class AuthInterceptor extends Interceptor {
  /// 🔓 Token istemeyen (public) endpoint listesi
  final List<String> _publicPaths = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/verify-email',
    '/api/auth/forgot-password',
    '/api/auth/reset-password',
    '/api/health',
    '/api/pets', // Genel ilan listesi (GET)
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // ✅ 1. Public endpoint’leri kontrol et
    bool isPublic = false;

    // Tam eşleşme varsa
    if (_publicPaths.contains(options.path)) {
      isPublic = true;
    }

    // GET /api/pets/:id gibi dinamik GET rotalarını da public say
    if (options.path.startsWith('/api/pets') && options.method == 'GET') {
      isPublic = true;
    }

    // ✅ 2. Public olmayan istekler için token ekle
    if (!isPublic) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      print('⚠️ [HTTP] Token geçersiz veya süresi dolmuş!');
    }
    return super.onError(err, handler);
  }
}

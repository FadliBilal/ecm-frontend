import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  // GANTI INI SESUAI DEVICE KAMU:
  // Emulator Android: 'http://10.0.2.2:8000/api'
  // HP Fisik: 'http://192.168.1.XX:8000/api' (Cek IP laptop pake ipconfig)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  final _storage = const FlutterSecureStorage();

  ApiClient() {
    // Interceptor: Otomatis tempel Token di setiap request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari brankas
          final token = await _storage.read(key: 'token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle Error Global (Misal: 401 Unauthorized -> Logout paksa)
          if (e.response?.statusCode == 401) {
             // Nanti kita tambah logic logout disini
             debugPrint("Token Expired atau Tidak Valid");
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Getter biar bisa dipanggil dari luar
  Dio get init => _dio;
}
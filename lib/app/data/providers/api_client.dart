import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart'; // Pakai GetStorage
import 'package:flutter/foundation.dart';

class ApiClient {
  // GANTI IP INI SESUAI DEVICE:
  // Emulator: 10.0.2.2
  // HP Fisik: 192.168.1.X
  static const String baseUrl = 'http://10.0.2.2:8000/api'; 

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // HAPUS FlutterSecureStorage, GANTI DENGAN INI:
  final box = GetStorage(); 

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Ambil token dari GetStorage (Sesuai dengan LoginController)
        final token = box.read('token'); 
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("🔑 Token Terlampir: $token"); // Debugging biar yakin
        } else {
          debugPrint("⚠️ Token Kosong (Belum Login)");
        }
        
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
             debugPrint("❌ Error 401: Token Expired / Tidak Valid");
             // Opsional: Redirect ke Login jika token mati
             // Get.offAllNamed('/login');
        }
        return handler.next(e);
      },
    ));
  }

  Dio get init => _dio;
}
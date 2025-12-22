import 'package:dio/dio.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  
  RxBool isLoading = false.obs;
  RxBool isObscure = true.obs;

  Future<void> login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar("Error", "Email dan Password harus diisi", 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.init.post('/login', data: {
        'email': emailC.text,
        'password': passwordC.text,
      });

      if (response.statusCode == 200) {
        // 1. Simpan Token
        String token = response.data['access_token'];
        await _storage.write(key: 'token', value: token);

        // 2. Navigasi ke Home (Hapus riwayat page sebelumnya)
        Get.offAllNamed('/home');
      }
    } on DioException catch (e) {
      String message = "Terjadi kesalahan";
      if (e.response != null) {
         message = e.response?.data['message'] ?? "Cek email/password anda";
      }
      Get.snackbar("Gagal Login", message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
       Get.snackbar("Error", "Gagal koneksi ke server",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
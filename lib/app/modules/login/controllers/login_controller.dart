import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart'; 

class LoginController extends GetxController {
  // --- Dependencies ---
  final ApiClient _apiClient = ApiClient();
  final box = GetStorage();

  // --- Controllers ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // --- State Variables ---
  var isLoading = false.obs;
  var obscureText = true.obs; 

  // --- Actions ---
  void toggleObscure() => obscureText.value = !obscureText.value;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Fungsi utama untuk melakukan Login
  Future<void> login() async {
    // 1. Validasi Input
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Email dan Password tidak boleh kosong", 
        backgroundColor: Colors.orange, 
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // 2. Set Loading State
    isLoading.value = true;

    try {
      // 3. Request ke API
      final response = await _apiClient.init.post('/login', data: {
        'email': emailController.text,
        'password': passwordController.text,
      });

      // 4. Handle Success (200 OK)
      if (response.statusCode == 200) {
        final responseData = response.data;

        // Simpan Session (Token & User Data)
        if (responseData['access_token'] != null) {
          await box.write('token', responseData['access_token']);
        }
        
        if (responseData['data'] != null) {
          await box.write('user', responseData['data']);
        }

        // Feedback User
        Get.snackbar(
          "Login Berhasil", 
          "Selamat datang kembali!", 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          snackPosition: SnackPosition.TOP,
        );
        
        // Navigasi ke Dashboard
        Get.offAllNamed('/dashboard'); 
      } 
      else {
        // Handle unexpected status code
        Get.snackbar("Gagal", "Respon server tidak valid", backgroundColor: Colors.red, colorText: Colors.white);
      }

    } on DioException catch (e) {
      // 5. Handle Dio Error (Koneksi / Salah Password / dll)
      String errorMessage = "Terjadi kesalahan koneksi";
      
      if (e.response != null) {
        // Ambil pesan spesifik dari backend jika ada
        errorMessage = e.response?.data['message'] ?? "Login Gagal";
      }

      Get.snackbar(
        "Gagal", 
        errorMessage, 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
    } catch (e) {
      // 6. Handle System Error
      debugPrint("System Error: $e");
      Get.snackbar(
        "Error", 
        "Terjadi kesalahan pada aplikasi", 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    } finally {
      // 7. Reset Loading State
      isLoading.value = false;
    }
  }
}
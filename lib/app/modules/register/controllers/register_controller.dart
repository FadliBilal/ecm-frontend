import 'package:frontend_ecommerce/app/data/models/location_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class RegisterController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  // Text Controllers buat Form
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final locationSearchC = TextEditingController();

  // Variable buat simpan ID Lokasi yang dipilih (Hidden)
  RxInt selectedLocationId = 0.obs;
  RxBool isLoading = false.obs;

  // 1. Fungsi Cari Lokasi (Dipanggil saat user ngetik)
  Future<List<Location>> searchLocation(String query) async {
    try {
      if (query.length < 3) return [];

      final response = await _apiClient.init.get(
        '/locations', 
        queryParameters: {'search': query}
      );

      if (response.statusCode == 200) {
        List data = response.data as List; 
        return data.map((e) => Location.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("ERROR SEARCH: $e");
      return [];
    }
  }

  // 2. Fungsi Register
  Future<void> register() async {
    // Validasi lokasi wajib diisi
    if (selectedLocationId.value == 0) {
      Get.snackbar("Error", "Pilih lokasi kecamatan dulu!", 
        backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.init.post('/register', data: {
        'name': nameC.text,
        'email': emailC.text,
        'password': passwordC.text,
        'role': 'buyer',
        'location_id': selectedLocationId.value,
        'location_label': locationSearchC.text,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ambil Token
        String token = response.data['access_token'];
        
        // Simpan Token ke HP
        await _storage.write(key: 'token', value: token);
        
        Get.snackbar("Sukses", "Selamat datang ${nameC.text}!",
          backgroundColor: Colors.green, colorText: Colors.white);

        // Kasih delay biar snackbar kebaca
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // 2. Pindah ke Home & Hapus history register (biar gak bisa di-back)
        Get.offAllNamed('/home'); 
      }
    } on DioException catch (e) {
      String message = e.response?.data['message'] ?? "Terjadi kesalahan";
      Get.snackbar("Gagal", message,
        backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
       Get.snackbar("Error", "Terjadi kesalahan sistem",
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
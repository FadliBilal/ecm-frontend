import 'package:frontend_ecommerce/app/data/models/location_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class RegisterController extends GetxController {
  // --- DEPENDENCIES ---
  final ApiClient _apiClient = ApiClient();

  // --- TEXT CONTROLLERS ---
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final locationSearchC = TextEditingController(); 
  final addressC = TextEditingController(); // Input Alamat Lengkap

  // --- STATE VARIABLES ---
  final isLoading = false.obs;
  final obscureText = true.obs;
  
  // Menyimpan ID Lokasi yang dipilih dari TypeAhead
  final selectedLocationId = 0.obs;

  // --- ACTIONS ---
  void toggleObscure() => obscureText.value = !obscureText.value;

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    locationSearchC.dispose();
    addressC.dispose();
    super.onClose();
  }

  /// Fungsi mencari lokasi berdasarkan query user
  /// Dipanggil otomatis oleh widget TypeAheadField
  Future<List<Location>> searchLocation(String query) async {
    if (query.length < 3) return []; 

    try {
      final response = await _apiClient.init.get(
        '/locations', 
        queryParameters: {'search': query} 
      );
      
      if (response.statusCode == 200) {
        List listData = [];
        
        // Handle format respon backend (bisa List langsung atau Object 'data')
        if (response.data is List) {
          listData = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          listData = response.data['data'];
        }
        
        return listData.map((e) => Location.fromJson(e)).toList();
      }
      return [];

    } catch (e) {
      debugPrint("❌ ERROR SEARCH: $e");
      return [];
    }
  }

  /// Fungsi Utama Registrasi
  Future<void> register() async {
    // 1. Validasi Input Kosong
    if (nameC.text.isEmpty || emailC.text.isEmpty || passwordC.text.isEmpty || addressC.text.isEmpty) {
      Get.snackbar(
        "Peringatan", "Semua data diri & alamat lengkap harus diisi", 
        backgroundColor: Colors.orange, colorText: Colors.white,
        snackPosition: SnackPosition.TOP
      );
      return;
    }

    // 2. Validasi Lokasi Belum Dipilih
    if (selectedLocationId.value == 0) {
      Get.snackbar(
        "Peringatan", "Silakan pilih Kecamatan/Kota dari daftar pencarian", 
        backgroundColor: Colors.orange, colorText: Colors.white,
        snackPosition: SnackPosition.TOP
      );
      return;
    }

    isLoading.value = true;

    try {
      // 3. Kirim Data ke Backend
      final response = await _apiClient.init.post('/register', data: {
        'name': nameC.text,
        'email': emailC.text,
        'password': passwordC.text,
        'password_confirmation': passwordC.text, // Wajib untuk Laravel
        'role': 'buyer',
        'location_id': selectedLocationId.value,
        'location_label': locationSearchC.text,
        'full_address': addressC.text,
      });

      // 4. Handle Sukses
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Registrasi Berhasil", "Akun berhasil dibuat! Silakan Login.", 
          backgroundColor: Colors.green, colorText: Colors.white
        );
        
        // Delay sebentar agar user baca notifikasi, lalu pindah
        await Future.delayed(const Duration(seconds: 2));
        Get.offNamed('/login'); 
      }

    } on DioException catch (e) {
      // 5. Handle Error dari Server (Validasi Laravel)
      String message = "Gagal Mendaftar";
      
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data['message'] != null) message = data['message'];
        
        // Ambil error pertama dari object 'errors'
        if (data['errors'] != null) {
           Map<String, dynamic> errors = data['errors'];
           if (errors.isNotEmpty) message = errors.values.first[0];
        }
      }
      
      Get.snackbar("Gagal", message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
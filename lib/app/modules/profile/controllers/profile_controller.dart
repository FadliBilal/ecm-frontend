import 'package:frontend_ecommerce/app/data/models/location_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final ApiClient _apiClient = ApiClient();
  
  final isLoading = false.obs;

  // State User Sesuai Tabel Database
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxInt locationId = 0.obs;
  RxString locationLabel = ''.obs;
  RxString fullAddress = ''.obs;
  RxString phone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Memuat data dari local storage (GetStorage)
  void loadUserData() {
    final user = box.read('user');
    if (user != null) {
      name.value = user['name'] ?? 'User';
      email.value = user['email'] ?? '';
      phone.value = user['phone'] ?? '-';
      fullAddress.value = user['full_address'] ?? 'Belum diatur';
      locationLabel.value = user['location_label'] ?? 'Pilih Lokasi';
      locationId.value = user['location_id'] ?? 0;
    }
  }

  // Fungsi Cari Lokasi (Logic dari RegisterController)
  Future<List<Location>> searchLocation(String query) async {
    if (query.length < 3) return []; 
    try {
      final response = await _apiClient.init.get(
        '/locations', 
        queryParameters: {'search': query}
      );
      
      if (response.statusCode == 200) {
        List listData = [];
        if (response.data is List) {
          listData = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          listData = response.data['data'];
        }
        return listData.map((e) => Location.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ ERROR SEARCH PROFILE: $e");
      return [];
    }
  }

  // Fungsi Update Profile ke Backend
  Future<void> updateProfile({
    required String newName,
    required String newPhone,
    required int newLocId,
    required String newLocLabel,
    required String newFullAddress,
  }) async {
    isLoading.value = true;
    try {
      // Endpoint ini harus disesuaikan dengan backend Anda nantinya
      final response = await _apiClient.init.put('/profile/update', data: {
        'name': newName,
        'phone': newPhone,
        'location_id': newLocId,
        'location_label': newLocLabel,
        'full_address': newFullAddress,
      });

      if (response.statusCode == 200) {
        // 1. Update data di GetStorage (Lokal)
        var user = box.read('user');
        user['name'] = newName;
        user['phone'] = newPhone;
        user['location_id'] = newLocId;
        user['location_label'] = newLocLabel;
        user['full_address'] = newFullAddress;
        box.write('user', user);

        // 2. Refresh UI Profil
        loadUserData();
        
        Get.back(); // Tutup Modal
        Get.snackbar(
          "Sukses", "Profil berhasil diperbarui", 
          backgroundColor: Colors.green, colorText: Colors.white,
          snackPosition: SnackPosition.TOP
        );
      }
    } on DioException catch (e) {
      String message = "Gagal memperbarui profil";
      if (e.response?.data != null && e.response?.data['message'] != null) {
        message = e.response?.data['message'];
      }
      Get.snackbar("Gagal", message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon Logout dengan Background Soft Red
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Konfirmasi Keluar",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Apakah kamu yakin ingin keluar dari akun ini?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Tombol Aksi
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tombol Keluar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Proses hapus data
                        box.remove('token');
                        box.remove('user');
                        // Redirect ke login
                        Get.offAllNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Keluar",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User wajib memilih salah satu tombol
    );
  }
}
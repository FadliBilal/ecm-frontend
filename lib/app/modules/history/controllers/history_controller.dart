import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart'; // Untuk debugPrint & Colors
import 'package:flutter/services.dart'; // Untuk Clipboard
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  RxList orders = [].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.init.get('/orders');
      if (response.statusCode == 200) {
        orders.assignAll(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Buka Link Xendit (Versi Anti-Crash)
  Future<void> payOrder(String url) async {
    if (url.isEmpty) return;
    
    final Uri uri = Uri.parse(url);

    try {
      // Coba buka dengan mode external (Browser)
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Gagal buka link otomatis: $e");
      
      // FALLBACK: Kalau gagal buka browser, kasih opsi copy link
      Get.defaultDialog(
        title: "Gagal Membuka Browser",
        middleText: "Browser tidak merespon. Silakan salin link pembayaran dan buka di Chrome/Browser HP Anda.",
        textConfirm: "Salin Link",
        textCancel: "Tutup",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Clipboard.setData(ClipboardData(text: url));
          Get.back();
          Get.snackbar("Berhasil", "Link disalin! Silakan buka browser.", backgroundColor: Colors.green, colorText: Colors.white);
        }
      );
    }
  }
}
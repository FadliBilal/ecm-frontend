import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:frontend_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:frontend_ecommerce/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final box = GetStorage();
  
  CartController get cartController {
    if (Get.isRegistered<CartController>()) {
      return Get.find<CartController>();
    }
    return Get.put(CartController());
  }

  // State Ongkir
  RxString selectedCourier = ''.obs;
  RxList shippingServices = [].obs;
  RxMap selectedService = {}.obs;
  RxBool isLoadingOngkir = false.obs;

  // --- STATE ALAMAT PENGIRIMAN ---
  RxString recipientName = ''.obs;
  RxString recipientPhone = ''.obs;
  RxString deliveryAddress = ''.obs;

  // Controller Text Editing
  late TextEditingController nameC;
  late TextEditingController phoneC;
  late TextEditingController addressC;

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    phoneC = TextEditingController();
    addressC = TextEditingController();
    loadUserData();
  }

  @override
  void onClose() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    super.onClose();
  }

  void loadUserData() {
    var user = box.read('user'); 
    if (user != null) {
      recipientName.value = user['name'] ?? 'User';
      recipientPhone.value = user['phone'] ?? '08123456789';
      deliveryAddress.value = user['address'] ?? 'Jl. Mulyorejo Kampus C Unair, Surabaya';
    }
  }

  // ✅ FIX: Getter Biaya Ongkir untuk View
  double get shippingCost {
    if (selectedService.isEmpty || selectedService['cost'] == null) return 0;
    return double.tryParse(selectedService['cost'].toString()) ?? 0;
  }

  // ✅ FIX: Getter Total Keseluruhan
  double get grandTotal {
    return cartController.totalPrice + shippingCost;
  }

  // --- FUNGSI TAMPILKAN POPUP UBAH ALAMAT ---
  void showEditAddressDialog() {
    nameC.text = recipientName.value;
    phoneC.text = recipientPhone.value;
    addressC.text = deliveryAddress.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Text("Ubah Alamat Pengiriman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _customTextField(nameC, "Nama Penerima", Icons.person_outline),
              const SizedBox(height: 16),
              _customTextField(phoneC, "Nomor HP", Icons.phone_android_outlined, type: TextInputType.phone),
              const SizedBox(height: 16),
              _customTextField(addressC, "Alamat Lengkap", Icons.home_outlined, lines: 3),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    recipientName.value = nameC.text;
                    recipientPhone.value = phoneC.text;
                    deliveryAddress.value = addressC.text;
                    Get.back();
                    Get.snackbar("Sukses", "Alamat pengiriman diperbarui", 
                      snackPosition: SnackPosition.BOTTOM, 
                      backgroundColor: Colors.green, 
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16)
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(Get.context!).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _customTextField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int lines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> checkOngkir(String courierCode) async {
    selectedCourier.value = courierCode;
    selectedService.clear();
    shippingServices.clear();
    isLoadingOngkir.value = true;

    try {
      final response = await _apiClient.init.post('/check-ongkir', data: {
        'courier': courierCode.toLowerCase(),
        'weight': cartController.totalWeight > 0 ? cartController.totalWeight : 1000,
        'origin': 444, // Surabaya
        'destination': 114, // Contoh Kota Tujuan
      });

      if (response.statusCode == 200) {
        List parsedCosts = [];
        var rawData = response.data;
        if (rawData is List) {
          parsedCosts = rawData;
        } else if (rawData['data'] is List) {
           parsedCosts = rawData['data']; 
        }
        shippingServices.assignAll(parsedCosts);
      }
    } catch (e) {
      Get.snackbar("Gagal", "Gagal memuat ongkir");
    } finally {
      isLoadingOngkir.value = false;
    }
  }

  Future<void> placeOrder() async {
    if (selectedService.isEmpty) {
      Get.snackbar("Peringatan", "Pilih layanan pengiriman dahulu!", 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      var dataKirim = {
        'shipping_service': selectedService['service'],
        'shipping_cost': shippingCost, 
        'total_price': grandTotal,
        'courier': selectedCourier.value, 
        'destination_city_id': 114, 
        'origin_city_id': 444,      
        'payment_method': 'xendit', 
        'address': "${recipientName.value} (${recipientPhone.value}) - ${deliveryAddress.value}", 
        'phone': recipientPhone.value,             
        'postal_code': '60115',
        'notes': 'Penerima: ${recipientName.value}',
      };

      final response = await _apiClient.init.post('/orders', data: dataKirim);
      if (Get.isDialogOpen == true) Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        String paymentUrl = response.data['payment_url'] ?? '';
        cartController.cartItems.clear(); 

        _showSuccessDialog(paymentUrl);
      }
    } on DioException catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      String msg = e.response?.data['message'] ?? "Gagal membuat pesanan";
      Get.snackbar("Gagal", msg, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showSuccessDialog(String paymentUrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("Pesanan Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Silakan selesaikan pembayaran untuk memproses pesanan Anda.", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    Get.back();
                    if (paymentUrl.isNotEmpty) {
                      await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
                    }
                    Get.offAllNamed('/dashboard');
                  },
                  child: const Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/dashboard');
                  if (Get.isRegistered<DashboardController>()) {
                    Get.find<DashboardController>().changeTabIndex(2); // Ke tab history
                  }
                },
                child: const Text("Nanti Saja", style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
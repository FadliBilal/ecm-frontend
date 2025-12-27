import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:frontend_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final box = GetStorage();
  
  // List barang checkout
  RxList checkoutItems = [].obs;

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

  // --- STATE USER & ALAMAT ---
  RxString recipientName = ''.obs;
  RxString recipientPhone = ''.obs;
  RxString deliveryAddress = ''.obs;
  
  // LOGIC MARKETPLACE: 
  // Origin = Kota Seller (Diambil dari Produk)
  // Destination = Kota Buyer (Diambil dari User)
  RxInt originCityId = 0.obs; 
  RxInt destinationCityId = 0.obs;

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
    prepareCheckoutItems();
  }

  @override
  void onClose() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    super.onClose();
  }

  // 1. SIAPKAN BARANG & TENTUKAN ASAL PENGIRIMAN (SELLER)
  void prepareCheckoutItems() {
    final args = Get.arguments;
    if (args != null && args['isDirectBuy'] == true) {
      try {
        var directItem = cartController.cartItems.firstWhere(
          (item) => item['product_id'] == args['productId'],
          orElse: () => null,
        );
        if (directItem != null) checkoutItems.assignAll([directItem]);
      } catch (e) {
        checkoutItems.assignAll(cartController.cartItems);
      }
    } else {
      checkoutItems.assignAll(cartController.cartItems);
    }

    // LOGIC MARKETPLACE: Ambil Origin dari Produk pertama
    // Asumsi: 1x Checkout = 1 Seller. Jika Multi-seller, butuh logic split cart lebih lanjut.
    if (checkoutItems.isNotEmpty) {
      // Pastikan backend kamu mengirim 'city_id' atau 'origin_id' di dalam objek product
      var productData = checkoutItems[0]['product'];
      
      // Coba ambil ID kota seller, jika null default ke Surabaya (Safe fallback)
      originCityId.value = int.tryParse(productData['city_id'].toString()) ?? 
                           int.tryParse(productData['origin_id'].toString()) ?? 444; 
    }
  }

  // 2. LOAD DATA USER & VALIDASI KELENGKAPAN
  void loadUserData() {
    var user = box.read('user'); 
    if (user != null) {
      recipientName.value = user['name'] ?? '';
      recipientPhone.value = user['phone'] ?? ''; // Jangan default dummy, biarkan kosong agar bisa divalidasi
      
      String label = user['location_label'] ?? '';
      String detail = user['full_address'] ?? '';
      
      if (label.isNotEmpty && detail.isNotEmpty) {
        deliveryAddress.value = "$label, $detail";
      } else {
        deliveryAddress.value = detail;
      }
      
      // Ambil ID Kota Buyer
      destinationCityId.value = int.tryParse(user['location_id'].toString()) ?? 0;
    }
  }

  // --- GETTER LOGIC MARKETPLACE ---

  // Hitung Total Berat Real (Gram)
  int get totalWeight {
    int total = 0;
    for (var item in checkoutItems) {
      // Ambil berat dari produk, default 1000g jika null
      int weightPerItem = int.tryParse(item['product']['weight'].toString()) ?? 1000;
      int qty = int.tryParse(item['quantity'].toString()) ?? 1;
      total += (weightPerItem * qty);
    }
    // API Ongkir biasanya menolak berat 0, minimal 1 gram (atau 1000 gram safe limit)
    return total > 0 ? total : 1000;
  }

  double get subtotalPrice {
    double total = 0;
    for (var item in checkoutItems) {
      double price = double.tryParse(item['product']['price'].toString()) ?? 0;
      int qty = int.tryParse(item['quantity'].toString()) ?? 0;
      total += (price * qty);
    }
    return total;
  }

  double get shippingCost {
    if (selectedService.isEmpty || selectedService['cost'] == null) return 0;
    return double.tryParse(selectedService['cost'].toString()) ?? 0;
  }

  double get grandTotal => subtotalPrice + shippingCost;

  // --- VALIDASI DATA USER SEBELUM TRANSAKSI ---
  bool validateUserData() {
    if (recipientPhone.value.isEmpty || recipientPhone.value.length < 5) {
      Get.snackbar(
        "Data Belum Lengkap", 
        "Nomor HP wajib diisi untuk pengiriman!",
        backgroundColor: Colors.red, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => showEditAddressDialog(), 
          child: const Text("Isi Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        )
      );
      // Otomatis buka popup jika mau
      showEditAddressDialog();
      return false;
    }

    if (destinationCityId.value == 0 || deliveryAddress.value.isEmpty) {
      Get.snackbar(
        "Alamat Kosong", 
        "Mohon atur alamat pengiriman terlebih dahulu.",
        backgroundColor: Colors.red, colorText: Colors.white
      );
      showEditAddressDialog();
      return false;
    }
    return true;
  }

  // --- FUNGSI CEK ONGKIR (DINAMIS DARI SELLER KE BUYER) ---
  Future<void> checkOngkir(String courierCode) async {
    // 1. Validasi dulu
    if (!validateUserData()) return;

    selectedCourier.value = courierCode;
    selectedService.clear();
    shippingServices.clear();
    isLoadingOngkir.value = true;

    try {
      final response = await _apiClient.init.post('/check-ongkir', data: {
        'courier': courierCode.toLowerCase(),
        'weight': totalWeight, // Berat Dinamis
        'origin': originCityId.value, // Lokasi Seller
        'destination': destinationCityId.value, // Lokasi Buyer
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
      Get.snackbar("Gagal", "Gagal memuat ongkir. Pastikan alamat seller & buyer valid.");
    } finally {
      isLoadingOngkir.value = false;
    }
  }

  Future<void> placeOrder() async {
    // 1. Validasi lagi sebelum bayar
    if (!validateUserData()) return;

    if (selectedService.isEmpty) {
      Get.snackbar("Peringatan", "Pilih layanan pengiriman dahulu!", 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      var dataKirim = {
        'items': checkoutItems.map((e) => e['id']).toList(),
        'shipping_service': selectedService['service'],
        'shipping_cost': shippingCost, 
        'total_price': grandTotal,
        'courier': selectedCourier.value, 
        'origin_city_id': originCityId.value, // PENTING: Origin Seller
        'destination_city_id': destinationCityId.value, // PENTING: Destination Buyer
        'payment_method': 'xendit', 
        'address': "${recipientName.value} (${recipientPhone.value}) - ${deliveryAddress.value}", 
        'phone': recipientPhone.value,
        'notes': 'Marketplace Order',
      };

      final response = await _apiClient.init.post('/orders', data: dataKirim);
      if (Get.isDialogOpen == true) Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        String paymentUrl = response.data['payment_url'] ?? '';
        await cartController.fetchCart(); 
        _showSuccessDialog(paymentUrl);
      }
    } on DioException catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      String msg = e.response?.data['message'] ?? "Gagal membuat pesanan";
      Get.snackbar("Gagal", msg, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- POPUP UBAH DATA (Updated dengan Validasi HP) ---
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
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              
              const Text("Lengkapi Data Pengiriman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Info jika data kosong
              if (recipientPhone.value.isEmpty || destinationCityId.value == 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text("Mohon isi Nomor HP & Alamat agar ongkir bisa dihitung.", style: TextStyle(fontSize: 12, color: Colors.orange))),
                    ],
                  ),
                ),

              _customTextField(nameC, "Nama Penerima", Icons.person_outline),
              const SizedBox(height: 16),
              
              // Field Nomor HP
              _customTextField(phoneC, "Nomor HP (Wajib)", Icons.phone_android_outlined, type: TextInputType.phone),
              const SizedBox(height: 16),
              
              _customTextField(addressC, "Alamat Lengkap", Icons.home_outlined, lines: 3),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Simpan Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Validasi Sederhana di tombol Simpan
                    if (phoneC.text.isEmpty) {
                      Get.snackbar("Gagal", "Nomor HP tidak boleh kosong", backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    recipientName.value = nameC.text;
                    recipientPhone.value = phoneC.text;
                    deliveryAddress.value = addressC.text;
                    Get.back();
                    Get.snackbar("Sukses", "Data pengiriman diperbarui", backgroundColor: Colors.green, colorText: Colors.white);
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
              const Text("Lakukan pembayaran sekarang?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    Get.back();
                    if (paymentUrl.isNotEmpty) await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
                    Get.offAllNamed('/dashboard');
                  },
                  child: const Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/dashboard');
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
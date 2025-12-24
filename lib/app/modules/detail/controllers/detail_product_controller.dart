import 'package:frontend_ecommerce/app/data/models/product_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:frontend_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class DetailProductController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  late Product product;
  RxBool isLoading = false.obs;
  
  // State Quantity
  RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    // Mengambil data produk dari argumen navigasi
    if (Get.arguments != null && Get.arguments is Product) {
      product = Get.arguments;
    } else {
      Get.back(); // Kembali jika data produk tidak ditemukan
    }
  }

  // Mereset jumlah beli ke 1 setiap kali modal dibuka
  void resetQty() {
    quantity.value = 1;
  }

  // Menambah jumlah beli dengan validasi stok
  void addQty() {
    if (quantity.value < product.stock) {
      quantity.value++;
    } else {
      Get.snackbar(
        "Maksimal Stok", 
        "Stok hanya tersisa ${product.stock}", 
        snackPosition: SnackPosition.BOTTOM, 
        margin: const EdgeInsets.all(16), 
        backgroundColor: Colors.orange, 
        colorText: Colors.white
      );
    }
  }

  // Mengurangi jumlah beli dengan batas minimal 1
  void removeQty() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  // --- FUNGSI EKSEKUSI ORDER / ADD TO CART ---
  Future<void> submitOrder({required bool isDirectBuy}) async {
    // 1. Tutup modal quantity agar tidak menghalangi loading/notifikasi
    if (Get.isBottomSheetOpen == true) Get.back(); 
    
    isLoading.value = true;
    
    try {
      // 2. Kirim data ke API Cart
      final response = await _apiClient.init.post('/cart', data: {
        'product_id': product.id,
        'quantity': quantity.value, 
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        
        // 3. WAJIB: Sinkronisasi data lokal dengan server
        // Kita gunakan await agar CartController selesai mengambil data terbaru 
        // sebelum kita pindah ke halaman Checkout.
        if (Get.isRegistered<CartController>()) {
          await Get.find<CartController>().fetchCart(); 
          debugPrint("♻️ Cart Controller Synchronized");
        }

        if (isDirectBuy) {
          // 4. NAVIGASI KE CHECKOUT (Beli Sekarang)
          // Mengirimkan flag isDirectBuy dan productId sebagai filter di Checkout
          Get.toNamed('/checkout', arguments: {
            'isDirectBuy': true, 
            'productId': product.id
          }); 
        } else {
          // 5. NOTIFIKASI SUKSES (Tambah ke Keranjang)
          Get.snackbar(
            "Sukses", 
            "Produk berhasil ditambahkan ke keranjang", 
            backgroundColor: Colors.green, 
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP
          );
        }
      }
    } on DioException catch (e) {
      // Menangkap pesan error spesifik dari backend jika ada
      String errorMessage = e.response?.data['message'] ?? "Gagal memproses pesanan";
      Get.snackbar("Gagal", errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
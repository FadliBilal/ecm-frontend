import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  RxList cartItems = [].obs;
  RxBool isLoading = false.obs;
  
  // Total Harga (Auto Hitung saat cartItems berubah)
  double get totalPrice => cartItems.fold(0, (sum, item) {
    try {
      double price = double.parse(item['product']['price'].toString());
      int qty = int.parse(item['quantity'].toString());
      return sum + (price * qty);
    } catch (e) {
      return sum;
    }
  });

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    // Loading cuma muncul pas AWAL BUKA HALAMAN saja
    // Saat update qty, loading tidak akan mengganggu user
    if (cartItems.isEmpty) isLoading.value = true;
    
    try {
      final response = await _apiClient.init.get('/cart');
      
      if (response.statusCode == 200) {
        List rawData = [];
        // Deteksi Struktur JSON
        if (response.data['data'] != null && response.data['data']['items'] != null) {
           rawData = response.data['data']['items'];
        } else if (response.data['data'] is List) {
           rawData = response.data['data'];
        }

        cartItems.assignAll(rawData);
      }
    } catch (e) {
      debugPrint("Error cart: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // LOGIC BARU: Optimistic Update (Tanpa Loading Spinner)
  Future<void> updateQty(int cartId, String type) async {
    // 1. Cari posisi item di list memory
    int index = cartItems.indexWhere((item) => item['id'] == cartId);
    if (index == -1) return;

    // 2. Hitung Quantity Baru
    int currentQty = int.parse(cartItems[index]['quantity'].toString());
    int newQty = (type == 'plus') ? currentQty + 1 : currentQty - 1;

    if (newQty < 1) return; // Minimal 1

    // 3. UPDATE UI DULUAN (Biar user merasa cepat)
    // Kita copy map-nya supaya UI sadar ada perubahan
    var tempItem = Map<String, dynamic>.from(cartItems[index]);
    tempItem['quantity'] = newQty;
    cartItems[index] = tempItem; 
    cartItems.refresh(); // PENTING: Trigger UI update manual

    try {
      // 4. Kirim ke Backend (Diam-diam)
      final response = await _apiClient.init.put('/cart/item/$cartId', data: {
        'quantity': newQty
      });
      
      // Kalau ternyata gagal di server, balikin angka ke semula (Rollback)
      if (response.statusCode != 200) {
        tempItem['quantity'] = currentQty;
        cartItems[index] = tempItem;
        cartItems.refresh();
        Get.snackbar("Gagal", "Stok tidak cukup atau error sistem");
      }
    } catch (e) {
      // Revert/Rollback kalau internet mati
      tempItem['quantity'] = currentQty;
      cartItems[index] = tempItem;
      cartItems.refresh();
      debugPrint("Gagal update qty: $e");
    }
  }
}
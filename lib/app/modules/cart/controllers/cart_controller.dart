import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // State Keranjang
  RxList cartItems = [].obs;
  RxBool isLoading = false.obs;
  
  // --- 1. GETTER (AUTO CALCULATE) ---
  
  // Hitung Total Harga (Aman dari error parsing)
  double get totalPrice => cartItems.fold(0, (sum, item) {
    try {
      // Ambil data price & quantity, konversi ke string dulu baru ke double/int
      // Menggunakan tryParse ?? 0 agar jika null/error dianggap 0
      double price = double.tryParse(item['product']['price'].toString()) ?? 0;
      int qty = int.tryParse(item['quantity'].toString()) ?? 0;
      return sum + (price * qty);
    } catch (e) {
      return sum;
    }
  });

  // Hitung Total Berat (Persiapan Ongkir)
  double get totalWeight => cartItems.fold(0, (sum, item) {
    try {
      double weight = double.tryParse(item['product']['weight'].toString()) ?? 0;
      int qty = int.tryParse(item['quantity'].toString()) ?? 0;
      return sum + (weight * qty);
    } catch (e) {
      return sum;
    }
  });

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  // --- 2. FUNGSI AMBIL DATA ---
  
  Future<void> fetchCart() async {
    // Loading hanya muncul jika list kosong (awal buka)
    // Supaya saat refresh background, user tidak terganggu loading
    if (cartItems.isEmpty) isLoading.value = true;
    
    try {
      final response = await _apiClient.init.get('/cart');
      
      if (response.statusCode == 200) {
        List rawData = [];
        
        // Cek Struktur JSON Backend (Jaga-jaga formatnya beda)
        if (response.data['data'] != null && response.data['data'] is Map && response.data['data']['items'] != null) {
           // Format: { data: { items: [...] } }
           rawData = response.data['data']['items'];
        } else if (response.data['data'] is List) {
           // Format: { data: [...] }
           rawData = response.data['data'];
        }

        cartItems.assignAll(rawData);
      }
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 3. FUNGSI UPDATE QTY (OPTIMISTIC) ---
  
  Future<void> updateQty(int cartId, String type) async {
    // Cari index barang di list memory
    int index = cartItems.indexWhere((item) => item['id'] == cartId);
    if (index == -1) return;

    // Hitung Qty Baru
    int currentQty = int.parse(cartItems[index]['quantity'].toString());
    int newQty = (type == 'plus') ? currentQty + 1 : currentQty - 1;

    if (newQty < 1) return; // Minimal 1, tidak boleh 0 atau negatif

    // --- LOGIC OPTIMISTIC UPDATE ---
    // Update UI duluan sebelum request ke server selesai
    var tempItem = Map<String, dynamic>.from(cartItems[index]);
    tempItem['quantity'] = newQty;
    cartItems[index] = tempItem; 
    cartItems.refresh(); // Trigger update tampilan total harga

    try {
      // Kirim request ke backend (background process)
      final response = await _apiClient.init.put('/cart/item/$cartId', data: {'quantity': newQty});
      
      // Jika Backend Gagal/Error
      if (response.statusCode != 200) {
        // Rollback (Balikin angka ke semula)
        tempItem['quantity'] = currentQty;
        cartItems[index] = tempItem;
        cartItems.refresh();
        Get.snackbar("Gagal", "Stok tidak cukup atau terjadi kesalahan", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      // Rollback jika koneksi putus
      tempItem['quantity'] = currentQty;
      cartItems[index] = tempItem;
      cartItems.refresh();
      debugPrint("Gagal update qty: $e");
    }
  }

  // --- 4. FUNGSI HAPUS ITEM (OPTIMISTIC) ---
  
  Future<void> deleteItem(int cartId) async {
    // Cari barangnya dulu buat cadangan (Undo)
    var itemToDelete = cartItems.firstWhereOrNull((item) => item['id'] == cartId);
    if (itemToDelete == null) return;
    
    int deletedIndex = cartItems.indexOf(itemToDelete);

    // Hapus dari UI duluan
    cartItems.removeAt(deletedIndex);
    
    try {
      // Hapus di Backend
      await _apiClient.init.delete('/cart/item/$cartId');
      
      Get.snackbar(
        "Dihapus", "Barang berhasil dihapus",
        snackPosition: SnackPosition.BOTTOM, 
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        mainButton: TextButton(
          onPressed: () {
            // Logic UNDO Sederhana: Refresh ulang dari server
            fetchCart(); 
          }, 
          child: const Text("Undo", style: TextStyle(color: Colors.white)),
        ),
      );
      
    } catch (e) {
      // Kembalikan item jika gagal hapus (Rollback)
      cartItems.insert(deletedIndex, itemToDelete);
      Get.snackbar("Error", "Gagal menghapus barang, coba lagi.", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
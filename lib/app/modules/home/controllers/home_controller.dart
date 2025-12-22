import 'package:frontend_ecommerce/app/data/models/product_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class HomeController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // State
  RxList<Product> products = <Product>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts(); // Otomatis panggil saat halaman dibuka
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      debugPrint("Fetching products..."); // Debug 1
      final response = await _apiClient.init.get('/products');
      
      debugPrint("STATUS CODE: ${response.statusCode}"); // Debug 2
      debugPrint("RAW DATA: ${response.data}"); // Debug 3: LIHAT INI DI TERMINAL

      if (response.statusCode == 200) {
        List rawData = [];

        // --- LOGIC DETEKSI OTOMATIS STRUKTUR JSON ---
        
        // KEMUNGKINAN A: Data langsung List [ {...}, {...} ]
        if (response.data is List) {
          rawData = response.data;
        } 
        // KEMUNGKINAN B: Dibungkus 'data' { "data": [...] } (Laravel Resource Default)
        else if (response.data['data'] != null && response.data['data'] is List) {
          rawData = response.data['data'];
        }
        // KEMUNGKINAN C: Pagination { "data": { "data": [...] } }
        else if (response.data['data'] != null && response.data['data']['data'] != null) {
          rawData = response.data['data']['data'];
        }

        debugPrint("Jumlah Produk Ditemukan: ${rawData.length}");

        products.value = rawData.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("ERROR FETCH PRODUCT: $e");
      
      // Kalau errornya parsing int/string, biasanya muncul detailnya disini
    } finally {
      isLoading.value = false;
    }
  }
}
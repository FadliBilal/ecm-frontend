import 'package:frontend_ecommerce/app/data/models/product_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Import GetStorage

class HomeController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final box = GetStorage(); // Akses penyimpanan
  
  // --- STATE ---
  RxList<Product> products = <Product>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentBannerIndex = 0.obs;

  // Data User
  RxString userName = "Juragan".obs;
  RxString totalPengeluaran = "Rp 0".obs; // Nanti bisa diganti data real dari API

  // Banner Images (Placeholder yang aman)
  final List<String> bannerImages = [
    'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchProducts();
  }

  void loadUserData() {
    // Ambil data user yang disimpan saat Login
    var user = box.read('user');
    if (user != null && user['name'] != null) {
      userName.value = user['name'];
    }
    // Disini nanti bisa panggil API cek total belanja jika ada
  }

  void changeBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  Future<void> refreshData() async {
    await fetchProducts();
    loadUserData();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.init.get('/products');
      
      if (response.statusCode == 200) {
        List rawData = [];
        // Logika parsing JSON yang fleksibel
        if (response.data is List) {
          rawData = response.data;
        } else if (response.data['data'] != null) {
          if (response.data['data'] is List) {
             rawData = response.data['data'];
          } else if (response.data['data']['data'] != null) {
             rawData = response.data['data']['data'];
          }
        }
        products.value = rawData.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("ERROR FETCH PRODUCT: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
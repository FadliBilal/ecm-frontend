import 'package:frontend_ecommerce/app/data/models/product_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final box = GetStorage();
  
  // --- STATE UI ---
  RxBool isLoading = false.obs;
  RxInt currentBannerIndex = 0.obs;

  // --- STATE DATA PRODUK ---
  RxList<Product> products = <Product>[].obs; 
  List<Product> allProducts = []; 

  // --- CONTROLLER SEARCH ---
  TextEditingController searchC = TextEditingController();

  // Data User
  RxString userName = "Juragan".obs;
  RxString totalPengeluaran = "Rp 0".obs;

  // Banner Images
  final List<String> bannerImages = [
    'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchProducts();
  }

  @override
  void onClose() {
    searchC.dispose(); 
    super.onClose();
  }

  void loadUserData() {
    var user = box.read('user');
    if (user != null && user['name'] != null) {
      userName.value = user['name'];
    }
  }

  void changeBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  Future<void> refreshData() async {
    searchC.clear(); 
    await fetchProducts();
    loadUserData();
  }

  // --- LOGIKA FETCH DATA ---
  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.init.get('/products');
      
      if (response.statusCode == 200) {
        List rawData = [];
        
        if (response.data is List) {
          rawData = response.data;
        } else if (response.data['data'] != null) {
          if (response.data['data'] is List) {
             rawData = response.data['data'];
          } else if (response.data['data']['data'] != null) {
             rawData = response.data['data']['data'];
          }
        }
        
        List<Product> parsedData = rawData.map((e) => Product.fromJson(e)).toList();

        allProducts = parsedData; 
        products.assignAll(parsedData); 
      }
    } catch (e) {
      debugPrint("ERROR FETCH PRODUCT: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA PENCARIAN (FILTER) ---
  void filterProducts(String query) {
    if (query.isEmpty) {
      products.assignAll(allProducts);
    } else {
      var filtered = allProducts.where((p) {
        var name = p.name.toLowerCase(); 
        return name.contains(query.toLowerCase());
      }).toList();
      
      products.assignAll(filtered);
    }
  }
}
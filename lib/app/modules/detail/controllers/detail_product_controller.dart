import 'package:frontend_ecommerce/app/data/models/product_model.dart';
import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class DetailProductController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // Data produk dilempar dari Home via Arguments
  late Product product;
  
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data yang dikirim dari Home
    if (Get.arguments != null) {
      product = Get.arguments;
    }
  }

  Future<void> addToCart() async {
    isLoading.value = true;
    try {
      // Hit endpoint POST /cart
      final response = await _apiClient.init.post('/cart', data: {
        'product_id': product.id,
        'quantity': 1, // Default beli 1 dulu
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Berhasil", 
          "${product.name} masuk keranjang!",
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      }
    } on DioException catch (e) {
      Get.snackbar("Gagal", e.response?.data['message'] ?? "Gagal masuk keranjang",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
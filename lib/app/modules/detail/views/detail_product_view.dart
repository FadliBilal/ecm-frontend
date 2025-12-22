import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/detail/controllers/detail_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailProductView extends StatelessWidget {
  const DetailProductView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(DetailProductController());
    final product = controller.product;
    
    // Formatter Rupiah
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // 1. AREA SCROLLABLE (Gambar & Deskripsi)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Gambar (Stack biar ada tombol back di atasnya)
                  Stack(
                    children: [
                      Image.network(
                        product.fullImageUrl,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Container(height: 300, color: Colors.grey[200]),
                      ),
                      Positioned(
                        top: 40,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Harga
                        Text(
                          currencyFormatter.format(product.price),
                          style: const TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.primary
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Nama Produk
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Deskripsi Section
                        const Text("Deskripsi Produk", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: const TextStyle(color: AppColors.textGrey, height: 1.5),
                        ),
                        
                        const SizedBox(height: 20),
                        // Info Tambahan (Berat/Stok)
                        Row(
                          children: [
                            const Icon(Icons.scale, size: 16, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text("${product.weight} gram", style: const TextStyle(color: AppColors.textGrey)),
                            const SizedBox(width: 16),
                            const Icon(Icons.inventory_2, size: 16, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Text("Stok: ${product.stock}", style: const TextStyle(color: AppColors.textGrey)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BOTTOM BAR (Tombol Beli)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), 
                  blurRadius: 10, 
                  offset: const Offset(0, -5)
                )
              ],
            ),
            child: SafeArea(
              child: Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.addToCart(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Tambah ke Keranjang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
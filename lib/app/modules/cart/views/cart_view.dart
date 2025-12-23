import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Saya"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.cartItems.isEmpty) {
          return const Center(child: Text("Keranjang masih kosong nih"));
        }

        return Column(
          children: [
            // 1. LIST ITEM
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  final product = item['product'];
                  
                  // Helper URL Gambar
                  String imageUrl = "https://placehold.co/100x100/png";
                  if (product['image'] != null) {
                      // Pastikan IP 10.0.2.2 jika pakai Emulator Android
                      imageUrl = "http://10.0.2.2:8000/storage/${product['image']}";
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // --- PERBAIKAN: GAMBAR DENGAN ERROR HANDLER ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl, 
                            width: 80, 
                            height: 80, 
                            fit: BoxFit.cover,
                            // Mencegah crash jika koneksi putus / gambar tidak ada
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        // ---------------------------------------------
                        const SizedBox(width: 12),
                        
                        // Info Produk (Sudah ada Expanded, Aman dari Overflow)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product['name'], 
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2, // Ubah jadi 2 baris biar lebih lega
                                overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormatter.format(double.tryParse(product['price'].toString()) ?? 0), 
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),

                        // Tombol Plus Minus
                        Row(
                          children: [
                            _qtyButton(Icons.remove, () {
                              controller.updateQty(item['id'], 'minus'); 
                            }),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(item['quantity'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),

                            _qtyButton(Icons.add, () {
                              controller.updateQty(item['id'], 'plus'); 
                            }),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            // 2. BOTTOM BAR (Total & Checkout)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Bayar:", style: TextStyle(fontSize: 16)),
                        Text(
                          currencyFormatter.format(controller.totalPrice),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/checkout');
                        },
                        child: const Text("Checkout Sekarang"),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/detail/controllers/detail_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailProductView extends GetView<DetailProductController> {
  const DetailProductView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetailProductController>()) {
      Get.put(DetailProductController());
    }

    final product = controller.product;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: Image.network(
                      // FIX: Menghapus null-aware karena fullImageUrl non-nullable
                      _fixImageUrl(product.fullImageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currencyFormatter.format(product.price),
                                style: GoogleFonts.poppins(
                                  fontSize: 26, 
                                  fontWeight: FontWeight.w800, 
                                  color: AppColors.primary
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Stok: ${product.stock}",
                                  style: const TextStyle(
                                    color: Colors.green, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20, 
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.3
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                          ),
                          const Text(
                            "Deskripsi Produk",
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w700,
                              color: Colors.black87
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            // FIX: Menghapus null-aware jika model description non-nullable
                            product.description,
                            style: TextStyle(
                              color: Colors.grey[700], 
                              height: 1.7,
                              fontSize: 14
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          // BOTTOM BAR
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () => _showQuantityModal(context, isDirectBuy: false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: () => _showQuantityModal(context, isDirectBuy: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      "Beli Sekarang",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityModal(BuildContext context, {required bool isDirectBuy}) {
    controller.resetQty(); 
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    // FIX: Menghapus null-aware
                    _fixImageUrl(controller.product.fullImageUrl),
                    width: 80, height: 80, fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormatter.format(controller.product.price),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text("Stok tersedia: ${controller.product.stock}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tentukan Jumlah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => controller.removeQty(),
                        icon: const Icon(Icons.remove, size: 20, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Obx(() => Text(
                          "${controller.quantity.value}", 
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)
                        )),
                      ),
                      IconButton(
                        onPressed: () => controller.addQty(),
                        icon: const Icon(Icons.add, size: 20, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.submitOrder(isDirectBuy: isDirectBuy),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: controller.isLoading.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      isDirectBuy ? "Lanjut ke Pembayaran" : "Tambahkan ke Keranjang",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
              )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _fixImageUrl(String url) {
    if (url.isEmpty) return "https://placehold.co/600x600/png?text=No+Image";
    if (url.startsWith('http')) {
      if (url.contains('localhost') || url.contains('127.0.0.1')) {
        return url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
      }
      return url;
    }
    return "http://10.0.2.2:8000/storage/$url";
  }
}
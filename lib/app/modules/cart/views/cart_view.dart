import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:frontend_ecommerce/app/modules/dashboard/controllers/dashboard_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ter-inject
    Get.put(CartController());
    
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text(
          "Keranjang Saya", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        // LOGIKA CERDAS TOMBOL KEMBALI
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back(); // Jika dibuka via Get.to (dari Home icon)
            } else {
              // Jika dibuka via Bottom Nav, balikkan tab Dashboard ke Home (Index 0)
              final dashController = Get.find<DashboardController>();
              dashController.changeTabIndex(0);
            }
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.cartItems.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            // 1. LIST ITEM
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => await controller.fetchCart(),
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    final product = item['product'];
                    
                    return _buildCartItem(item, product, currencyFormatter);
                  },
                ),
              ),
            ),

            // 2. BOTTOM BAR
            _buildBottomSummary(currencyFormatter),
          ],
        );
      }),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[300]),
            ),
            const SizedBox(height: 24),
            const Text(
              "Keranjangmu Kosong", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)
            ),
            const SizedBox(height: 12),
            Text(
              "Sepertinya kamu belum menambahkan barang apapun ke keranjang.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // LOGIKA CERDAS TOMBOL MULAI BELANJA
                  if (Navigator.canPop(context)) {
                    Get.back();
                  } else {
                    final dashController = Get.find<DashboardController>();
                    dashController.changeTabIndex(0);
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Mulai Belanja", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map item, Map product, NumberFormat formatter) {
    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => controller.deleteItem(item['id']),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _fixImageUrl(product['full_image_url'] ?? product['image']), 
                width: 90, height: 90, fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 90, height: 90, color: Colors.grey[100],
                  child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'], 
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87),
                    maxLines: 2, overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(double.tryParse(product['price'].toString()) ?? 0), 
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            _qtyButton(Icons.remove, () => controller.updateQty(item['id'], 'minus')),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                item['quantity'].toString(), 
                                style: const TextStyle(fontWeight: FontWeight.w800)
                              ),
                            ),
                            _qtyButton(Icons.add, () => controller.updateQty(item['id'], 'plus'), isAdd: true),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.deleteItem(item['id']),
                        icon: Icon(Icons.delete_outline_rounded, size: 22, color: Colors.red[300]),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06), 
            blurRadius: 20, 
            offset: const Offset(0, -5)
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pembayaran", 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)
                ),
                Text(
                  formatter.format(controller.totalPrice),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Checkout Sekarang", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon, 
          size: 18, 
          color: isAdd ? AppColors.primary : Colors.grey[600]
        ),
      ),
    );
  }

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "https://placehold.co/200x200/png?text=No+Image";
    if (url.startsWith('http')) {
      if (url.contains('localhost') || url.contains('127.0.0.1')) {
        return url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
      }
      return url;
    }
    return "http://10.0.2.2:8000/storage/$url";
  }
}
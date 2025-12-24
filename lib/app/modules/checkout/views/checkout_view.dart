import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CheckoutController());
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang soft grey
      appBar: AppBar(
        title: const Text("Pengiriman", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ALAMAT PENGIRIMAN
                  _buildSectionHeader("Alamat Pengiriman", onAction: () => controller.showEditAddressDialog()),
                  _buildAddressCard(),
                  
                  const SizedBox(height: 32),

                  // 2. DAFTAR PESANAN
                  _buildSectionHeader("Daftar Pesanan"),
                  _buildOrderSummaryCard(currencyFormatter),

                  const SizedBox(height: 32),

                  // 3. PILIH KURIR
                  _buildSectionHeader("Pilih Kurir"),
                  _buildCourierSelector(),

                  const SizedBox(height: 20),

                  // 4. HASIL LAYANAN ONGKIR
                  _buildShippingServices(currencyFormatter),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 5. BOTTOM SUMMARY BAR
          _buildBottomAction(currencyFormatter),
        ],
      ),
    );
  }

  // --- PRIVATE WIDGET COMPONENTS ---

  Widget _buildSectionHeader(String title, {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              child: const Text("Ubah", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Obx(() => Text(
                controller.recipientName.value,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              )),
            ],
          ),
          const SizedBox(height: 6),
          Obx(() => Text(
            controller.recipientPhone.value,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          )),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          Obx(() => Text(
            controller.deliveryAddress.value,
            style: const TextStyle(height: 1.5, color: Colors.black87, fontSize: 14),
          )),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() {
        if (controller.cartController.cartItems.isEmpty) {
          return const Center(child: Text("Memuat pesanan..."));
        }
        return Column(
          children: [
            ...controller.cartController.cartItems.take(2).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _fixImageUrl(item['product']['full_image_url'] ?? item['product']['image']),
                        width: 64, height: 64, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['product']['name'] ?? 'Produk', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            "${item['quantity']} barang • ${formatter.format(double.tryParse(item['product']['price'].toString()) ?? 0)}",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
            if (controller.cartController.cartItems.length > 2)
              Text("+${controller.cartController.cartItems.length - 2} produk lainnya", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        );
      }),
    );
  }

  Widget _buildCourierSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: ['jne', 'pos', 'tiki'].map((courier) {
          return Expanded(
            child: Obx(() {
              bool isSelected = controller.selectedCourier.value == courier;
              return GestureDetector(
                onTap: () => controller.checkOngkir(courier),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      courier.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShippingServices(NumberFormat formatter) {
    return Obx(() {
      if (controller.isLoadingOngkir.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
      }
      if (controller.selectedCourier.isNotEmpty && controller.shippingServices.isEmpty) {
        return _buildErrorState("Layanan tidak tersedia di wilayah Anda");
      }

      return Column(
        children: controller.shippingServices.map((service) {
          bool isSelected = controller.selectedService['service'] == service['service'];
          return GestureDetector(
            onTap: () => controller.selectedService.assignAll(service),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: isSelected ? AppColors.primary : Colors.grey.shade300),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service['service'] ?? 'Layanan', style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text("Estimasi tiba ${service['etd'] ?? '-'} hari", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Text(formatter.format(double.tryParse(service['cost'].toString()) ?? 0), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildBottomAction(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow("Subtotal Produk", formatter.format(controller.cartController.totalPrice)),
            const SizedBox(height: 8),
            Obx(() => _buildPriceRow("Biaya Pengiriman", formatter.format(controller.shippingCost))),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pembayaran", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Obx(() => Text(formatter.format(controller.grandTotal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.placeOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Bayar Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildErrorState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
      child: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "https://placehold.co/100x100/png?text=No+Image";
    if (url.startsWith('http')) {
      if (url.contains('localhost') || url.contains('127.0.0.1')) {
        return url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
      }
      return url;
    }
    return "http://10.0.2.2:8000/storage/$url";
  }
}
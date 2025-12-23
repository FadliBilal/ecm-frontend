import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Pengiriman & Pembayaran")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. INFO ALAMAT (Statis dulu atau ambil dari user)
                  const Text("Alamat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: const Text("Alamat sesuai profil (Surabaya, Jawa Timur)"), // Nanti bisa dibikin dinamis
                  ),
                  
                  const SizedBox(height: 24),

                  // 2. PILIH KURIR
                  const Text("Pilih Kurir", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: ['jne', 'pos', 'tiki'].map((courier) {
                      return Obx(() => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(courier.toUpperCase()),
                          selected: controller.selectedCourier.value == courier,
                          onSelected: (selected) {
                            if (selected) controller.checkOngkir(courier);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: controller.selectedCourier.value == courier ? Colors.white : Colors.black),
                        ),
                      ));
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // 3. LIST PAKET ONGKIR (Hasil dari API)
                  Obx(() {
                    if (controller.isLoadingOngkir.value) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    
                    if (controller.shippingServices.isEmpty && controller.selectedCourier.isNotEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("Tidak ada layanan tersedia."),
                      );
                    }

                    return Column(
                      children: controller.shippingServices.map((service) {
                        final cost = double.parse(service['cost'][0]['value'].toString());
                        final etd = service['cost'][0]['etd'] ?? '-';
                        
                        // Cek apakah item ini dipilih
                        bool isSelected = controller.selectedService == service;

                        return GestureDetector(
                          onTap: () {
                            controller.selectedService.value = service;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${service['service']} (${service['description']})", 
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text("Estimasi: $etd hari", 
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormatter.format(cost), 
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: AppColors.primary,
                                    fontSize: 16
                                  )
                                ),
                                const SizedBox(width: 12),
                                // Icon Checkmark kalau dipilih
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? AppColors.primary : Colors.grey,
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 4. BOTTOM BAR (Rincian & Bayar)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildSummaryRow("Subtotal Produk", currencyFormatter.format(controller.cartController.totalPrice)),
                  const SizedBox(height: 8),
                  Obx(() {
                     double ongkir = 0;
                     if (controller.selectedService.isNotEmpty) {
                       ongkir = double.parse(controller.selectedService['cost'][0]['value'].toString());
                     }
                     return _buildSummaryRow("Ongkos Kirim", currencyFormatter.format(ongkir));
                  }),
                  const Divider(height: 24),
                  Obx(() => _buildSummaryRow("Total Tagihan", currencyFormatter.format(controller.grandTotal), isTotal: true)),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.placeOrder(),
                      child: const Text("Bayar Sekarang"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? AppColors.primary : Colors.black)),
      ],
    );
  }
}
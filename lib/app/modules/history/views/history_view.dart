import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/history/controllers/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pesanan")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          // Kita bungkus Stack/ListView agar halaman kosong pun bisa di-refresh
          return RefreshIndicator(
            onRefresh: () async => await controller.fetchOrders(),
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text("Belum ada pesanan")),
              ],
            ),
          );
        }

        // --- FITUR UTAMA: REFRESH INDICATOR ---
        return RefreshIndicator(
          onRefresh: () async {
            // Panggil fungsi ini untuk cek status terbaru ke Xendit
            await controller.fetchOrders();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            // Tambahkan physics ini agar bisa ditarik walau item sedikit
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              final status = order['status'] ?? 'PENDING';
              
              // Parsing aman untuk harga
              final total = double.tryParse(order['total_price'].toString()) ?? 0;
              final paymentUrl = order['xendit_invoice_url'];

              // Tentukan Warna Status
              Color statusColor;
              Color statusBgColor;

              switch (status) {
                case 'PAID':
                case 'SETTLED':
                  statusColor = Colors.green;
                  statusBgColor = Colors.green.shade100;
                  break;
                case 'EXPIRED':
                  statusColor = Colors.red;
                  statusBgColor = Colors.red.shade100;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusBgColor = Colors.orange.shade100;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order['order_number'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(status, style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          )),
                        )
                      ],
                    ),
                    const Divider(),
                    Text("Total: ${currencyFormatter.format(total)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Kurir: ${order['courier'].toString().toUpperCase()} - ${order['shipping_service']}"),
                    const SizedBox(height: 12),
                    
                    // Tombol Bayar (Hanya muncul jika PENDING dan ada Link)
                    if (status == 'PENDING' && paymentUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => controller.payOrder(paymentUrl),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text("Bayar Sekarang"),
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
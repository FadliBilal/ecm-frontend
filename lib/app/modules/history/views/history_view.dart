import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/history/controllers/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan find jika sudah di-inject via binding, atau put jika belum
    final controller = Get.isRegistered<HistoryController>() 
        ? Get.find<HistoryController>() 
        : Get.put(HistoryController());
        
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.orders.isEmpty) {
          return _buildEmptyState(controller);
        }

        return RefreshIndicator(
          onRefresh: () async => await controller.fetchOrders(),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: controller.orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(order, currencyFormatter, controller);
            },
          ),
        );
      }),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildEmptyState(HistoryController controller) {
    return RefreshIndicator(
      onRefresh: () async => await controller.fetchOrders(),
      child: ListView(
        children: [
          SizedBox(height: Get.height * 0.2),
          Center(
            child: Column(
              children: [
                Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 20),
                const Text(
                  "Belum Ada Transaksi", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
                const SizedBox(height: 8),
                Text(
                  "Semua riwayat belanjaanmu akan \nmuncul di sini.", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map order, NumberFormat formatter, HistoryController controller) {
    final status = (order['status'] ?? 'PENDING').toString().toUpperCase();
    final total = double.tryParse(order['total_price'].toString()) ?? 0;
    final paymentUrl = order['xendit_invoice_url'];
    final date = order['created_at'] != null 
        ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(order['created_at']))
        : '-';

    // Warna Status Modern
    Color statusColor;
    switch (status) {
      case 'PAID':
      case 'SETTLED':
        statusColor = Colors.green; break;
      case 'EXPIRED':
      case 'CANCELLED':
        statusColor = Colors.red; break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: No Pesanan & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['order_number'] ?? 'INV-XXXXX', 
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status, 
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)
                ),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Info Kurir & Total
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Icon(Icons.local_shipping_outlined, size: 20, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Pembayaran", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      formatter.format(total), 
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          Text(
            "Kurir: ${order['courier'].toString().toUpperCase()} (${order['shipping_service']})",
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),

          // Tombol Aksi (Bayar)
          if ((status == 'PENDING' || status == 'UNPAID') && paymentUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.payOrder(paymentUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Bayar Sekarang", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
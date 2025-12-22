import 'package:frontend_ecommerce/app/modules/home/controllers/home_controller.dart';
import 'package:frontend_ecommerce/app/modules/home/views/widgets/product_card.dart';
import 'package:frontend_ecommerce/app/widgets/custom_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Juragan Laptop"), // Nama Toko
        actions: [
          // Icon Keranjang (Nanti kita update badge-nya)
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Get.toNamed('/cart'); // <--- Arahkan ke Cart
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'token');
              Get.offAllNamed('/login');
            },
          )
        ],
      ),
      body: Obx(() {
        // --- LOGIC LOADING (SHIMMER) ---
        if (controller.isLoading.value) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 6, // Tampilkan 6 skeleton dummy
            itemBuilder: (context, index) => const CustomSkeleton(radius: 12),
          );
        }

        // --- LOGIC KOSONG ---
        if (controller.products.isEmpty) {
          return const Center(
            child: Text("Belum ada produk nih..."),
          );
        }

        // --- LOGIC DATA MUNCUL ---
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 Kolom
            childAspectRatio: 0.75, // Perbandingan Lebar : Tinggi Card
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ProductCard(
              product: product,
              onTap: () {
                Get.toNamed('/detail', arguments: product); 
              },
            );
          },
        );
      }),
    );
  }
}
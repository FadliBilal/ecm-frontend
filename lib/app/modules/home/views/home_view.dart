import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/home/controllers/home_controller.dart';
import 'package:frontend_ecommerce/app/modules/home/views/widgets/product_card.dart';
import 'package:frontend_ecommerce/app/widgets/custom_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller di-put
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Sticky)
            _buildHeader(),

            // 2. KONTEN SCROLLABLE
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A. BANNER SLIDER
                      _buildBannerSlider(),

                      // B. SAPAAN USER (Tanpa Kategori)
                      _buildGreetingSection(),

                      const SizedBox(height: 24),
                      
                      // C. JUDUL PRODUK
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Produk Terbaru",
                              style: GoogleFonts.poppins(
                                fontSize: 18, 
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBlack
                              ),
                            ),
                            const Text(
                              "Lihat Semua",
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      // D. GRID PRODUK
                      _buildProductGrid(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: const [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: AppColors.textGrey),
                  SizedBox(width: 8),
                  Text("Cari barang...", style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => Get.toNamed('/cart'),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textBlack),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.notifications_none_outlined, color: AppColors.textBlack),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            onPageChanged: controller.changeBannerIndex,
            itemCount: controller.bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300], 
                  image: DecorationImage(
                    image: NetworkImage(controller.bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indikator Dots
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            controller.bannerImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: controller.currentBannerIndex.value == index ? 24 : 6,
              decoration: BoxDecoration(
                // PERBAIKAN: Ganti withOpacity jadi withValues
                color: controller.currentBannerIndex.value == index 
                    ? AppColors.primary 
                    : AppColors.textGrey.withValues(alpha: 0.3), 
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // PERBAIKAN: Ganti withOpacity jadi withValues
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo, Selamat Datang 👋",
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.userName.value,
                  style: GoogleFonts.poppins(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack
                  ),
                )),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Total Pembelian", style: TextStyle(fontSize: 10, color: AppColors.primary)),
                  Obx(() => Text(
                    controller.totalPengeluaran.value,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => const CustomSkeleton(radius: 8),
        );
      }

      if (controller.products.isEmpty) {
        return const Center(child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Produk tidak ditemukan"),
        ));
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return ProductCard(
            product: product,
            onTap: () => Get.toNamed('/detail', arguments: product),
          );
        },
      );
    });
  }
}
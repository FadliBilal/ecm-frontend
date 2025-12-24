import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/home/controllers/home_controller.dart';
import 'package:frontend_ecommerce/app/modules/home/views/widgets/product_card.dart';
import 'package:frontend_ecommerce/app/widgets/custom_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller agar logika search jalan
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white, // Background bersih
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Search Bar Aktif)
            _buildHeader(),

            // 2. KONTEN SCROLLABLE
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A. BANNER SLIDER
                      _buildBannerSlider(),

                      // B. GREETING & QUOTE
                      _buildGreetingSection(),

                      const SizedBox(height: 24),
                      
                      // C. JUDUL SECTION (Tanpa Lihat Semua)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Produk Tukuo",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: 0.5
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // D. GRID PRODUK (Reactive)
                      _buildProductGrid(),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          // SEARCH BAR YANG BERFUNGSI (TextField)
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[50], // Abu sangat muda
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: controller.searchC, // Controller Text
                onChanged: (val) => controller.filterProducts(val), // Panggil Fungsi Search
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Cari produk impianmu...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                  border: InputBorder.none, // Hilangkan garis bawah default
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // ICON CART
          GestureDetector(
            onTap: () => Get.toNamed('/cart'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            onPageChanged: controller.changeBannerIndex,
            itemCount: controller.bannerImages.length,
            itemBuilder: (context, index) {
              String imgUrl = _fixImageUrl(controller.bannerImages[index]);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        
        // INDICATOR DOTS
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
                color: controller.currentBannerIndex.value == index 
                    ? AppColors.primary 
                    : Colors.grey.shade300, 
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // KIRI: Sapaan Nama User
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Datang, 👋",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.userName.value,
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w800,
                    color: Colors.black87
                  ),
                )),
              ],
            ),
            
            // KANAN: Tagline / Quotes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Tukuo seng akeh!", 
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary
                    ),
                  ),
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
      // 1. Loading State
      if (controller.isLoading.value) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => const CustomSkeleton(radius: 12),
        );
      }

      // 2. Empty State (Jika Search Tidak Ketemu)
      if (controller.products.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  "Produk tidak ditemukan", 
                  style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ),
        );
      }

      // 3. List Produk
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          // Hero Animation Tag (Opsional, pastikan unik di ProductCard)
          return ProductCard(
            product: product,
            onTap: () => Get.toNamed('/detail', arguments: product),
          );
        },
      );
    });
  }

  // --- FUNGSI HELPER: FIX GAMBAR ---
  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return "https://placehold.co/600x300/png?text=Promo";
    }

    if (url.startsWith('http')) {
      // Ganti localhost dengan IP Emulator
      if (url.contains('localhost') || url.contains('127.0.0.1')) {
        return url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
      }
      return url;
    }

    // Jika path relatif dari backend
    return "http://10.0.2.2:8000/storage/$url";
  }
}
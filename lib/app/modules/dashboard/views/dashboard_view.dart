import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:frontend_ecommerce/app/modules/home/views/home_view.dart';
import 'package:frontend_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:frontend_ecommerce/app/modules/history/views/history_view.dart'; 
import 'package:frontend_ecommerce/app/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 🛠️ FIX ERROR DISINI ---
    // Inject Controller agar tidak error "DashboardController not found"
    Get.put(DashboardController()); 
    // ---------------------------

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: const [
          HomeView(),    // Tab 0
          CartView(),    // Tab 1
          HistoryView(), // Tab 2
          ProfileView(), // Tab 3
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      )),
    );
  }
}
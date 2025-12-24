import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:frontend_ecommerce/app/modules/home/views/home_view.dart';
import 'package:frontend_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:frontend_ecommerce/app/modules/history/views/history_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: [
          const HomeView(),           
          const HistoryView(),        
          const CartView(),           
          const Center(child: Text("Profil (Soon)")), 
        ],
      )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              // PERBAIKAN: withValues
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() => BottomNavigationBar(
          onTap: controller.changeTabIndex,
          currentIndex: controller.tabIndex.value,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed, 
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        )),
      ),
    );
  }
}
import 'package:frontend_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:frontend_ecommerce/app/modules/history/controllers/history_controller.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
    
    // Logic Auto-Refresh Data
    switch (index) {
      case 1: // Tab Keranjang
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().fetchCart();
        } else {
          Get.put(CartController());
        }
        break;
        
      case 2: // Tab Riwayat (History)
        if (Get.isRegistered<HistoryController>()) {
          Get.find<HistoryController>().fetchOrders();
        } else {
          Get.put(HistoryController());
        }
        break;
    }
  }
}
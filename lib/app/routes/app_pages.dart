import 'package:get/get.dart';

// VIEWS
import 'package:frontend_ecommerce/app/modules/login/views/login_view.dart';
import 'package:frontend_ecommerce/app/modules/register/views/register_view.dart';
import 'package:frontend_ecommerce/app/modules/home/views/home_view.dart';
import 'package:frontend_ecommerce/app/modules/detail/views/detail_product_view.dart';
import 'package:frontend_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:frontend_ecommerce/app/modules/checkout/views/checkout_view.dart';
import 'package:frontend_ecommerce/app/modules/history/views/history_view.dart';
import 'package:frontend_ecommerce/app/modules/dashboard/views/dashboard_view.dart';

// BINDINGS (Pastikan Import Ini Ada)
import 'package:frontend_ecommerce/app/modules/login/bindings/login_binding.dart';
import 'package:frontend_ecommerce/app/modules/register/bindings/register_binding.dart';

class AppPages {
  static const initial = '/login'; 

  static final routes = [
    // 1. LOGIN (Tambahkan binding)
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: LoginBinding(), // <--- INI KUNCINYA
      transition: Transition.fadeIn,
    ),
    
    // 2. REGISTER (Tambahkan binding)
    GetPage(
      name: '/register',
      page: () => const RegisterView(),
      binding: RegisterBinding(), 
      transition: Transition.fadeIn,
    ),

    // 3. DASHBOARD (Menu Utama)
    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      transition: Transition.fadeIn,
    ),

    // Rute Lama (Biarkan saja atau hapus pelan-pelan nanti)
    GetPage(name: '/home', page: () => const HomeView()),
    GetPage(name: '/detail', page: () => const DetailProductView()),
    GetPage(name: '/cart', page: () => const CartView()),
    GetPage(name: '/checkout', page: () => const CheckoutView()),
    GetPage(name: '/history', page: () => const HistoryView()),
  ];
}
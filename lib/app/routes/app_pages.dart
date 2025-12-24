import 'package:get/get.dart';

// --- IMPORT VIEWS ---
import 'package:frontend_ecommerce/app/modules/splash/views/splash_view.dart'; // <--- JANGAN LUPA INI
import 'package:frontend_ecommerce/app/modules/login/views/login_view.dart';
import 'package:frontend_ecommerce/app/modules/register/views/register_view.dart';
import 'package:frontend_ecommerce/app/modules/dashboard/views/dashboard_view.dart';
import 'package:frontend_ecommerce/app/modules/home/views/home_view.dart';
import 'package:frontend_ecommerce/app/modules/detail/views/detail_product_view.dart';
import 'package:frontend_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:frontend_ecommerce/app/modules/checkout/views/checkout_view.dart';
import 'package:frontend_ecommerce/app/modules/history/views/history_view.dart';

// --- IMPORT BINDINGS ---
import 'package:frontend_ecommerce/app/modules/login/bindings/login_binding.dart';
import 'package:frontend_ecommerce/app/modules/register/bindings/register_binding.dart';
// Jika kamu punya dashboard_binding.dart, import juga disini

class AppPages {
  // 1. SET INITIAL KE SPLASH
  static const initial = '/splash'; 

  static final routes = [
    // --- SPLASH SCREEN ---
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
      transition: Transition.fadeIn,
    ),

    // --- AUTH ---
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.fadeIn,
    ),

    // --- MAIN APP ---
    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/home', 
      page: () => const HomeView()
    ),
    
    // --- PRODUCT ---
    GetPage(
      name: '/detail', 
      page: () => const DetailProductView()
      // binding: DetailProductBinding(), // Recommended
    ),

    // --- TRANSACTION ---
    GetPage(
      name: '/cart', 
      page: () => const CartView()
    ),
    GetPage(
      name: '/checkout', 
      page: () => const CheckoutView()
    ),
    GetPage(
      name: '/history', 
      page: () => const HistoryView()
    ),
  ];
}
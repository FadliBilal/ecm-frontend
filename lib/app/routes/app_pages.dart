import 'package:get/get.dart';
import 'package:frontend_ecommerce/app/modules/login/views/login_view.dart';
import 'package:frontend_ecommerce/app/modules/register/views/register_view.dart';
import 'package:frontend_ecommerce/app/modules/home/views/home_view.dart';
import 'package:frontend_ecommerce/app/modules/detail/views/detail_product_view.dart';
import 'package:frontend_ecommerce/app/modules/cart/views/cart_view.dart';

class AppPages {
  // Halaman pertama kali aplikasi dibuka
  static const initial = '/login'; 

  static final routes = [
    GetPage(
      name: '/login', 
      page: () => const LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/register', 
      page: () => const RegisterView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/home', 
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/detail', 
      page: () => const DetailProductView()
    ),
    GetPage(
      name: '/cart', 
      page: () => const CartView()
    ),
  ];
}
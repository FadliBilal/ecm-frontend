import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    // Delay 3 detik biar logonya kelihatan, lalu cek login
    Future.delayed(const Duration(seconds: 3), () {
      if (box.hasData('token')) {
        Get.offAllNamed('/dashboard'); // Sudah Login
      } else {
        Get.offAllNamed('/login'); // Belum Login
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Pakai warna utama aplikasimu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO UTAMA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                // --- UBAH DISINI ---
                // Ganti BoxShape.circle jadi BorderRadius
                borderRadius: BorderRadius.circular(24), 
                // Opsional: Tambah bayangan sedikit biar timbul
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: const Icon(Icons.shopping_bag, size: 60, color: AppColors.primary),
            ),
            
            const SizedBox(height: 24),
            
            // NAMA APLIKASI
            const Text(
              "Tukuo", 
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                letterSpacing: 1.5
              ),
            ),
            
            const SizedBox(height: 40),
            
            // LOADING INDICATOR
            const SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
            ),
          ],
        ),
      ),
    );
  }
}
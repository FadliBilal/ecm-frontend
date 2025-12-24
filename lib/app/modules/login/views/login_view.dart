import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // KUNCI RATA KIRI
            children: [
              const SizedBox(height: 20),
              
              // 1. LOGO (Rounded Box Style)
              Container(
                height: 60,
                width: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // Kotak Rounded
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15), // Bayangan halus warna primary
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded, 
                  size: 32, 
                  color: AppColors.primary
                ),
              ),

              const SizedBox(height: 32),

              // 2. HEADER TEXT (Rata Kiri)
              const Text(
                "Selamat Datang \nKembali! 👋",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800, // Lebih tebal
                  color: Colors.black87,
                  height: 1.2, // Jarak antar baris
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Silakan masuk untuk melanjutkan belanja.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // 3. FORM INPUT
              // Label Email
              const Text(
                "Alamat Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "Masukkan email kamu",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500], size: 22),
                  filled: true,
                  fillColor: Colors.grey[50], // Background abu sangat muda
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Hilangkan border default
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Label Password
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: controller.obscureText.value,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "••••••••",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey[500], size: 22),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureText.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[500],
                      size: 22,
                    ),
                    onPressed: () => controller.toggleObscure(),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              )),

              // Lupa Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Lupa Password?",
                    style: TextStyle(
                      color: AppColors.primary, 
                      fontWeight: FontWeight.w600,
                      fontSize: 13
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 4. TOMBOL LOGIN (Besar & Modern)
              SizedBox(
                width: double.infinity,
                height: 56, // Lebih tinggi sedikit biar gagah
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 8, // Tambah shadow
                    shadowColor: AppColors.primary.withValues(alpha: 0.3), // Shadow warna senada
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Rounded lebih besar
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        )
                      : const Text(
                          "Masuk Sekarang",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                )),
              ),

              const SizedBox(height: 30),

              // 5. FOOTER (Tetap di tengah untuk keseimbangan)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun? ",
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/register'),
                      child: const Text(
                        "Daftar Disini",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
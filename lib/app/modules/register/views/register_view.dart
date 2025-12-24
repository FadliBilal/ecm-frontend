import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/data/models/location_model.dart';
import 'package:frontend_ecommerce/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Back Button & Title)
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                "Buat Akun Tukuo",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lengkapi data diri untuk pengalaman belanja terbaik.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),

              const SizedBox(height: 32),

              // 2. FORM INPUT
              // Nama Lengkap
              _buildLabel("Nama Lengkap"),
              _buildTextField(
                controller: controller.nameC,
                hint: "Masukkan nama lengkap",
                icon: Icons.person_outline_rounded,
              ),
              
              const SizedBox(height: 20),

              // Email
              _buildLabel("Email"),
              _buildTextField(
                controller: controller.emailC,
                hint: "Contoh: user@email.com",
                icon: Icons.email_outlined,
                inputType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // Password
              _buildLabel("Password"),
              Obx(() => TextField(
                controller: controller.passwordC,
                obscureText: controller.obscureText.value,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint: "Buat password yang kuat",
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureText.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[500],
                      size: 22,
                    ),
                    onPressed: controller.toggleObscure,
                  ),
                ),
              )),

              const SizedBox(height: 20),

              // Cari Kecamatan (TypeAhead)
              _buildLabel("Cari Kecamatan"),
              TypeAheadField<Location>(
                controller: controller.locationSearchC,
                builder: (context, textController, focusNode) {
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: _inputDecoration(
                      hint: "Ketik nama kecamatan...",
                      icon: Icons.location_city_outlined,
                    ),
                  );
                },
                suggestionsCallback: (pattern) async => await controller.searchLocation(pattern),
                itemBuilder: (context, suggestion) => ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.primary),
                  title: Text(suggestion.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                onSelected: (suggestion) {
                  controller.locationSearchC.text = suggestion.label;
                  controller.selectedLocationId.value = suggestion.id;
                },
                emptyBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Lokasi tidak ditemukan", style: TextStyle(color: Colors.grey)),
                ),
                decorationBuilder: (context, child) {
                  return Material(
                    type: MaterialType.card,
                    elevation: 4,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Alamat Lengkap
              _buildLabel("Alamat Lengkap"),
              TextField(
                controller: controller.addressC,
                maxLines: 3,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint: "Nama Jalan, No. Rumah, RT/RW...",
                  icon: Icons.home_outlined,
                  isMultiline: true,
                ),
              ),

              const SizedBox(height: 40),

              // 3. TOMBOL DAFTAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.register(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text("Daftar Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                )),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    TextInputType inputType = TextInputType.text
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: _inputDecoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String hint, 
    required IconData icon, 
    Widget? suffixIcon, 
    bool isMultiline = false
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Padding(
        padding: isMultiline ? const EdgeInsets.only(bottom: 30) : EdgeInsets.zero,
        child: Icon(icon, color: Colors.grey[500], size: 22),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[50], // Abu sangat muda
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
    );
  }
}
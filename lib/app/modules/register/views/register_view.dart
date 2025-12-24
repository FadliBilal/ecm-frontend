import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/data/models/location_model.dart';
import 'package:frontend_ecommerce/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

// PASTIKAN NAMA KELAS INI ADALAH RegisterView
class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back, color: AppColors.textBlack),
              ),
              const SizedBox(height: 24),
              const Text(
                "Buat Akun Baru",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text("Lengkapi data diri untuk pengiriman paket", style: TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 32),

              // Form Input (Nama, Email, Password, Lokasi, Alamat)
              _buildLabel("Nama Lengkap"),
              _buildTextField(controller: controller.nameC, hint: "Nama Lengkap", icon: Icons.person_outline),
              const SizedBox(height: 16),
              
              _buildLabel("Email"),
              _buildTextField(controller: controller.emailC, hint: "Email", icon: Icons.email_outlined, inputType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              _buildLabel("Password"),
              Obx(() => TextField(
                controller: controller.passwordC,
                obscureText: controller.obscureText.value,
                decoration: _inputDecoration(
                  hint: "Password", 
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(controller.obscureText.value ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
                    onPressed: controller.toggleObscure,
                  ),
                ),
              )),
              const SizedBox(height: 16),

              _buildLabel("Cari Kecamatan"),
              TypeAheadField<Location>(
                controller: controller.locationSearchC,
                builder: (context, textController, focusNode) {
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: _inputDecoration(hint: "Cari Kecamatan...", icon: Icons.location_on_outlined),
                  );
                },
                suggestionsCallback: (pattern) async => await controller.searchLocation(pattern),
                itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion.label)),
                onSelected: (suggestion) {
                  controller.locationSearchC.text = suggestion.label;
                  controller.selectedLocationId.value = suggestion.id;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel("Alamat Lengkap"),
              TextField(
                controller: controller.addressC,
                maxLines: 3,
                decoration: _inputDecoration(hint: "Jalan, No Rumah...", icon: Icons.home, isMultiline: true),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.register(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: controller.isLoading.value ? const CircularProgressIndicator(color: Colors.white) : const Text("Daftar Sekarang", style: TextStyle(color: Colors.white)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper Sederhana
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
  
  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, TextInputType inputType = TextInputType.text}) {
    return TextField(controller: controller, keyboardType: inputType, decoration: _inputDecoration(hint: hint, icon: icon));
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffixIcon, bool isMultiline = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Padding(padding: isMultiline ? const EdgeInsets.only(bottom: 30) : EdgeInsets.zero, child: Icon(icon, color: AppColors.textGrey)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: AppColors.background,
    );
  }
}
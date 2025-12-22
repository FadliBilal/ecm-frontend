import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/data/models/location_model.dart';
import 'package:frontend_ecommerce/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(RegisterController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Text
              Text(
                "Buat Akun Baru",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const Text(
                "Mulai belanja barang impianmu",
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 30),

              // Form Inputs
              _buildLabel("Nama Lengkap"),
              TextField(
                controller: controller.nameC,
                decoration: const InputDecoration(hintText: "Masukkan nama"),
              ),
              const SizedBox(height: 16),

              _buildLabel("Email"),
              TextField(
                controller: controller.emailC,
                decoration: const InputDecoration(hintText: "contoh@email.com"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildLabel("Password"),
              TextField(
                controller: controller.passwordC,
                obscureText: true,
                decoration: const InputDecoration(hintText: "••••••••"),
              ),
              const SizedBox(height: 16),

              // --- AUTOCOMPLETE LOKASI ---
              _buildLabel("Cari Kecamatan/Kota"),
              TypeAheadField<Location>(
                controller: controller.locationSearchC,
                builder: (context, textController, focusNode) {
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: "Ketik min. 3 huruf (cth: Sura)",
                      suffixIcon: Icon(Icons.location_on_outlined),
                    ),
                  );
                },
                suggestionsCallback: (pattern) async {
                  return await controller.searchLocation(pattern);
                },
                itemBuilder: (context, Location suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.place, color: AppColors.textGrey),
                    title: Text(suggestion.label),
                  );
                },
                onSelected: (Location suggestion) {
                  controller.locationSearchC.text = suggestion.label;
                  controller.selectedLocationId.value = suggestion.id;
                  debugPrint("Lokasi dipilih: ${suggestion.id}"); // Debugging
                },
                loadingBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Mencari...", style: TextStyle(color: AppColors.textGrey)),
                ),
                emptyBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Lokasi tidak ditemukan"),
                ),
              ),
              // ---------------------------

              const SizedBox(height: 32),

              // Tombol Daftar
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.register(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text("Daftar Sekarang"),
                ),
              )),
              
              const SizedBox(height: 20),
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? ", style: TextStyle(color: AppColors.textGrey)),
                  GestureDetector(
                    onTap: () {
                      // Nanti arahkan ke halaman Login
                      debugPrint("Ke Halaman Login");
                    },
                    child: const Text("Masuk", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
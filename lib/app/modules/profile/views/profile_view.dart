import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend_ecommerce/app/core/theme/app_colors.dart';
import 'package:frontend_ecommerce/app/data/models/location_model.dart';
import 'package:frontend_ecommerce/app/modules/profile/controllers/profile_controller.dart';
import 'package:frontend_ecommerce/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan controller terdaftar
    final controller = Get.isRegistered<ProfileController>() 
        ? Get.find<ProfileController>() 
        : Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil Saya", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 1. HEADER USER (RATA KIRI)
              Row(
                children: [
                  Container(
                    height: 70, width: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          controller.name.value,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          controller.email.value,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        )),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
              const SizedBox(height: 24),

              // 2. DETAIL INFORMASI DARI DATABASE
              const Text(
                "Data Akun", 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)
              ),
              const SizedBox(height: 20),
              
              _buildInfoRow(Icons.phone_android_rounded, "Nomor Telepon", controller.phone),
              _buildInfoRow(Icons.location_on_rounded, "Lokasi/Kecamatan", controller.locationLabel),
              _buildInfoRow(Icons.home_work_rounded, "Alamat Lengkap", controller.fullAddress),

              const SizedBox(height: 24),
              const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
              const SizedBox(height: 16),

              // 3. MENU AKSI
              _buildActionTile(
                Icons.edit_note_rounded, 
                "Ubah Data Profil", 
                () => _showEditProfileModal(context, controller)
              ),
              _buildActionTile(
                Icons.shopping_bag_outlined, 
                "Riwayat Pesanan", 
                () => Get.find<DashboardController>().changeTabIndex(2)
              ),

              const SizedBox(height: 40),

              // 4. TOMBOL LOGOUT
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => controller.logout(),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInfoRow(IconData icon, String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Obx(() => Text(
                  value.value, 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)
                )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05), 
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  // --- MODAL EDIT PROFIL (DENGAN TYPEAHEAD PENCARIAN KECAMATAN) ---
  void _showEditProfileModal(BuildContext context, ProfileController controller) {
    final nameC = TextEditingController(text: controller.name.value);
    final phoneC = TextEditingController(text: controller.phone.value);
    final locSearchC = TextEditingController(text: controller.locationLabel.value);
    final addressC = TextEditingController(text: controller.fullAddress.value);
    
    int selectedLocId = controller.locationId.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              _buildEditTextField(nameC, "Nama Lengkap", Icons.person_outline),
              const SizedBox(height: 16),
              _buildEditTextField(phoneC, "Nomor HP", Icons.phone_android_outlined, type: TextInputType.phone),
              const SizedBox(height: 16),
              
              const Text("Cari Kecamatan", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              
              // Widget TypeAhead untuk cari lokasi seperti saat registrasi
              TypeAheadField<Location>(
                controller: locSearchC,
                builder: (context, controller, focusNode) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: "Ketik min. 3 huruf...",
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide(color: Colors.grey.shade200)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: const BorderSide(color: AppColors.primary)
                    ),
                  ),
                ),
                suggestionsCallback: (search) => controller.searchLocation(search),
                itemBuilder: (context, Location suggestion) => ListTile(
                  title: Text(suggestion.label, style: const TextStyle(fontSize: 14)),
                ),
                onSelected: (Location suggestion) {
                  locSearchC.text = suggestion.label;
                  selectedLocId = suggestion.id;
                },
              ),
              
              const SizedBox(height: 16),
              _buildEditTextField(addressC, "Alamat Lengkap (Jl/No Rumah)", Icons.home_outlined, lines: 2),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () {
                    controller.updateProfile(
                      newName: nameC.text,
                      newPhone: phoneC.text,
                      newLocId: selectedLocId,
                      newLocLabel: locSearchC.text,
                      newFullAddress: addressC.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ),
              // Memberi ruang agar tidak tertutup keyboard
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildEditTextField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          maxLines: lines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: Colors.grey.shade200)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: AppColors.primary)
            ),
          ),
        ),
      ],
    );
  }
}
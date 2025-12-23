import 'package:frontend_ecommerce/app/data/providers/api_client.dart';
import 'package:frontend_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- JANGAN LUPA IMPORT INI

class CheckoutController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final CartController cartController = Get.find<CartController>();

  RxString selectedCourier = ''.obs;
  RxList shippingServices = [].obs;
  RxMap selectedService = {}.obs;
  RxBool isLoadingOngkir = false.obs;

  // Grand Total
  double get grandTotal {
    double productTotal = cartController.totalPrice;
    double shippingCost = 0;

    if (selectedService.isNotEmpty) {
      // Kita sudah normalkan strukturnya di bawah, jadi aksesnya aman
      shippingCost = double.tryParse(selectedService['cost'][0]['value'].toString()) ?? 0;
    }

    return productTotal + shippingCost;
  }

  Future<void> checkOngkir(String courierCode) async {
    selectedCourier.value = courierCode;
    selectedService.clear();
    shippingServices.clear();
    isLoadingOngkir.value = true;

    try {
      debugPrint("🚀 MENGIRIM REQUEST KE BACKEND...");

      final response = await _apiClient.init.post('/check-ongkir', data: {
        'courier': courierCode.toLowerCase(),
        'weight': cartController.totalWeight > 0 ? cartController.totalWeight : 1000,
        'origin': 444,      
        'destination': 114, 
      });

      debugPrint("📦 RAW JSON: ${response.data}");

      if (response.statusCode == 200) {
        List parsedCosts = [];
        var rawData = response.data;

        // --- PARSING KHUSUS BACKEND KAMU ---
        if (rawData is List) {
          parsedCosts = rawData.map((item) {
            return {
              'service': item['service'],
              'description': item['description'],
              'cost': [
                {
                  'value': item['cost'], 
                  'etd': item['etd']     
                }
              ]
            };
          }).toList();
        } 
        else if (rawData['data'] is List) {
           parsedCosts = rawData['data']; 
        }

        debugPrint("✅ BERHASIL PARSING: ${parsedCosts.length} item");
        shippingServices.assignAll(parsedCosts);
      }
    } on DioException catch (e) {
      debugPrint("❌ DIO ERROR: ${e.response?.data}");
      Get.snackbar("Gagal", "Error Ongkir: ${e.message}");
    } catch (e) {
      debugPrint("❌ ERROR PARSING: $e");
      Get.snackbar("Error", "Gagal memproses data ongkir");
    } finally {
      isLoadingOngkir.value = false;
    }
  }

  Future<void> placeOrder() async {
    if (selectedService.isEmpty) {
      Get.snackbar("Peringatan", "Pilih ongkir dulu!", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    
    // Mencegah double click
    if (Get.isDialogOpen == true) return; 

    // Tampilkan Loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      debugPrint("🚀 MENGIRIM ORDER...");
      
      var shippingCost = double.tryParse(selectedService['cost'][0]['value'].toString()) ?? 0;
      
      var dataKirim = {
        'shipping_service': selectedService['service'],
        'shipping_cost': shippingCost, 
        'total_price': grandTotal,
        'courier': selectedCourier.value, 
        'destination_city_id': 114, 
        'origin_city_id': 444,      
        // Data Dummy agar lolos validasi backend
        'payment_method': 'xendit', 
        'address': 'Jalan Mulyorejo Kampus C Unair, Surabaya', 
        'phone': '08123456789',             
        'postal_code': '60115',
        'notes': 'Mohon dipacking kayu',
      };

      debugPrint("📦 DATA DIKIRIM: $dataKirim");

      final response = await _apiClient.init.post('/orders', data: dataKirim);
      
      // Tutup Loading
      if (Get.isDialogOpen == true) Get.back();

      debugPrint("✅ RESPONSE ORDER: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        
        // 1. AMBIL LINK PEMBAYARAN
        String paymentUrl = response.data['payment_url'] ?? '';

        Get.defaultDialog(
          title: "🎉 Order Berhasil!",
          middleText: "Pesanan telah dibuat. Lanjutkan pembayaran sekarang?",
          textConfirm: "Bayar Sekarang",
          textCancel: "Nanti Saja",
          confirmTextColor: Colors.white,
          buttonColor: Colors.blue, 
          
          // --- LOGIC TOMBOL BAYAR YANG SUDAH DIPERBAIKI ---
          onConfirm: () async {
            // 1. Tutup Dialog dulu biar UI bersih
            Get.back(); 
            
            // 2. Bersihkan keranjang
            cartController.cartItems.clear(); 
            
            // 3. Buka Link Xendit (Versi Aman)
            if (paymentUrl.isNotEmpty) {
              try {
                final Uri uri = Uri.parse(paymentUrl);
                // Langsung launch mode external (Browser HP)
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint("Gagal buka link: $e");
                Get.snackbar("Info", "Silakan cek halaman Riwayat untuk membayar");
              }
            }

            // 4. Pindah ke Halaman History
            // Pastikan kamu sudah mendaftarkan route '/history' di AppPages!
            Get.offAllNamed('/history'); 
          },
          // ------------------------------------------------
          
          onCancel: () {
            cartController.cartItems.clear();
            Get.offAllNamed('/home');
          }
        );
      }
    } on DioException catch (e) {
      if (Get.isDialogOpen == true) Get.back(); // Tutup loading jika error

      debugPrint("❌ DIO ERROR STATUS: ${e.response?.statusCode}");
      debugPrint("❌ DIO ERROR DATA: ${e.response?.data}");

      String pesan = "Terjadi kesalahan";
      
      if (e.response != null) {
        if (e.response?.data['message'] != null) {
          pesan = e.response?.data['message'];
        }
        if (e.response?.data['errors'] != null) {
           // Ambil error pertama dari map errors
           var errors = e.response?.data['errors'];
           if (errors is Map && errors.isNotEmpty) {
             pesan = "${errors.values.first[0]}";
           }
        }
      }

      Get.snackbar("Gagal Order", pesan, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 4));
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      debugPrint("❌ ERROR LAIN: $e");
      Get.snackbar("Error", "$e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
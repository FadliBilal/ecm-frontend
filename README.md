# 📱 Tukuo – Mobile App (Flutter)

Frontend **Tukuo** adalah aplikasi **Mobile E-Commerce Marketplace** berbasis Flutter yang terhubung ke Backend Laravel melalui REST API. Aplikasi ini digunakan oleh buyer untuk menjelajahi produk, mengelola keranjang, checkout, hingga melakukan pembayaran digital.

---

## 🚀 Gambaran Umum Aplikasi

Tukuo merupakan **marketplace multi-seller**, di mana:

* User dapat melihat produk dari berbagai seller
* Setiap produk memiliki lokasi seller berbeda (origin dinamis)
* Alamat user digunakan sebagai tujuan pengiriman (destination)
* Ongkir dihitung otomatis saat checkout
* Pembayaran dilakukan melalui payment gateway

Aplikasi ini sepenuhnya **bergantung pada Backend API**.

---

## 🧱 Tech Stack

* **Framework** : Flutter
* **State Management** : GetX
* **HTTP Client** : Dio
* **Local Storage** : GetStorage
* **Routing & Navigation** : GetX
* **Platform** : Android / iOS

---

## 📂 Struktur Folder

```
lib/
 ├── app/
 │   ├── data/
 │   │   ├── models/        # Model response API
 │   │   ├── providers/     # Dio & API provider
 │   │   └── services/      # Helper & service
 │   ├── modules/
 │   │   ├── auth/          # Login & Register
 │   │   ├── home/          # Home & product list
 │   │   ├── product/       # Detail produk
 │   │   ├── cart/          # Keranjang
 │   │   ├── checkout/      # Checkout & ongkir
 │   │   └── profile/       # Profil user
 │   └── routes/            # App routing
 └── main.dart
```

---

## 🔐 Autentikasi & Session

* Login & Register menggunakan API Backend
* Token disimpan di **GetStorage**
* **Dio Interceptor** otomatis menambahkan header:

```
Authorization: Bearer {token}
```

* Jika token invalid / expired → user logout otomatis

---

## 🛍️ Fitur Utama Aplikasi

### 1️⃣ Authentication

* Register user
* Login user
* Auto login jika token masih tersedia
* Logout

---

### 2️⃣ Produk

* Menampilkan list produk
* Detail produk:

  * Nama
  * Harga
  * Stok
  * Berat
  * Deskripsi

---

### 3️⃣ Keranjang (Cart)

* Add to cart
* Update quantity
* Hapus item
* Data cart tersimpan di backend

---

### 4️⃣ Logic "Beli Sekarang"

Aplikasi membedakan dua alur:

* **Beli Sekarang**

  * Checkout langsung 1 produk

* **Checkout Keranjang**

  * Checkout banyak produk sekaligus

Logic ini dikontrol melalui state & parameter checkout.

---

### 5️⃣ Checkout (Fitur Paling Kompleks)

Alur checkout di frontend:

1. Validasi data user

   * Alamat
   * Nomor HP

2. Jika data belum lengkap

   * Muncul popup wajib isi data

3. Hitung ongkir otomatis

   * Origin → lokasi seller
   * Destination → lokasi user
   * Berat → total berat produk

4. Menampilkan:

   * Pilihan kurir
   * Ongkir
   * Total harga

---

### 6️⃣ Pembayaran

* Frontend request pembuatan order ke backend
* Backend mengembalikan `payment_url`
* URL dibuka melalui:

  * WebView atau
  * Browser

Status pembayaran disimpan dan dikelola di backend.

---

## 🌐 Komunikasi API

* Semua request menggunakan **Dio**
* Base URL API diset di satu file (mudah diganti)
* Error handling terpusat

---

## ⚙️ Cara Menjalankan Project

### 1️⃣ Clone Repository

```
git clone https://github.com/username/tukuo-frontend.git
cd tukuo-frontend
```

---

### 2️⃣ Install Dependency

```
flutter pub get
```

---

### 3️⃣ Konfigurasi API

* Pastikan backend sudah berjalan
* Atur `baseUrl` ke alamat backend API

Contoh:

```
http://127.0.0.1:8000/api
```

---

### 4️⃣ Jalankan Aplikasi

```
flutter run
```

---

## 📌 Catatan Penting

* Aplikasi **tidak bisa berjalan tanpa backend**
* Pastikan:

  * Backend aktif
  * Token valid
  * Koneksi internet tersedia

---

## 👨‍💻 Penutup

Frontend **Tukuo** dirancang modular, rapi, dan mudah dipelajari dengan pendekatan GetX agar scalable dan maintainable.

Cocok untuk pembelajaran maupun pengembangan aplikasi marketplace berbasis mobile 🚀

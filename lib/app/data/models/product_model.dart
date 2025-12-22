class Product {
  final int id;
  final String name;
  final int price;
  final int weight;
  final int stock;
  final String? image;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.weight,
    required this.stock,
    this.image,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      
      // --- PERBAIKAN DI SINI ---
      // Parse ke double dulu biar aman dari ".00", baru ubah ke int
      price: double.parse(json['price'].toString()).toInt(),
      
      // Lakukan hal yang sama untuk weight (jaga-jaga kalau ada koma juga)
      weight: double.parse(json['weight'].toString()).toInt(),
      stock: int.parse(json['stock'].toString()),
      
      image: json['image'],
      description: json['description'] ?? '',
    );
  }

  // --- HELPER BUAT URL GAMBAR ---
  // Ganti 10.0.2.2 dengan IP Laptopmu jika pakai HP Fisik
  String get fullImageUrl {
    if (image == null || image!.isEmpty) {
      return "https://placehold.co/600x400/png"; 
    }

    // SEBELUMNYA (SALAH):
    // return "http://10.0.2.2:8000/storage/products/$image";
    
    // PERBAIKAN (BENAR):
    // Langsung tempel $image karena di DB sudah ada nama foldernya
    return "http://10.0.2.2:8000/storage/$image";
  }
}
class Location {
  final int id;
  final String label; // Contoh: "Tambaksari, Surabaya, Jawa Timur"

  Location({required this.id, required this.label});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      // Handle jika backend kirim 'label' atau kombinasi nama kecamatan
      id: json['id'] ?? 0, 
      label: json['label'] ?? json['subdistrict_name'] ?? 'Lokasi Tanpa Nama',
    );
  }
}
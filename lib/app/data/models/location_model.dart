class Location {
  final int id;
  final String label; // Contoh: "Tambaksari, Surabaya, Jawa Timur"

  Location({required this.id, required this.label});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      // Sesuaikan dengan response API RajaOngkirService kamu
      // Biasanya RajaOngkir/Komerce balikin 'subdistrict_id' atau 'destination_id'
      // Tapi di API Service kamu kemarin saya lihat kamu return standardized data
      id: json['id'] ?? 0, 
      label: json['label'] ?? json['subdistrict_name'] ?? 'Unknown',
    );
  }
}
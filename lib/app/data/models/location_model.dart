class Location {
  final int id;
  final String label;

  Location({required this.id, required this.label});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? 0, 
      label: json['label'] ?? json['subdistrict_name'] ?? 'Lokasi Tanpa Nama',
    );
  }
}
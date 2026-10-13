class Product {
  int? id;
  String nama;
  int harga;
  int stok;
  String deskripis;
  String? gambar;

  Product({
    this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.deskripis,
    this.gambar,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      nama: json["nama"]?.toString() ?? "",
      harga: int.tryParse(json["harga"].toString()) ?? 0,
      stok: int.tryParse(json["stok"].toString()) ?? 0,
      deskripis: json["deskripis"]?.toString() ??
          json["deskripsi"]?.toString() ??
          "",
      gambar: json["gambar"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama": nama,
      "harga": harga,
      "stok": stok,
      "deskripis": deskripis,
      "gambar": gambar,
    };
  }
}
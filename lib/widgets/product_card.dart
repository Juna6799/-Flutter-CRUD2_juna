import 'package:flutter/material.dart';
import 'package:flutter_juna/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onDetail,
  });

  String formatRupiah(int angka) {
      String hasil = angka.toString();
      String result = "";
      int counter = 0;

      for (int i = hasil.length - 1; i >= 0; i--) {
        result = hasil[i] + result;
        counter++;

        if (counter == 3 && i != 0) {
          result = ".$result";
          counter = 0;
        }
      }

      return "Rp$result";
    }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDetail,
      child: Card(
        margin: const EdgeInsets.all(11),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: product.gambar == null ||
                          product.gambar!.isEmpty
                      ? Image.asset(
                          "assets/burung.jpg",
                          height: 121,
                          width: 121,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          "http://localhost:8000/storage/products/${product.gambar}",
                          height: 121,
                          width: 121,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("GAMBAR ERROR: $error");
                            print(
                              "URL GAMBAR: http://localhost:8000/storage/products/${product.gambar}",
                            );

                            return const Icon(
                              Icons.broken_image,
                              size: 80,
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                product.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 11),

              Text(
                "Harga: ${formatRupiah(product.harga)}",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 11),

              Text(
                "Stok: ${product.stok}",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 11),

              Text(product.deskripis),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
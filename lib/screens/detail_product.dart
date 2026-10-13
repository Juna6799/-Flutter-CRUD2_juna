import 'package:flutter/material.dart';
import 'package:flutter_juna/models/product.dart';
import 'package:flutter_juna/screens/edit_pace.dart';

class DetailProduct extends StatelessWidget {
  final Product product;

  const DetailProduct({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Product"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Hero(
              tag: product.id!,
              child: Container(
                height: 201,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    133,
                    21,
                    145,
                    154,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: product.gambar != null && product.gambar!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          "http://127.0.0.1:8000/storage/products/${product.gambar}",
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 100,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 120,
                          color: Colors.red,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 21),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 21),

                    // HARGA
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Rp ${product.harga}",
                          style: const TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // STOK
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Stok: ${product.stok}",
                          style: const TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 14,
                    ),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      product.deskripis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // EDIT PRODUCT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Edit Product",
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: ()async {
                  final hasil = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPage(
                        product: product,
                      ),
                    ),
                  );
                  if (hasil == true){
                    Navigator.pop(context,true);
                  }
                },
              ),
            ),

            const SizedBox(height: 15),

            // KEMBALI
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                label: const Text(
                  "Kembali",
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

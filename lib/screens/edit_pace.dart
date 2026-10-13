import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_juna/models/product.dart';
import 'package:flutter_juna/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class EditPage extends StatefulWidget {
  final Product product;

  const EditPage({
    super.key,
    required this.product,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();
  final deskripsiController = TextEditingController();

  final ApiService api = ApiService();

  final ImagePicker picker = ImagePicker();

  bool loading = false;

  XFile? image;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();

    namaController.text = widget.product.nama;
    hargaController.text = widget.product.harga.toString();
    stokController.text = widget.product.stok.toString();
    deskripsiController.text = widget.product.deskripis;
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> pilihGambar() async {
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (picked == null) {
        return;
      }
      final Uint8List bytes = await picked.readAsBytes();

      setState(() {
        image = picked;
        imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select image: $e',
          ),
        ),
      );
    }
  }

  Future<void> updateData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    Product product = Product(
      id: widget.product.id,
      nama: namaController.text,
      harga: int.parse(hargaController.text),
      stok: int.parse(stokController.text),
      deskripis: deskripsiController.text,
    );

    bool berhasil = await api.updateProduct(product);

    setState(() {
      loading = false;
    });

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal memperbarui produk"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> konfirmasiUpdate() async {
    bool? hasil = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah Anda yakin ingin memperbarui data?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      updateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Product"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(17),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama produk wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Harga wajib diisi";
                  }

                  if (int.tryParse(value) == null) {
                    return "Harga harus berupa angka";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Stok Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Stok wajib diisi";
                  }

                  if (int.tryParse(value) == null) {
                    return "Stok harus berupa angka";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: deskripsiController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Deskripsi wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : konfirmasiUpdate,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.edit),
                  label: Text(
                    loading ? "Menyimpan..." : "Update Product",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

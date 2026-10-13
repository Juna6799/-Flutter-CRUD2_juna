import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_juna/models/product.dart';
import 'package:flutter_juna/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();
  final deskripsiController = TextEditingController();

  final ApiService api = ApiService();

  bool loading = false;

  XFile? image;
  Uint8List? imageBytes;

  final ImagePicker picker = ImagePicker();

  // =========================
  // PILIH GAMBAR
  // =========================
  Future<void> pilihGambar() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setState(() {
        image = picked;
        imageBytes = bytes;
      });
    }
  }

  // =========================
  // SIMPAN DATA
  // =========================
  Future<void> simpanData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final Product product = Product(
        nama: namaController.text,
        harga: int.parse(hargaController.text),
        stok: int.parse(stokController.text),
        deskripis: deskripsiController.text,
      );

      final bool berhasil = await api.storeProduct(
        product,
        image,
      );

      if (!mounted) return;

      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produk Berhasil Ditambahkan"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menambahkan produk"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    deskripsiController.dispose();

    super.dispose();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambahkan Produk"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // GAMBAR PRODUK
            // =========================
            Center(
              child: GestureDetector(
                onTap: pilihGambar,
                child: imageBytes == null
                    ? Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 60,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          imageBytes!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // FORM
            // =========================
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // NAMA
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.shopping_bag,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nama Wajib diisi";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // HARGA
                    TextFormField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Harga Produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.money,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Harga Wajib diisi";
                        }

                        if (int.tryParse(value) == null) {
                          return "Harga harus berupa angka";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // STOK
                    TextFormField(
                      controller: stokController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Stok Produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.inventory_2,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Stok Wajib diisi";
                        }

                        if (int.tryParse(value) == null) {
                          return "Stok harus berupa angka";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // DESKRIPSI
                    TextFormField(
                      controller: deskripsiController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Deskripsi Produk",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.description,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Deskripsi Wajib diisi";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : simpanData,
                        icon: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          loading
                              ? "Menyimpan..."
                              : "Simpan",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
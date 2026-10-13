  import 'package:flutter/material.dart';
  import 'package:flutter_juna/models/product.dart';
  import 'package:flutter_juna/screens/detail_product.dart';
  import 'package:flutter_juna/screens/edit_pace.dart';
  import 'package:flutter_juna/screens/login_page.dart';
  import 'package:flutter_juna/services/api_service.dart';
  import 'package:flutter_juna/widgets/dashboard_card.dart';
  import '../widgets/product_card.dart';
  import 'add_page.dart';

  class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    // VARIABLE

    final ApiService api = ApiService();

    final TextEditingController searchController = TextEditingController();

    List<Product> allProduct = [];
    List<Product> hasilPencarian = [];

    String filterHarga = "Semua";
    String sorting = "Nama A-Z";

    bool isLoading = true;

    // INIT STATE

    @override
    void initState() {
      super.initState();
      loadProduk();
    }

    // LOAD DATA PRODUK

    Future<void> loadProduk() async {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      try {
        final data = await api.getProducts();

        if (!mounted) return;

        allProduct = data;

        isLoading = false;

        prosesData();
      } catch (e) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal mengambil data: $e",
            ),
          ),
        );
      }
    }

    // PROSES SEARCH
    // FILTER
    // SORTING

    void prosesData() {
      List<Product> data = List.from(allProduct);

      // SEARCH BERDASARKAN NAMA
      final keyword = searchController.text.trim().toLowerCase();

      if (keyword.isNotEmpty) {
        data = data.where((produk) {
          return produk.nama.toLowerCase().contains(keyword);
        }).toList();
      }

      // FILTER HARGA
      if (filterHarga == "< Rp510000") {
        data = data.where((produk) {
          return produk.harga < 510000;
        }).toList();
      } else if (filterHarga == "Rp510000 - Rp2100000") {
        data = data.where((produk) {
          return produk.harga >= 510000 && produk.harga <= 2100000;
        }).toList();
      } else if (filterHarga == "> Rp2100000") {
        data = data.where((produk) {
          return produk.harga > 2100000;
        }).toList();
      }

      // SORTING
      if (sorting == "Nama A-Z") {
        data.sort(
          (a, b) => a.nama.toLowerCase().compareTo(
                b.nama.toLowerCase(),
              ),
        );
      } else if (sorting == "Nama Z-A") {
        data.sort(
          (a, b) => b.nama.toLowerCase().compareTo(
                a.nama.toLowerCase(),
              ),
        );
      } else if (sorting == "Harga tertinggi") {
        data.sort(
          (a, b) => b.harga.compareTo(a.harga),
        );
      } else if (sorting == "Harga terendah") {
        data.sort(
          (a, b) => a.harga.compareTo(b.harga),
        );
      } else if (sorting == "Stok banyak") {
        data.sort(
          (a, b) => b.stok.compareTo(a.stok),
        );
      } else if (sorting == "Stok sedikit") {
        data.sort(
          (a, b) => a.stok.compareTo(b.stok),
        );
      }

      if (!mounted) return;

      setState(() {
        hasilPencarian = data;
      });
    }

    // SEARCH

    void cariProduk(String keyword) {
      prosesData();
    }

    // =========================
    // PILIH FILTER HARGA
    // =========================

    void pilihFilterHarga(String? pilihan) {
      if (pilihan == null) return;

      filterHarga = pilihan;

      prosesData();
    }

    // =========================
    // PILIH SORTING
    // =========================

    void pilihSorting(String? pilihan) {
      if (pilihan == null) return;

      sorting = pilihan;

      prosesData();
    }

    // =========================
    // TOTAL PRODUK
    // =========================

    int totalProduk() {
      return allProduct.length;
    }

    // =========================
    // TOTAL STOK
    // =========================

    int totalStok() {
      return allProduct.fold(
        0,
        (total, item) => total + item.stok,
      );
    }

    // =========================
    // TOTAL HARGA
    // =========================

    int totalHarga() {
      return allProduct.fold(
        0,
        (total, item) => total + (item.harga * item.stok),
      );
    }

    // =========================
    // FORMAT RUPIAH
    // =========================

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

    // =========================
    // HAPUS PRODUK
    // =========================

    Future<void> hapusProduk(Product product) async {
      final bool? konfirmasi = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Konfirmasi",
            ),
            content: Text(
              "Apakah yakin akan menghapus "
              "${product.nama}?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text(
                  "Batal",
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  "Hapus",
                ),
              ),
            ],
          );
        },
      );

      if (konfirmasi != true) {
        return;
      }

      try {
        print(
          "ID yang dikirim: ${product.id}",
        );

        final bool hasil = await api.deleteProduct(product.id!);

        print(
          "Status delete: $hasil",
        );

        if (!mounted) return;

        if (hasil) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Produk berhasil dihapus",
              ),
            ),
          );

          await loadProduk();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Produk gagal dihapus",
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Terjadi kesalahan: $e",
            ),
          ),
        );
      }
    }

    // =========================
    // DISPOSE
    // =========================

    @override
    void dispose() {
      searchController.dispose();
      super.dispose();
    }

    // =========================
    // BUILD
    // =========================

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        // =========================
        // APP BAR
        // =========================

        appBar: AppBar(
          title: const Text(
            "Product Data XII RPL 1",
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(
            255,
            6,
            228,
            221,
          ),
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
              ),
              onPressed: () async {
                await api.logout();

                if (!mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),

        // =========================
        // FLOATING BUTTON
        // =========================

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final hasil = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddPage(),
              ),
            );

            if (hasil == true) {
              await loadProduk();
            }
          },
          child: const Icon(
            Icons.add,
          ),
        ),

        // =========================
        // BODY
        // =========================

        body: RefreshIndicator(
          onRefresh: loadProduk,
          child: isLoading

              // -------------------------
              // LOADING
              // -------------------------

              ? const Center(
                  child: CircularProgressIndicator(),
                )

              // -------------------------
              // DATA
              // -------------------------

              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: [
                    // =========================
                    // GREETING
                    // =========================

                    const Text(
                      "Hello Admin",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    const Text(
                      "Selamat Datang di "
                      "Aplikasi CRUD XII RPL 1",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // =========================
                    // SEARCH
                    // =========================

                    TextField(
                      controller: searchController,
                      onChanged: cariProduk,
                      decoration: InputDecoration(
                        hintText: "Cari Produk",
                        prefixIcon: const Icon(
                          Icons.search,
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  searchController.clear();

                                  cariProduk(
                                    "",
                                  );
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // =========================
                    // FILTER & SORTING
                    // =========================

                    Row(
                      children: [
                        // FILTER HARGA
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: filterHarga,
                            decoration: const InputDecoration(
                              labelText: "Filter Harga",
                              prefixIcon: Icon(
                                Icons.filter_alt,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "Semua",
                                child: Text(
                                  "Semua",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "< Rp510000",
                                child: Text(
                                  "< Rp510.000",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Rp510000 - Rp2100000",
                                child: Text(
                                  "Rp510.000 - Rp2.100.000",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "> Rp2100000",
                                child: Text(
                                  "> Rp2.100.000",
                                ),
                              ),
                            ],
                            onChanged: pilihFilterHarga,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        // SORTING
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sorting,
                            decoration: const InputDecoration(
                              labelText: "Urutkan",
                              prefixIcon: Icon(
                                Icons.sort,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "Nama A-Z",
                                child: Text(
                                  "Nama A-Z",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Nama Z-A",
                                child: Text(
                                  "Nama Z-A",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Harga tertinggi",
                                child: Text(
                                  "Harga tertinggi",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Harga terendah",
                                child: Text(
                                  "Harga terendah",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Stok banyak",
                                child: Text(
                                  "Stok banyak",
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Stok sedikit",
                                child: Text(
                                  "Stok sedikit",
                                ),
                              ),
                            ],
                            onChanged: pilihSorting,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // =========================
                    // DASHBOARD
                    // =========================

                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: "Produk",
                            value: "${totalProduk()}",
                            icon: Icons.shopping_bag,
                            color: Colors.indigo,
                          ),
                        ),
                        Expanded(
                          child: DashboardCard(
                            title: "Stok",
                            value: "${totalStok()}",
                            icon: Icons.inventory,
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: DashboardCard(
                            title: "Total Harga",
                            value: formatRupiah(
                              totalHarga(),
                            ),
                            icon: Icons.payment,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =========================
                    // JUDUL PRODUK
                    // =========================

                    const Text(
                      "Daftar Produk",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      "${hasilPencarian.length} "
                      "produk ditemukan",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // =========================
                    // HASIL PRODUK
                    // =========================

                    if (hasilPencarian.isEmpty)

                      // -------------------------
                      // TIDAK ADA HASIL
                      // -------------------------

                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Produk tidak ditemukan",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else

                      // -------------------------
                      // LIST PRODUK
                      // -------------------------

                      ...hasilPencarian.map(
                        (product) {
                          return ProductCard(
                            product: product,

                            // =========================
                            // EDIT
                            // =========================

                            onEdit: () async {
                              final hasil = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPage(
                                    product: product,
                                  ),
                                ),
                              );

                              if (hasil == true) {
                                await loadProduk();
                              }
                            },

                            // =========================
                            // DELETE
                            // =========================

                            onDelete: () {
                              hapusProduk(
                                product,
                              );
                            },

                            // =========================
                            // DETAIL
                            // =========================

                            onDetail: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailProduct(
                                    product: product,
                                  ),
                                ),
                              );

                              await loadProduk();
                            },
                          );
                        },
                      ),
                  ],
                ),
        ),
      );
    }
  }

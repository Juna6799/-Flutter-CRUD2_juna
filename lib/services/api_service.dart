import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/';
  static const String imageBaseUrl = 'http://127.0.0.1:8000/storage/';

  Future<List<Product>> getProducts() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    print("TOKEN GET: $token");

    if (token.isEmpty) {
      throw Exception("Token tidak ditemukan. Silakan login kembali.");
    }

    final response = await http.get(
      Uri.parse('${baseUrl}products'),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("STATUS GET: ${response.statusCode}");
    print("RESPONSE GET: ${response.body}");

    if (response.statusCode == 401) {
      await pref.remove("token");
      throw Exception("Token tidak valid. Silakan login kembali.");
    }

    if (response.statusCode != 200) {
      throw Exception(
        "Gagal mengambil data. Status: ${response.statusCode}",
      );
    }

    final decoded = jsonDecode(response.body);

    List data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map && decoded["data"] is List) {
      data = decoded["data"];
    } else {
      throw Exception("Format data tidak sesuai.");
    }

    final products = data
        .map((e) => Product.fromJson(e))
        .toList();

    print("JUMLAH PRODUK: ${products.length}");

    return products;
  }

  Future<bool> storeProduct(
    Product product,
    XFile? imageFile,
  ) async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${baseUrl}products"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields["nama"] = product.nama;
      request.fields["harga"] = product.harga.toString();
      request.fields["stok"] = product.stok.toString();
      request.fields["deskripis"] = product.deskripis;

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            "gambar",
            bytes,
            filename: imageFile.name,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      print("STATUS STORE: ${response.statusCode}");
      print("RESPONSE STORE: ${response.body}");

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("ERROR STORE: $e");
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    try {
      final response = await http.put(
        Uri.parse("${baseUrl}products/${product.id}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nama": product.nama,
          "harga": product.harga,
          "stok": product.stok,
          "deskripis": product.deskripis,
        }),
      );

      print("STATUS UPDATE: ${response.statusCode}");
      print("RESPONSE UPDATE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("ERROR UPDATE: $e");
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    try {
      final response = await http.delete(
        Uri.parse("${baseUrl}products/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("STATUS DELETE: ${response.statusCode}");
      print("RESPONSE DELETE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("ERROR DELETE: $e");
      return false;
    }
  }

  Future<String?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}login"),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "email": email,
          "password": password,
        },
      );

      print("STATUS LOGIN: ${response.statusCode}");
      print("RESPONSE LOGIN: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? token;

        if (data is Map && data["token"] != null) {
          token = data["token"].toString();
        } else if (data is Map &&
            data["data"] is Map &&
            data["data"]["token"] != null) {
          token = data["data"]["token"].toString();
        }

        if (token != null && token.isNotEmpty) {
          final pref = await SharedPreferences.getInstance();

          await pref.setString(
            "token",
            token,
          );

          print("TOKEN BERHASIL DISIMPAN");
          print("TOKEN: $token");

          return token;
        }
      }

      return null;
    } catch (e) {
      print("ERROR LOGIN: $e");
      return null;
    }
  }

  Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    try {
      await http.post(
        Uri.parse("${baseUrl}logout"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
    } finally {
      await pref.remove("token");
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  // Ganti dengan IP komputer/server Laravel kamu
  final String baseUrl = "http://192.168.115.151:8000/api";

  Future<bool> createMultiItemOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
    required List items,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/orders");

      // Debugging: Cetak data mentah sebelum diproses
      print("DEBUG - Items mentah: $items");

      // Format data agar sesuai dengan validasi Laravel
      List<Map<String, dynamic>> formattedItems = items.map((item) {
        // Logika pengambilan ID: coba product_id, jika null coba id, jika tidak ada kirim null
        var pId = item["product_id"] ?? item["id"];

        print("DEBUG - Memproses Item: ${item["name"]}, ID yang terbaca: $pId");

        return {
          "product_id": pId,
          "product_name": item["name"],
          "qty": item["qty"],
          "price": double.tryParse(item["price"].toString()) ?? 0,
        };
      }).toList();

      // Ambil token dari SharedPreferences untuk auth
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "customer_name": customerName,
          "phone": phone,
          "address": address,
          "payment_method": paymentMethod,
          "items": formattedItems,
        }),
      );

      // Cek respon server
      if (response.statusCode == 201) {
        print("DEBUG - Order Berhasil");
        return true;
      } else {
        // Tampilkan error server jika gagal (500 atau 422)
        print(
          "DEBUG - Server Error (${response.statusCode}): ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("DEBUG - Exception OrderService: $e");
      return false;
    }
  }
}

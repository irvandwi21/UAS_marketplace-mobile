import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String baseUrl =
      "http://192.168.115.151:8000/api";

  Future<bool> createOrder({
  required String customerName,
  required String phone,
  required String address,
  required String productName,
  required int qty,
  required double totalPrice,
  required String paymentMethod,
  }) async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    String? token =
        prefs.getString("token");

    final response = await http.post(
      Uri.parse("$baseUrl/orders"),

      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },

      body: {
  "customer_name": customerName,
  "phone": phone,
  "address": address,
  "product_name": productName,
  "qty": qty.toString(),
  "total_price": totalPrice.toString(),
  "payment_method": paymentMethod,
},
    );

    print(response.body);

    return response.statusCode == 200 ||
        response.statusCode == 201;
  }
}
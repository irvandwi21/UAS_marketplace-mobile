import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl =
      "http://192.168.115.151:8000/api";

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse("$baseUrl/products"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data
          .map((item) => Product.fromJson(item))
          .toList();
    }

    return [];
  }
}
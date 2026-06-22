import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/cart_data.dart';

import '../cart/checkout_page.dart';
import '../auth/login_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int id;
  final String name;
  final String price;
  final String description;
  final String image;

  const ProductDetailPage({
  super.key,
  required this.id,
  required this.name,
  required this.price,
  required this.description,
  required this.image,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}


class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  Future<bool> isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    return token != null;
  }

  Future<void> buyNow() async {
    bool login = await isLogin();

    if (!mounted) return;

    if (!login) {
      final result = await Navigator.push(
        context,

        MaterialPageRoute(builder: (_) => const LoginPage(fromCheckout: true)),
      );

      if (result == true) {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => const CheckoutPage()),
        );
      }

      return;
    }

    Navigator.push(
      context,

      MaterialPageRoute(builder: (_) => const CheckoutPage()),
    );
  }

  Future<void> addToCart() async {
    bool login = await isLogin();

    if (!mounted) return;

    if (!login) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage(fromCheckout: true)),
      );
      return;
    }

    CartData.items.add({
        "id": widget.id,
        "name": widget.name,
        "price": widget.price,
        "qty": quantity,
        "image": widget.image,
        "description": widget.description,
      });

    print("ISI KERANJANG:");
    print(CartData.items);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${widget.name} masuk keranjang")));
  }

  @override
      Widget build(BuildContext context) {

        print("IMAGE DETAIL = ${widget.image}");

        return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                 "http://192.168.115.151:8000/products/${widget.image}",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 120,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.name,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.price,

                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Deskripsi Produk",

                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  Text(
                      widget.description,
                      style: const TextStyle(fontSize: 16),
                    ),

                  const SizedBox(height: 20),

                  const Text(
                    "Jumlah",

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },

                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                      ),

                      Text(
                        quantity.toString(),

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },

                        icon: const Icon(Icons.add_circle, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),

        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: addToCart,

                icon: const Icon(Icons.shopping_cart),

                label: const Text("Keranjang"),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: buyNow,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),

                child: const Text(
                  "Beli Sekarang",

                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

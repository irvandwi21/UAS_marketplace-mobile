import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onBuy;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Card(
        elevation: 3,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        child: Column(
          children: [
            Expanded(
              child: Image.network(
                "http://192.168.115.151:8000/products/${product.image}",
                width: double.infinity,
                fit: BoxFit.cover,

                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 60);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Text(
              "Rp ${product.price}",
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(onPressed: onBuy, child: const Text("Beli")),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

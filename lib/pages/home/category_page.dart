import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Text(
            "Produk Kategori $categoryName",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text("$categoryName 1"),
              subtitle: const Text("Rp 100.000"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text("$categoryName 2"),
              subtitle: const Text("Rp 200.000"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text("$categoryName 3"),
              subtitle: const Text("Rp 300.000"),
            ),
          ),
        ],
      ),
    );
  }
}

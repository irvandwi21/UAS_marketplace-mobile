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
  State<ProductDetailPage> createState() => _ProductDetailPageState();
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

    // --- BUNGKUS DATA PRODUK KE DALAM LIST ---
    final List<Map<String, dynamic>> itemToBuy = [
      {
        "id": widget.id,
        "name": widget.name,
        "price": widget.price, 
        "qty": quantity, // Menggunakan variabel quantity dari state
        "image": widget.image,
        "description": widget.description,
      }
    ];

    if (!login) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage(fromCheckout: true)),
      );

      if (result == true) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutPage(selectedItems: itemToBuy),
          ),
        );
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(selectedItems: itemToBuy),
      ),
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

    // INFO: widget.price tetap menggunakan data angka mentah dari API untuk cart
    // jadi tidak akan merusak struktur perhitungan atau database kamu.
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

  // --- FUNGSI BANTUAN UNTUK FORMAT RUPIAH ---
  String formatRupiah(String priceStr) {
    try {
      // Ubah string ke int (mengabaikan desimal jika ada)
      int price = double.parse(priceStr).toInt(); 
      // Format dengan pemisah ribuan titik
      String result = price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      return 'Rp $result';
    } catch (e) {
      // Jika formatnya sudah mengandung 'Rp' dari API, kembalikan saja langsung
      if (priceStr.toUpperCase().contains('RP')) return priceStr;
      return 'Rp $priceStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    print("IMAGE DETAIL = ${widget.image}");

    // --- DEFINISI PALET WARNA ---
    const Color bgColor = Color(0xFF0B1221);       
    const Color cardColor = Color(0xFF1A2235);     
    const Color accentColor = Color(0xFF2979FF);   
    const Color priceColor = Color(0xFF00BFA5);    
    const Color bottomNavColor = Color(0xFF111827);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER IMAGE
            Stack(
              children: [
                SizedBox(
                  height: 380, 
                  width: double.infinity,
                  child: Image.network(
                    "http://192.168.115.151:8000/products/${widget.image}",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: cardColor, 
                        child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[700]),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          bgColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // KONTEN DETAIL PRODUK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // HARGA YANG SUDAH DI-FORMAT RUPIAH
                  Text(
                    formatRupiah(widget.price),
                    style: const TextStyle(
                      color: priceColor, 
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Deskripsi Produk",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      height: 1.6, 
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Jumlah",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Kontrol Jumlah Premium
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.remove,
                            color: quantity > 1 ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            quantity.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          icon: const Icon(Icons.add, color: accentColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30), 
                ],
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: bottomNavColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: addToCart,
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: const Text(
                  "Keranjang",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  side: const BorderSide(color: accentColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), 
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: ElevatedButton(
                onPressed: buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), 
                  ),
                  elevation: 4,
                  shadowColor: accentColor.withOpacity(0.4), 
                ),
                child: const Text(
                  "Beli Sekarang",
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
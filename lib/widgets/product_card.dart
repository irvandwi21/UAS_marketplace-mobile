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
    required this.onBuy, // Tetap dipertahankan agar tidak error di halaman Home
  });

  // Fungsi helper untuk memformat angka menjadi Rupiah (Rp 10.000.000)
  String formatRupiah(String priceStr) {
    try {
      int price = double.parse(priceStr).toInt();
      String result = price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      return 'Rp $result';
    } catch (e) {
      if (priceStr.toUpperCase().contains('RP')) return priceStr;
      return 'Rp $priceStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DEFINISI PALET WARNA TEMA ---
    const Color cardColor = Color(0xFF1A2235); // Warna Card Navy Terang
    const Color priceColor = Color(0xFF00BFA5); // Hijau Tosca

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15), // Supaya efek klik ripple melengkung rapi
      child: Container(
        decoration: BoxDecoration(
          color: cardColor, // Mengubah card putih menjadi navy gelap
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ratakan teks ke kiri
          children: [
            
            // --- BAGIAN GAMBAR ---
            Expanded(
              child: ClipRRect(
                // Melengkungkan HANYA sudut atas gambar
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  "http://192.168.115.151:8000/products/${product.image}",
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF0B1221), // Latar gelap saat gagal muat
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            // --- BAGIAN TEKS INFORMASI PRODUK ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Nama Produk
                  Text(
                    product.name,
                    maxLines: 1, // Dibatasi 1 baris
                    overflow: TextOverflow.ellipsis, // Jika kepanjangan jadi "..."
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Harga Produk
                  Text(
                    formatRupiah(product.price.toString()),
                    style: const TextStyle(
                      color: priceColor, // Hijau Tosca
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  
                  // Sedikit jarak bawah agar teks tidak terlalu menempel ke tepi card
                  const SizedBox(height: 4), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../data/cart_data.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Fungsi Lokal untuk membuat format mata uang dengan titik (.) tanpa package tambahan
  String formatRupiah(dynamic number) {
    String value = number.toString().split('.')[0]; // ambil angka bulatnya saja
    if (value.length <= 3) return value;

    String formatted = "";
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      count++;
      formatted = value[i] + formatted;
      if (count % 3 == 0 && i != 0) {
        formatted = '.$formatted';
      }
    }
    return formatted;
  }

  double getTotal() {
    double total = 0;
    for (var item in CartData.items) {
      total +=
          (double.tryParse(item["price"].toString()) ?? 0) * (item["qty"] ?? 1);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengubah sedikit background agar card putih terlihat lebih stand-out/menyembul
      backgroundColor: Colors.grey.shade50,
      body: CartData.items.isEmpty
          ? const Center(
              child: Text(
                "Keranjang Masih Kosong",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: CartData.items.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      var item = CartData.items[index];
                      int currentQty = item["qty"] ?? 1;
                      double price =
                          double.tryParse(item["price"].toString()) ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        elevation:
                            1.5, // Mengurangi kepekatan shadow agar lebih clean
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// GAMBAR PRODUK
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "http://192.168.115.151:8000/products/${item["image"]}",
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 85,
                                      height: 85,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),

                              /// INFORMASI PRODUK
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Menggunakan Row agar nama produk dan tombol hapus sejajar rapi
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["name"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // Tombol Hapus ditaruh di pojok kanan atas card
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              CartData.items.removeAt(index);
                                            });
                                          },
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.grey.shade600,
                                            size: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rp ${formatRupiah(price)}",
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// TOMBOL PENGATUR KUANTITAS (- / +)
                                    Row(
                                      children: [
                                        _buildQtyButton(
                                          icon: Icons.remove,
                                          onTap: () {
                                            if (currentQty > 1) {
                                              setState(() {
                                                item["qty"] = currentQty - 1;
                                              });
                                            }
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            "$currentQty",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _buildQtyButton(
                                          icon: Icons.add,
                                          onTap: () {
                                            setState(() {
                                              item["qty"] = currentQty + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// BOTTOM SUMMARY & TOTAL BELANJA
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top:
                        false, // Menghindari overflow jika dijalankan di hp berponi bawah
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Belanja",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors
                                    .black54, // Sudah aman dari error merah karena didukung const lengkap
                              ),
                            ),
                            Text(
                              "Rp ${formatRupiah(getTotal())}",
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    20, // Diperbesar sedikit agar kontras menonjol
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            /// Nanti ke CheckoutPage
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutPage(),
                                ),
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Checkout",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper Widget Khusus Tombol Minus dan Plus Lingkaran Ringan
  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          color: Colors.white,
        ),
        child: Icon(icon, size: 16, color: Colors.grey.shade800),
      ),
    );
  }
}

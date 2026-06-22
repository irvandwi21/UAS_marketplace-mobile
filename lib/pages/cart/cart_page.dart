import 'package:flutter/material.dart';
import '../../data/cart_data.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // --- PALET WARNA (Tema Dark Mode Tetap Konsisten) ---
  static const Color _bgColor = Color(0xFF0B1221);       // Dark Navy pekat
  static const Color _cardColor = Color(0xFF1A2235);     // Warna Card Produk
  static const Color _bottomNavColor = Color(0xFF111827); // Warna panel bawah
  static const Color _accentColor = Color(0xFF2979FF);    // Biru Neon
  static const Color _priceColor = Color(0xFF00BFA5);     // Hijau Tosca
  static const Color _redAccent = Color(0xFFFF5252);      // Merah untuk tombol hapus

  @override
  void initState() {
    super.initState();
    // Memastikan setiap item memiliki field "selected", default = true jika belum ada
    for (var item in CartData.items) {
      item["selected"] ??= true;
    }
  }

  // Fungsi format mata uang Rupiah tanpa package tambahan
  String formatRupiah(dynamic number) {
    if (number == null) return "0";
    String value = number.toString().split('.')[0];
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

  // Menghitung total belanja HANYA untuk produk yang dicentang (selected == true)
  double getTotal() {
    double total = 0;
    for (var item in CartData.items) {
      if (item["selected"] == true) {
        total += (double.tryParse(item["price"].toString()) ?? 0) * (item["qty"] ?? 1);
      }
    }
    return total;
  }

  // Menghitung jumlah jenis produk yang sedang dicentang
  int getSelectedCount() {
    return CartData.items.where((item) => item["selected"] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Keranjang Belanja",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: CartData.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Keranjang Masih Kosong",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ayo temukan hardware impianmu!",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
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
                      bool isSelected = item["selected"] ?? true;
                      int currentQty = item["qty"] ?? 1;
                      double price = double.tryParse(item["price"].toString()) ?? 0;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // Agar checkbox sejajar vertikal di tengah row
                            children: [
                              /// 1. CHECKBOX (Di sebelah kiri gambar produk)
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Colors.grey[600],
                                ),
                                child: Checkbox(
                                  value: isSelected,
                                  activeColor: _accentColor,
                                  checkColor: Colors.white,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      item["selected"] = value ?? false;
                                    });
                                  },
                                ),
                              ),

                              /// 2. GAMBAR PRODUK
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  "http://192.168.115.151:8000/products/${item["image"]}",
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 85,
                                      height: 85,
                                      color: _bottomNavColor,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),

                              /// 3. INFORMASI PRODUK
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["name"] ?? "Produk",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        // Tombol Hapus Item
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              CartData.items.removeAt(index);
                                            });
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: _redAccent,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Rp ${formatRupiah(price)}",
                                      style: const TextStyle(
                                        color: _priceColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

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
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            "$currentQty",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
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
                                          isAdd: true,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: const BoxDecoration(
                    color: _bottomNavColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // Baris Informasi Dipilih X Produk
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dipilih: ${getSelectedCount()} Produk",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Belanja",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              "Rp ${formatRupiah(getTotal())}",
                              style: const TextStyle(
                                color: _priceColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Filter item yang dicentang
                              final selectedItems = CartData.items.where((item) => item["selected"] == true).toList();

                              // Validasi jika tidak ada produk yang dicentang
                              if (selectedItems.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Silakan pilih produk terlebih dahulu"),
                                    backgroundColor: _redAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              // Kirim ke CheckoutPage
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutPage(
                                    selectedItems: selectedItems,
                                  ),
                                )
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                              shadowColor: _accentColor.withOpacity(0.4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Checkout",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios_rounded, size: 16),
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

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isAdd = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isAdd ? _accentColor : Colors.grey.shade700,
            width: 1.5,
          ),
          color: isAdd ? _accentColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAdd ? _accentColor : Colors.white,
        ),
      ),
    );
  }
}
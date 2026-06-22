import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../data/cart_data.dart';

class CheckoutPage extends StatefulWidget {
  final List selectedItems;

  const CheckoutPage({super.key, required this.selectedItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController hpController = TextEditingController();

  String paymentMethod = "COD";

  // --- FUNGSI FORMAT RUPIAH ---
  String formatRupiah(dynamic number) {
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

  Future<void> buatPesanan() async {
    if (namaController.text.isEmpty ||
        hpController.text.isEmpty ||
        alamatController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi data penerima")));
      return;
    }

    bool sukses = await OrderService().createMultiItemOrder(
      customerName: namaController.text,
      phone: hpController.text,
      address: alamatController.text,
      paymentMethod: paymentMethod,
      items: CartData.items,
    );

    if (!mounted) return;

    if (sukses) {
      CartData.items.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pesanan berhasil dibuat")));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pesanan gagal dibuat")));
    }
  }

  double getTotal() {
    double total = 0;

    for (var item in widget.selectedItems) {
      total +=
          (double.tryParse(item["price"].toString()) ?? 0) * (item["qty"] ?? 1);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    // --- DEFINISI PALET WARNA (KONSISTEN DENGAN TEMA) ---
    const Color bgColor = Color(0xFF0B1221); // Dark Navy pekat
    const Color cardColor = Color(0xFF1A2235); // Warna Input/Card
    const Color accentColor = Color(0xFF2979FF); // Biru Neon
    const Color priceColor = Color(0xFF00BFA5); // Hijau Tosca

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER DATA PENERIMA ---
            const Text(
              "Data Penerima",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // --- INPUT FORM ---
            _buildCustomTextField(
              controller: namaController,
              label: "Nama Lengkap",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),

            _buildCustomTextField(
              controller: hpController,
              label: "Nomor HP",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _buildCustomTextField(
              controller: alamatController,
              label: "Alamat Lengkap",
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            // --- DROPDOWN METODE PEMBAYARAN ---
            DropdownButtonFormField<String>(
              value: paymentMethod,
              dropdownColor: cardColor, // Agar menu pop-up juga berwarna gelap
              style: const TextStyle(color: Colors.white, fontSize: 15),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              decoration: InputDecoration(
                labelText: "Metode Pembayaran",
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(
                  Icons.payment_outlined,
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: accentColor, width: 1.5),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "COD",
                  child: Text("COD (Bayar di Tempat)"),
                ),
                DropdownMenuItem(
                  value: "Transfer Bank",
                  child: Text("Transfer Bank"),
                ),
                DropdownMenuItem(value: "DANA", child: Text("DANA")),
                DropdownMenuItem(value: "OVO", child: Text("OVO")),
                DropdownMenuItem(value: "GoPay", child: Text("GoPay")),
              ],
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            // --- HEADER RINGKASAN BELANJA ---
            const Text(
              "Ringkasan Belanja",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // --- KOTAK RINGKASAN ITEM ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ...widget.selectedItems.map((item) {
                    double itemPrice =
                        double.tryParse(item["price"].toString()) ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Qty: ${item["qty"]}",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Rp ${formatRupiah(itemPrice)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  Divider(
                    color: Colors.white.withOpacity(0.1),
                    height: 20,
                    thickness: 1,
                  ),

                  // Total Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Bayar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Rp ${formatRupiah(getTotal())}",
                        style: const TextStyle(
                          color: priceColor, // Hijau Tosca
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- TOMBOL BUAT PESANAN ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: buatPesanan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded Corners
                  ),
                  elevation: 4,
                  shadowColor: accentColor.withOpacity(0.4),
                ),
                child: const Text(
                  "BUAT PESANAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK TEXTFIELD BIAR RAPI ---
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A2235), // Card Color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2979FF),
            width: 1.5,
          ), // Accent Color
        ),
      ),
    );
  }
}

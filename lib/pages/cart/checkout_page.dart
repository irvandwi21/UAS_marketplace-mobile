import 'package:flutter/material.dart';
import '../../data/cart_data.dart';
import '../../services/order_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController namaController = TextEditingController();

  final TextEditingController alamatController = TextEditingController();

  final TextEditingController hpController = TextEditingController();

  String paymentMethod = "COD";

  Future<void> buatPesanan() async {
    if (namaController.text.isEmpty ||
        hpController.text.isEmpty ||
        alamatController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi data penerima")));
      return;
    }

    bool sukses = true;

    for (var item in CartData.items) {
      bool result = await OrderService().createOrder(
        customerName: namaController.text,
        phone: hpController.text,
        address: alamatController.text,
        productName: item["name"],
        qty: item["qty"],
        totalPrice:
            (double.tryParse(item["price"].toString()) ?? 0) * item["qty"],
        paymentMethod: paymentMethod,
      );

      if (!result) {
        sukses = false;
      }
    }

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

    for (var item in CartData.items) {
      total +=
          (double.tryParse(item["price"].toString()) ?? 0) * (item["qty"] ?? 1);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Data Penerima",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: hpController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Nomor HP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: alamatController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Alamat Lengkap",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: paymentMethod,
              decoration: const InputDecoration(
                labelText: "Metode Pembayaran",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "COD", child: Text("COD")),
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

            const SizedBox(height: 25),

            const Text(
              "Ringkasan Belanja",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...CartData.items.map((item) {
              return ListTile(
                title: Text(item["name"]),
                subtitle: Text("Qty : ${item["qty"]}"),
                trailing: Text("Rp ${item["price"]}"),
              );
            }),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${getTotal().toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: buatPesanan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Buat Pesanan",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataDiriPage extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final String currentAddress;

  const DataDiriPage({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentAddress,
  });

  @override
  State<DataDiriPage> createState() => _DataDiriPageState();
}

class _DataDiriPageState extends State<DataDiriPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool isLoading = false;

  // Pastikan IP ini sama dengan yang ada di home_page.dart
  final String baseUrl = "http://192.168.115.151:8000/api";

  @override
  void initState() {
    super.initState();
    // Mengisi input field dengan data saat ini yang dikirim dari halaman profil
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);

    // Hilangkan teks placeholder jika belum diatur
    phoneController = TextEditingController(
      text:
          widget.currentPhone == "Belum mengatur No. HP" ||
              widget.currentPhone == "-"
          ? ""
          : widget.currentPhone,
    );
    addressController = TextEditingController(
      text:
          widget.currentAddress == "Belum mengatur alamat" ||
              widget.currentAddress == "-"
          ? ""
          : widget.currentAddress,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // --- FUNGSI UPDATE DATA KE LARAVEL ---
  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // Menggunakan rute PUT /settings/profile sesuai dengan api.php kamu
      var response = await http.put(
        Uri.parse("$baseUrl/settings/profile"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "address": addressController.text,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Data diri berhasil diperbarui",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman sebelumnya dan kirim sinyal 'true' agar halaman Home me-refresh data
        Navigator.pop(context, true);
      } else {
        var data = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Gagal memperbarui data"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error update profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan koneksi"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA DARK MODE PREMIUM ---
    const Color bgColor = Color(0xFF0B1221);
    const Color cardColor = Color(0xFF1A2235);
    const Color accentColor = Color(0xFF2979FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Data Diri",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Perbarui Informasi Akun",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pastikan data diri Anda valid agar proses transaksi dan pengiriman berjalan lancar.",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            _buildInputField(
              "Nama Lengkap",
              Icons.person_outline,
              nameController,
              cardColor,
              accentColor,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              "Alamat Email",
              Icons.email_outlined,
              emailController,
              cardColor,
              accentColor,
              isEmail: true,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              "Nomor Telepon",
              Icons.phone_android,
              phoneController,
              cardColor,
              accentColor,
              isPhone: true,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              "Alamat Lengkap",
              Icons.location_on_outlined,
              addressController,
              cardColor,
              accentColor,
              maxLines: 3,
            ),

            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: accentColor.withOpacity(0.4),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER TEXTFIELD ---
  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller,
    Color cardColor,
    Color accentColor, {
    bool isEmail = false,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone ? TextInputType.phone : TextInputType.text),
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: cardColor,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? 45.0 : 0,
          ), // Adjust icon position for textarea
          child: Icon(icon, color: Colors.grey[500]),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}

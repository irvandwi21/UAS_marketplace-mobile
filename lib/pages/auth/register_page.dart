import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String message = "";
  String baseUrl = "http://192.168.115.151:8000/api";

  Future<void> register() async {
    print("===== REGISTER DIKLIK =====");

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        message = "Semua field wajib diisi";
      });
      return;
    }

    try {
      print("Request ke : $baseUrl/register");

      var response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      print("Status Code : ${response.statusCode}");
      print("Response : ${response.body}");

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Register berhasil")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        setState(() {
          message = data["message"] ?? "Register gagal";
        });
      }
    } catch (e) {
      print("ERROR REGISTER");
      print(e);

      setState(() {
        message = "Gagal koneksi ke server";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DEFINISI PALET WARNA KONSISTEN DENGAN LOGIN PAGE ---
    const Color backgroundColor = Color(
      0xFF0D1527,
    ); // Biru tua pekat (Dark Navy)
    const Color cardColor = Color(
      0xFF17233F,
    ); // Biru navy semi-terang untuk text field
    const Color primaryAccent = Color(0xFF2979FF); // Biru Neon (Electric Blue)
    const Color secondaryAccent = Color(
      0xFFFF2E93,
    ); // Pink/Fuchsia Neon untuk error

    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar dibuat transparan agar menyatu halus dengan tema gelap
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Header Text Modern & Elegan
            const Text(
              "Create Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sign up to start exploring premium products",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 35),

            // Input Field Nama
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nama",
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: cardColor,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Shape dominan round (16px)
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: primaryAccent,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Input Field Email
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: cardColor,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: primaryAccent,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Input Field Password
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: cardColor,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: primaryAccent,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Tombol Register Premium dengan Glow Shadow Biru Neon
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: primaryAccent.withOpacity(0.4),
                ),
                child: const Text(
                  "REGISTER",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Kotak Alert Pesan Error (Menggunakan Fuchsia/Pink Neon)
            if (message.isNotEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: secondaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: secondaryAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: secondaryAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Navigasi Kembali ke Login dengan RichText yang Selaras
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
                child: RichText(
                  text: const TextSpan(
                    text: "Sudah punya akun? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

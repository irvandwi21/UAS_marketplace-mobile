import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final bool fromCheckout;

  const LoginPage({super.key, this.fromCheckout = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String message = "";
  String baseUrl = "http://192.168.115.151:8000/api";

  Future<void> login() async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);

        if (!mounted) return;

        // LOGIN DARI CHECKOUT
        if (widget.fromCheckout) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        setState(() {
          message = data["message"] ?? "Email atau Password Salah";
        });
      }
    } catch (e) {
      setState(() {
        message = "Gagal konek ke server";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DEFINISI PALET WARNA SESUAI KARAKTERISTIK UI ---
    const Color backgroundColor = Color(
      0xFF0D1527,
    ); // Biru tua pekat (Dark Navy)
    const Color cardColor = Color(
      0xFF17233F,
    ); // Biru navy sedikit terang untuk input field
    const Color primaryAccent = Color(0xFF2979FF); // Biru Neon (Electric Blue)
    const Color secondaryAccent = Color(
      0xFFFF2E93,
    ); // Pink/Fuchsia Neon untuk error/aksen

    return Scaffold(
      backgroundColor: backgroundColor,
      // Membuat AppBar transparan agar menyatu dengan background body yang elegan
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
            const SizedBox(height: 20),

            // Header Text Bergaya Modern & Premium
            const Text(
              "Welcome Back",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Login to access your premium marketplace account",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Input Field Email (Karakteristik: Rounded, Filled, Elegan)
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
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Shape dominan round
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: primaryAccent,
                    width: 1.5,
                  ), // Aksen Biru saat diklik
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
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Shape dominan round
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

            // Tombol Login Premium (Rounded Pill dengan Efek Glow Halus)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent, // Warna Biru Neon
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Sudut bulat konsisten
                  ),
                  elevation: 4,
                  shadowColor: primaryAccent.withOpacity(
                    0.4,
                  ), // Efek bayangan biru tipis
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Pesan Error (Menggunakan warna Fuchsia/Pink Neon agar terlihat kontras & modern)
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

            // Link Register bergaya RichText (Teks abu-abu, kata kunci berwarna Biru Neon)
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
                child: RichText(
                  text: const TextSpan(
                    text: "Belum punya akun? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Register",
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

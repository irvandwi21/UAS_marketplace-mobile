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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Marketplace"),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 30),

            TextField(
              controller: emailController,

              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,

              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: login,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(15),
                ),

                child: const Text(
                  "LOGIN",

                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (message.isNotEmpty)
              Text(
                message,

                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },

              child: const Text("Belum punya akun? Register"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product_model.dart';
import '../../services/api_service.dart';

import '../../widgets/product_card.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/category_item.dart';

import '../auth/login_page.dart';
import '../cart/cart_page.dart';
import '../product/product_detail_page.dart';
import '../profil/data_diri_page.dart'; // <--- IMPORT HALAMAN DATA DIRI

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  // --- DEFINISI PALET WARNA UTAMA ---
  final Color bgColor = const Color(0xFF0B1221);
  final Color bottomNavColor = const Color(0xFF111827);
  final Color accentColor = const Color(0xFF2979FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Marketplace Hardware",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: [
        const HomeContent(),
        const CartPage(),
        const ProfilePage(),
      ][currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: bottomNavColor,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.home),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.shopping_cart),
            ),
            label: "Keranjang",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.person_outline),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.person),
            ),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}

// ==========================================
// KONTEN HALAMAN HOME (PRODUK & FILTER)
// ==========================================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Product> allProducts = [];
  List<Product> displayedProducts = [];
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    try {
      final data = await ApiService().getProducts();
      setState(() {
        allProducts = data;
        displayedProducts = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD PRODUCT: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      displayedProducts = allProducts.where((product) {
        final matchSearch = product.name.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        final matchCategory =
            selectedCategory.isEmpty ||
            product.name.toLowerCase().contains(selectedCategory.toLowerCase());
        return matchSearch && matchCategory;
      }).toList();
    });
  }

  Future<void> buyNow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage(fromCheckout: true)),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Lanjut ke Checkout")));
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF2979FF);
    const Color searchBarColor = Color(0xFF1A2235);

    return SingleChildScrollView(
      child: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                searchQuery = value;
                _applyFilters();
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search laptops, GPUs...",
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 22,
                ),
                filled: true,
                fillColor: searchBarColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: accentColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: BannerSlider(),
          ),
          const SizedBox(height: 28),

          // HEADER KATEGORI
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // LIST KATEGORI
          SizedBox(
            height: 105,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSelectableCategory(
                  "Processor",
                  Icons.memory,
                  const Color(0xFF2979FF),
                ),
                _buildSelectableCategory(
                  "Storage",
                  Icons.storage,
                  const Color(0xFF00BFA5),
                ),
                _buildSelectableCategory(
                  "Monitor",
                  Icons.monitor,
                  const Color(0xFFFF2E93),
                ),
                _buildSelectableCategory(
                  "RAM",
                  Icons.developer_board,
                  const Color(0xFF9D00FF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // HEADER PRODUK & VIEW ALL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Products",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = "";
                        searchQuery = "";
                        searchController.clear();
                        _applyFilters();
                      });
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // GRID PRODUK
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: accentColor),
            )
          else if (displayedProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                "Produk tidak ditemukan",
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final product = displayedProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                            id: product.id,
                            name: product.name,
                            price: product.price.toString(),
                            description: product.description,
                            image: product.image,
                          ),
                        ),
                      );
                    },
                    onBuy: buyNow,
                  );
                },
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSelectableCategory(
    String title,
    IconData icon,
    Color neonColor,
  ) {
    bool isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = isSelected ? "" : title;
          _applyFilters();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: neonColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: CategoryItem(icon: icon, title: title, iconColor: neonColor),
      ),
    );
  }
}

// ==========================================
// KONTEN HALAMAN PROFIL (INFO AKUN & API)
// ==========================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String userPhone = "-";
  String userAddress = "-";
  bool isLoading = true;

  // Base URL (Pastikan IP Address ini sudah benar)
  final String baseUrl = "http://192.168.115.151:8000/api";

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  Future<void> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token != null) {
      try {
        var response = await http.get(
          Uri.parse("$baseUrl/profile"),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (mounted) {
            setState(() {
              userName = data['name'] ?? "User";
              userEmail = data['email'] ?? "Email tidak tersedia";
              userPhone = data['phone'] ?? "Belum mengatur No. HP";
              userAddress = data['address'] ?? "Belum mengatur alamat";
              isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => isLoading = false);
        }
      } catch (e) {
        print("Error fetch profile: $e");
        if (mounted) setState(() => isLoading = false);
      }
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token != null) {
      try {
        await http.post(
          Uri.parse("$baseUrl/logout"),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );
      } catch (e) {
        print("Gagal hit logout server: $e");
      }
    }

    await prefs.remove("token");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0B1221);
    const Color cardColor = Color(0xFF1A2235);
    const Color redAccent = Color(0xFFFF5252);
    const Color blueAccent = Color(0xFF2979FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: blueAccent))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU INFORMASI PENGGUNA
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: blueAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: blueAccent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      color: Colors.grey[400],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        userEmail,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.grey[400],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        userAddress,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // TOMBOL EDIT MEMBUKA HALAMAN DATA DIRI
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DataDiriPage(
                                    currentName: userName,
                                    currentEmail: userEmail,
                                    currentPhone: userPhone,
                                    currentAddress: userAddress,
                                  ),
                                ),
                              ).then((isUpdated) {
                                if (isUpdated == true) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  getUserProfile();
                                }
                              });
                            },
                            icon: Icon(
                              Icons.edit_square,
                              color: blueAccent.withOpacity(0.8),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Text(
                      "Pengaturan Akun",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // KOTAK MENU PENGATURAN
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: "Data Diri",
                            onTap: () {
                              // NAVIGASI KE DATA DIRI PAGE
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DataDiriPage(
                                    currentName: userName,
                                    currentEmail: userEmail,
                                    currentPhone: userPhone,
                                    currentAddress: userAddress,
                                  ),
                                ),
                              ).then((isUpdated) {
                                if (isUpdated == true) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  getUserProfile();
                                }
                              });
                            },
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 1,
                            thickness: 1,
                          ),
                          _buildMenuItem(
                            icon: Icons.location_on_outlined,
                            title: "Daftar Alamat",
                            onTap: () {},
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 1,
                            thickness: 1,
                          ),
                          _buildMenuItem(
                            icon: Icons.credit_card_outlined,
                            title: "Metode Pembayaran",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // TOMBOL LOGOUT
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: logout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: redAccent,
                          size: 20,
                        ),
                        label: const Text(
                          "KELUAR DARI AKUN",
                          style: TextStyle(
                            color: redAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: redAccent, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Colors.grey[400], size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.grey[600],
        size: 16,
      ),
      onTap: onTap,
    );
  }
}

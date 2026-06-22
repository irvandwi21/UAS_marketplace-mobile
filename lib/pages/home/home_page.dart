import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product_model.dart';
import '../../services/api_service.dart';

import '../../widgets/product_card.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/category_item.dart';

import '../auth/login_page.dart';
import '../cart/cart_page.dart';
import '../product/product_detail_page.dart';

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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Variabel untuk menyimpan master data dari API
  List<Product> allProducts = [];
  // Variabel untuk data yang dirender ke layar (hasil filter)
  List<Product> displayedProducts = [];

  bool isLoading = true;

  // Variabel state untuk filter
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
        allProducts = data; // Simpan data asli
        displayedProducts = data; // Tampilkan data awal
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD PRODUCT:");
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  // --- FUNGSI UNTUK MELAKUKAN FILTER DATA ---
  void _applyFilters() {
    setState(() {
      displayedProducts = allProducts.where((product) {
        // 1. Cek Pencarian (Search) dari inputan teks
        final matchSearch = product.name.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );

        // 2. Cek Kategori berdasarkan NAMA PRODUK
        final matchCategory =
            selectedCategory.isEmpty ||
            product.name.toLowerCase().contains(selectedCategory.toLowerCase());

        // Tampilkan produk yang cocok
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
          // KARTU MEMBER DIHAPUS - Langsung masuk ke Search Bar
          // --- SEARCH BAR FUNGSIONAL ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                searchQuery = value;
                _applyFilters(); // Panggil fungsi filter saat mengetik
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

          // HEADER: Categories
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

          // --- LIST KATEGORI FUNGSIONAL ---
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

          // HEADER: Featured Products & View All (BISA DIKLIK)
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
                      // KETIKA DIKLIK: Reset semua filter & search
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

          // LOADING STATE & GRID PRODUK
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

  // --- WIDGET HELPER UNTUK KATEGORI YANG BISA DIKLIK ---
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Profile", style: TextStyle(color: Colors.white)),
    );
  }
}

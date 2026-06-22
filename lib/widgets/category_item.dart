import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor; // Tambahan properti warna neon

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor, // Menjadikan properti ini wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Disesuaikan agar proporsional
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mengubah CircleAvatar menjadi Container bersudut bulat (Rounded Square)
          // agar selaras dengan karakteristik UI dari gambar referensimu
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15), // Background warna neon tapi transparan
              borderRadius: BorderRadius.circular(16), // Shape dominan round (16px)
            ),
            child: Icon(
              icon,
              color: iconColor, // Warna ikon mengikuti parameter warna neon
              size: 28,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Mengubah warna teks menjadi putih agar terlihat jelas di dark mode
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            maxLines: 1, // Mencegah teks terlalu panjang merusak layout
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
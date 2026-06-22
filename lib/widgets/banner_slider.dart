import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> bannerImages = [
      "assets/images/banner1.png",
      "assets/images/banner2.jpg",
      "assets/images/banner3.jpg",
      "assets/images/banner4.jpg",
      "assets/images/banner5.png",
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        viewportFraction: 1,
        autoPlay: true,
      ),

      items: bannerImages.map((image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),

          child: Image.asset(image, fit: BoxFit.cover, width: double.infinity),
        );
      }).toList(),
    );
  }
}

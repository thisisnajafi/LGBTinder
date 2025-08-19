import 'package:flutter/material.dart';

class LGBTinderLogo extends StatelessWidget {
  final double height;
  final double? width;
  const LGBTinderLogo({Key? key, this.height = 40, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/logo.png', // You should place your logo image here
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
} 
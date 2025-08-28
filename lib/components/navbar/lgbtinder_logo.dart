import 'package:flutter/material.dart';

class LGBTinderLogo extends StatelessWidget {
  final double height;
  final double? width;
  final double? size;
  
  const LGBTinderLogo({
    Key? key, 
    this.height = 40, 
    this.width,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finalHeight = size ?? height;
    final finalWidth = size ?? width ?? finalHeight;
    
    return Image.asset(
      'assets/logo/logo.png', // You should place your logo image here
      height: finalHeight,
      width: finalWidth,
      fit: BoxFit.contain,
    );
  }
} 
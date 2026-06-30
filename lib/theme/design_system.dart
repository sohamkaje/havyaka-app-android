import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HAAColors {
  static const charcoal = Color(0xFF1A1612);
  static const deepBrown = Color(0xFF2C1F0E);
  static const orange = Color(0xFFC8530A);
  static const orangeLight = Color(0xFFF5E8DF);
  static const gold = Color(0xFFB87D1A);
  static const goldLight = Color(0xFFFDF3E0);
  static const cream = Color(0xFFFDFAF6);
  static const warmWhite = Color(0xFFFFFFFF);
  static const border = Color(0x59E8D8B0);
  static const muted = Color(0xFF6B5B4B);
  static const mutedLight = Color(0xFFA89070);
  static const heroText = Color(0xFFF5E8C0);
  static const vedicBg = Color(0xFFFDF3E0);
  static const vedicFg = Color(0xFF8A5A10);
  static const culturalBg = Color(0xFFF5E8DF);
  static const culturalFg = Color(0xFF8A3A10);
  static const socialBg = Color(0xFFE1F5EE);
  static const socialFg = Color(0xFF0F5E3A);
  static const ceremonyBg = Color(0xFFE6F1FB);
  static const ceremonyFg = Color(0xFF185FA5);
  static const success = Color(0xFF1D9E75);
  static const successBg = Color(0xFFE8F8F0);
}

class HAASpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
}

class HAARadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 50.0;
}

class HAAFonts {
  static TextStyle serif(double size, {FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.notoSerif(fontSize: size, fontWeight: weight);
  }

  static TextStyle sans(double size, {FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontSize: size, fontWeight: weight, fontFamily: 'Roboto');
  }
}

class HAACard extends StatelessWidget {
  const HAACard({super.key, required this.child, this.padding = HAASpacing.lg});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: HAAColors.warmWhite,
        borderRadius: BorderRadius.circular(HAARadius.lg),
        border: Border.all(color: HAAColors.border, width: 0.5),
      ),
      child: child,
    );
  }
}

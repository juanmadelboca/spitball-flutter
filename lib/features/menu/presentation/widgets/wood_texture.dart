import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WoodTexture extends StatelessWidget {
  const WoodTexture({super.key});

  @override
  Widget build(BuildContext context) {
    const String svgString = '''
    <svg width="280" height="60" viewBox="0 0 280 60" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- Base color of the button -->
        <rect width="280" height="60" fill="#a1662f"/>
        
        <!-- Top highlight for 3D effect -->
        <rect width="280" height="3" fill="#b7804a"/>
        
        <!-- Bottom shadow for 3D effect -->
        <rect y="57" width="280" height="3" fill="#8a5420"/>

        <!-- Subtle horizontal lines for wood grain -->
        <line x1="0" y1="15" x2="280" y2="15" stroke="#8a5420" stroke-width="1.5"/>
        <line x1="0" y1="30" x2="280" y2="30" stroke="#8a5420" stroke-width="1"/>
        <line x1="0" y1="45" x2="280" y2="45" stroke="#8a5420" stroke-width="1.5"/>
    </svg>
    ''';

    return SvgPicture.string(
      svgString,
      fit: BoxFit.fill,
    );
  }
}

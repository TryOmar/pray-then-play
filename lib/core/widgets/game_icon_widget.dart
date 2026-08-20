import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameIconWidget extends StatelessWidget {
  final String iconName;
  final double size;
  final int fallbackColor;

  const GameIconWidget({
    super.key,
    required this.iconName,
    this.size = 36,
    this.fallbackColor = 0xFF00E5FF,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = Color(fallbackColor);
    final pngPath = 'assets/icons/$iconName.png';
    final svgPath = 'assets/icons/$iconName.svg';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: brandColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: brandColor.withValues(alpha: 0.38),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: brandColor.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: Image.asset(
          pngPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Padding(
              padding: EdgeInsets.all(size * 0.16),
              child: SvgPicture.asset(
                svgPath,
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.sports_esports_rounded,
                      color: brandColor,
                      size: size * 0.55,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}



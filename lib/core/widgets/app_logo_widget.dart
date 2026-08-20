import 'package:flutter/material.dart';

enum AppLogoVariant {
  iconOnly,
  compact,
  horizontal,
}

class AppLogoWidget extends StatelessWidget {
  final double size;
  final AppLogoVariant variant;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? playColor;
  final bool showGlow;
  final bool isMonochrome;

  const AppLogoWidget({
    super.key,
    this.size = 40,
    this.variant = AppLogoVariant.iconOnly,
    this.primaryColor,
    this.secondaryColor,
    this.playColor,
    this.showGlow = false,
    this.isMonochrome = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = primaryColor ??
        (isMonochrome
            ? (isDark ? Colors.white : const Color(0xFF0F172A))
            : theme.primaryColor);

    final secondary = secondaryColor ??
        (isMonochrome
            ? primary
            : (isDark ? const Color(0xFF3B82F6) : const Color(0xFFE11D48)));

    final play = playColor ??
        (isMonochrome
            ? primary
            : (isDark ? const Color(0xFF00F0FF) : const Color(0xFFF97316)));

    final markWidget = Container(
      width: size,
      height: size,
      decoration: showGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: size * 0.4,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _PrayThenPlayLogoPainter(
          primaryColor: primary,
          secondaryColor: secondary,
          playColor: play,
          isMonochrome: isMonochrome,
        ),
      ),
    );

    if (variant == AppLogoVariant.iconOnly) {
      return markWidget;
    }

    if (variant == AppLogoVariant.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          markWidget,
          SizedBox(width: size * 0.25),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: theme.colorScheme.onSurface,
              ),
              children: [
                const TextSpan(text: 'P'),
                TextSpan(
                  text: 'T',
                  style: TextStyle(color: primary),
                ),
                const TextSpan(text: 'P'),
              ],
            ),
          ),
        ],
      );
    }

    // Horizontal full lockup
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        markWidget,
        SizedBox(width: size * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  const TextSpan(text: 'Pray '),
                  TextSpan(
                    text: 'Then ',
                    style: TextStyle(color: primary),
                  ),
                  const TextSpan(text: 'Play'),
                ],
              ),
            ),
            Text(
              'STAY ON TIME • PLAY PEACEFULLY',
              style: TextStyle(
                fontSize: (size * 0.18).clamp(8.0, 11.0),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                    const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrayThenPlayLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color playColor;
  final bool isMonochrome;

  _PrayThenPlayLogoPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.playColor,
    required this.isMonochrome,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradient or flat shader for P
    final Shader pShader = isMonochrome
        ? (LinearGradient(colors: [primaryColor, primaryColor])
            .createShader(Rect.fromLTWH(0, 0, w, h)))
        : (LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor],
          ).createShader(Rect.fromLTWH(0, 0, w, h)));

    final stemPaint = Paint()
      ..shader = pShader
      ..style = PaintingStyle.fill;

    final archPaint = Paint()
      ..shader = pShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final playPaint = Paint()
      ..color = playColor
      ..style = PaintingStyle.fill;

    // 1. Draw Geometric P Stem (left pillar)
    final stemRadius = Radius.circular(w * 0.065);
    final stemRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, w * 0.14, w * 0.13, h * 0.72),
      stemRadius,
    );
    canvas.drawRRect(stemRect, stemPaint);

    // 2. Draw Geometric P Loop (Upper rounded arch)
    final archPath = Path();
    final startX = w * 0.22;
    final topY = h * 0.205;
    final loopRight = w * 0.82;
    final bottomY = h * 0.535;

    archPath.moveTo(startX, topY);
    archPath.lineTo(w * 0.52, topY);
    archPath.cubicTo(
      loopRight,
      topY,
      loopRight,
      bottomY,
      w * 0.52,
      bottomY,
    );
    archPath.lineTo(startX, bottomY);
    canvas.drawPath(archPath, archPaint);

    // 3. Draw Forward Play Triangle fused into the loop core
    final playPath = Path();
    final playLeft = w * 0.44;
    final playTop = h * 0.28;
    final playRight = w * 0.63;
    final playCenterY = h * 0.37;
    final playBottom = h * 0.46;

    playPath.moveTo(playLeft, playTop);
    playPath.lineTo(playRight, playCenterY);
    playPath.lineTo(playLeft, playBottom);
    playPath.close();

    canvas.drawPath(playPath, playPaint);
  }

  @override
  bool shouldRepaint(covariant _PrayThenPlayLogoPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.playColor != playColor ||
        oldDelegate.isMonochrome != isMonochrome;
  }
}

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// The kitenge thread — the app's single visual signature.
///
/// A 10px diagonal repeating stripe of gold, clay and forest that runs across
/// the top of every screen (under the status bar/AppBar), tying the app back
/// to the woven fabric patterns savings groups already recognise. Purely
/// decorative, so it is excluded from semantics.
class KitengeThread extends StatelessWidget {
  const KitengeThread({super.key, this.height = 10});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _KitengePainter(height)),
      ),
    );
  }
}

class _KitengePainter extends CustomPainter {
  _KitengePainter(this.height);

  final double height;

  static const double _bandWidth = 14;
  static final List<Color> _colours = [
    AppColors.gold,
    AppColors.clay,
    AppColors.forest,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Slide the start left so the pattern tiles seamlessly across the width.
    for (double x = -height; x < size.width + height; x += _bandWidth * 3) {
      for (var b = 0; b < 3; b++) {
        final x0 = x + b * _bandWidth;
        paint.color = _colours[b];
        final path = Path()
          ..moveTo(x0, 0)
          ..lineTo(x0 + _bandWidth, 0)
          ..lineTo(x0 + _bandWidth + height, height)
          ..lineTo(x0 + height, height)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KitengePainter oldDelegate) =>
      oldDelegate.height != height;
}
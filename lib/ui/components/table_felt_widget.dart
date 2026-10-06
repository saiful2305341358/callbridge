import 'package:flutter/material.dart';
import '../../models/game_state.dart';

class TableFeltWidget extends StatelessWidget {
  final TableFeltTheme theme;
  final Widget child;

  const TableFeltWidget({
    super.key,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.darkColor,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            theme.lightColor,
            theme.baseColor,
            theme.darkColor,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Subtle circular felt ring markings
          Positioned.fill(
            child: CustomPaint(
              painter: FeltTablePainter(accentGold: theme.accentGold),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class FeltTablePainter extends CustomPainter {
  final Color accentGold;

  FeltTablePainter({required this.accentGold});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDim = size.shortestSide;

    // Faint outer decorative oval / circle
    final outerPaint = Paint()
      ..color = accentGold.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, minDim * 0.38, outerPaint);

    // Inner dashed ring
    final innerPaint = Paint()
      ..color = accentGold.withAlpha(35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, minDim * 0.28, innerPaint);
  }

  @override
  bool shouldRepaint(covariant FeltTablePainter oldDelegate) =>
      oldDelegate.accentGold != accentGold;
}

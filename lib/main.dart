import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GaugeView(),
    );
  }
}

class GaugeView extends StatelessWidget {
  const GaugeView({super.key});

  @override
  Widget build(BuildContext context) {
    const widthPainter = 240.0; // min width: 180
    const percentage = 80; // 0-100

    return Scaffold(
      backgroundColor: const Color(0xff11131e),
      body: Center(
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              tween: Tween(begin: 0, end: 1),
              builder: (_, val, __) {
                return SizedBox(
                  height: widthPainter / 2,
                  width: widthPainter,
                  child: CustomPaint(
                    painter: IndicatorPainter(
                      value: val * (1 / 100 * percentage),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                ),
                child: Column(
                  children: const [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Daily Activity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.75,
                      child: Text(
                        'You are awesome!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IndicatorPainter extends CustomPainter {
  IndicatorPainter({
    required this.value,
    this.strokeWidth = 24,
    this.blur = 5,
    this.color = const Color(0xffdafb43),
    this.baseColor = const Color(0xff191c26),
    this.blurColor = Colors.black,
    this.blurOpacity = 0.5,
  }) : assert(value >= 0 && value <= 1, 'value no valid');

  final double value;
  final double strokeWidth;
  final double blur;
  final Color color;
  final Color baseColor;
  final Color blurColor;
  final double blurOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    Paint getPaint(Color color, {bool isBlur = false, bool base = false}) {
      return Paint()
        ..color = color
        ..strokeWidth =
            isBlur ? strokeWidth - 4 : (base ? strokeWidth - 2 : strokeWidth)
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isBlur ? blur : 0)
        ..style = PaintingStyle.stroke;
    }

    double angleToRadian(double angle) {
      return angle * (pi / 180);
    }
    
    // use sizeOval/2 for center rotation
    Offset getOffset(double angle, double radius, double sizeOval) {
      final rotationAwareAngle = 180 + angle;
      final radian = angleToRadian(rotationAwareAngle);
      final x = cos(radian) * radius + radius - (sizeOval / 2);
      final y = sin(radian) * radius + radius - (sizeOval / 2);

      return Offset(x, y);
    }

    // base shadow
    final paintBaseS =
        getPaint(blurColor.withOpacity(blurOpacity), isBlur: true);
    // 4: offset.y for shadow effect
    canvas.drawArc(
      const Offset(0, 4) & Size(size.width, size.width),
      -pi,
      pi,
      false,
      paintBaseS,
    );

    // base color
    final paintBase = getPaint(baseColor, base: true);
    canvas.drawArc(
      Offset.zero & Size(size.width, size.width),
      -pi,
      pi,
      false,
      paintBase,
    );

    // oval gradient large
    final sizeOvalLg = strokeWidth * 1.5; // 150% of strokeWith
    final offsetSize = getOffset(180 * value, size.height, sizeOvalLg) &
        Size(sizeOvalLg, sizeOvalLg);

    final paintOvalLg = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        offsetSize.topCenter,
        offsetSize.bottomCenter,
        [color, color.withOpacity(0.05)],
        [0.3, 1],
      );

    canvas.drawOval(
      offsetSize,
      paintOvalLg,
    );

    // primary painter
    final paintPrimary = getPaint(color);
    final angle = pi * value;
    canvas.drawArc(
      Offset.zero & Size(size.width, size.width),
      -pi,
      angle,
      false,
      paintPrimary,
    );

    // oval base small
    final paintOvalSm = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    final sizeOvalSm = strokeWidth * 0.5; // 50% of strokeWith
    canvas.drawOval(
      getOffset(180 * value, size.height, sizeOvalSm) &
          Size(sizeOvalSm, sizeOvalSm),
      paintOvalSm,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

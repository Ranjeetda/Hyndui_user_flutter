import 'package:flutter/cupertino.dart';

class CustomTabIndicator extends Decoration {
  final Color color;
  final double radius;

  const CustomTabIndicator({required this.color, this.radius = 8});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(color: color, radius: radius);
  }
}

class _CustomPainter extends BoxPainter {
  final Color color;
  final double radius;

  _CustomPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Offset circleOffset = offset +
        Offset(config.size!.width / 2, config.size!.height - radius);

    canvas.drawCircle(circleOffset, radius, paint);
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'colors.dart';

class GlassBackground extends StatefulWidget {
  final Widget child;
  final int numberOfShapes;

  const GlassBackground({
    super.key,
    required this.child,
    this.numberOfShapes = 12,
  });

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground> {
  List<_ShapeData>? _shapes;
  Size _lastSize = Size.zero;

  List<_ShapeData> _generateShapes(double width, double height) {
    final random = Random(42);
    final colors = [
      ColorsMain.secondary,
      ColorsMain.primary,
      ColorsMain.gradEnd,
      ColorsMain.gradStart,
    ];

    return List.generate(widget.numberOfShapes, (index) {
      return _ShapeData(
        top: random.nextDouble() * (height + 100) - 50,
        left: random.nextDouble() * (width + 100) - 50,
        size: random.nextDouble() * 160 + 80,
        color: colors[random.nextInt(colors.length)],
        opacity: random.nextDouble() * 0.25 + 0.1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: ColorsMain.backgroundGradient,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final currentSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (_shapes == null || (_lastSize != currentSize && currentSize.width > 0)) {
            _lastSize = currentSize;
            _shapes = _generateShapes(currentSize.width, currentSize.height);
          }

          return Stack(
            children: [
              ..._shapes!.map((shape) {
                return Positioned(
                  top: shape.top,
                  left: shape.left,
                  child: Container(
                    width: shape.size,
                    height: shape.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: shape.color.withOpacity(shape.opacity),
                    ),
                  ),
                );
              }),

              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class _ShapeData {
  final double top;
  final double left;
  final double size;
  final Color color;
  final double opacity;

  _ShapeData({
    required this.top,
    required this.left,
    required this.size,
    required this.color,
    required this.opacity,
  });
}
import 'package:flutter/material.dart';

class TemplateButtonTI extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? func;

  final Color backColor;
  final Color ictColor;

  const TemplateButtonTI({super.key, required this.label, required this.icon, required this.func, required this.backColor, required this.ictColor});

  @override
  Widget build(BuildContext context) {

    return ElevatedButton.icon(
      onPressed: func,
      label: Text(label),
      icon: Icon(icon),

      style: ElevatedButton.styleFrom(
        backgroundColor: backColor,
        foregroundColor: ictColor,
      )
    );
  }
}

class TemplateButtonIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? func;
  final double iconSize;

  final Color backColor;
  final Color ictColor;

  const TemplateButtonIcon({super.key, required this.icon, required this.iconSize, required this.func, required this.backColor, required this.ictColor});

  @override
  Widget build(BuildContext context) {

    return IconButton(
        onPressed: func,
        icon: Icon(icon),
        iconSize: iconSize,

        style: IconButton.styleFrom(
          backgroundColor: backColor,
          foregroundColor: ictColor,
        )
    );
  }
}
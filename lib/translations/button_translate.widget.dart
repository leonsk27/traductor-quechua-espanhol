import 'package:flutter/material.dart';

// Widget personalizado para los botones
Widget buildTranslateButton({
  required IconData icon,
  required String text,
  required Color colorBack,
  required Color colorFont,
  required VoidCallback onTap,
}) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorBack,
      foregroundColor: colorFont,
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    icon: Icon(icon),
    label: Text(text),
    onPressed: onTap,
  );
}

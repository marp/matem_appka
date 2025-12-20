import 'package:flutter/material.dart';

import '../const/colors.dart';

class ResultMessage extends StatelessWidget {
  final String message;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback onTap;
  final IconData icon;
  final Color? accentColor;

  const ResultMessage({
    super.key,
    required this.message,
    this.subtitle,
    this.buttonText,
    required this.onTap,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Colors.deepPurple;
    final surface = Colors.deepPurple.shade400;
    final accent = accentColor ?? Colors.white;

    return AlertDialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: whiteTextStyle.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: greyTextStyle.copyWith(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.25,
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(Icons.arrow_back, size: 20),
                label: Text(
                  buttonText ?? 'OK',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: surface,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

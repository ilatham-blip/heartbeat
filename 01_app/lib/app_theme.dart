import 'package:flutter/material.dart';

// ─── Shared Color Constants ───
const kBackgroundColor = Color(0xFFFAFAFA);
const kBrandBlue = Color(0xFF1E40AF);

// ─── Reusable Gradient Button ───
class HeartbeatButton extends StatelessWidget {
  const HeartbeatButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradientColors,
    this.shadowColor,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final Color? shadowColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? const [Color(0xFF1E40AF), Color(0xFF3B82F6)];
    final shadow = shadowColor ?? colors.first.withValues(alpha: 0.35);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: onPressed == null
              ? colors.map((c) => c.withValues(alpha: 0.5)).toList()
              : colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

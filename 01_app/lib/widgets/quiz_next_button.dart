import 'package:flutter/material.dart';

class QuizNextButton extends StatelessWidget {
  const QuizNextButton({
    super.key,
    required this.onPressed,
    this.label = 'Next',
    this.isSaving = false,
    this.icon = Icons.arrow_forward,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isSaving;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(isSaving ? 'Saving...' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F7CFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          disabledBackgroundColor: const Color(0xFF4F7CFF).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

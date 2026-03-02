import 'package:flutter/material.dart';

class QuizBottomBar extends StatelessWidget {
  const QuizBottomBar({
    super.key,
    required this.onPause,
    required this.onStop,
    this.onBack,
  });

  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pause / Stop
          _SmallActionButton(
            icon: Icons.pause,
            label: 'Pause',
            onTap: onPause,
          ),
          const SizedBox(width: 8),
          _SmallActionButton(
            icon: Icons.stop,
            label: 'Stop',
            onTap: onStop,
            danger: true,
          ),

          const Spacer(),

          // Back
          if (onBack != null) ...[
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE53935) : Colors.black54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

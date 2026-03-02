import 'package:flutter/material.dart';

class QuizNavigationControls extends StatelessWidget {
  const QuizNavigationControls({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    this.onBack,
    required this.onNext,
    required this.onPause,
    required this.onStop,
  });

  final bool isFirst;
  final bool isLast;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback onPause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              if (!isFirst)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ),
                ),
              if (!isFirst) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLast
                        ? const Color(0xFF43A047)
                        : const Color(0xFF4F7CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isLast ? 'Save Log' : 'Next',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: onPause,
                icon: const Icon(Icons.pause, size: 20, color: Colors.black54),
                label: const Text('Pause',
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
              ),
              const SizedBox(width: 24),
              TextButton.icon(
                onPressed: onStop,
                icon:
                    const Icon(Icons.stop, size: 20, color: Color(0xFFE53935)),
                label: const Text('Stop',
                    style: TextStyle(
                        color: Color(0xFFE53935), fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

Color scoreColor(int? score) {
  if (score == null) return Colors.grey;
  if (score >= 75) return const Color(0xFF1E8E3E);
  if (score >= 50) return const Color(0xFF7CB342);
  if (score >= 25) return const Color(0xFFF29900);
  return const Color(0xFFD93025);
}

/// Pastille ronde avec la note sur 100.
class ScoreBadge extends StatelessWidget {
  final int? score;
  final double size;
  const ScoreBadge({super.key, required this.score, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: scoreColor(score), shape: BoxShape.circle),
      child: Text(
        score?.toString() ?? '?',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.38),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme.dart';

export '../theme.dart' show scoreColor, scoreOnColor;

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
            color: scoreOnColor(score),
            fontWeight: FontWeight.bold,
            fontSize: size * 0.38),
      ),
    );
  }
}

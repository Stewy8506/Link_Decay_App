import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/freshness.dart';

/// An animated, color-coded horizontal bar indicating freshness score (0–1).
/// This is the primary intentional color element in the UI.
class FreshnessBar extends StatelessWidget {
  const FreshnessBar({
    super.key,
    required this.score,
    this.height = 3.0,
    this.showLabel = false,
    this.animate = true,
  });

  final double score;
  final double height;
  final bool showLabel;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final color = freshnessColor(score);
    final label = freshnessLabel(score);
    final cs = Theme.of(context).colorScheme;

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background track — neutral border color, not the freshness tint
              Container(
                height: height,
                width: constraints.maxWidth,
                color: cs.outline.withValues(alpha: 0.5),
              ),
              // Filled portion — the one colorful element
              AnimatedContainer(
                duration: animate ? kDurationSlow : Duration.zero,
                curve: Curves.easeOutCubic,
                height: height,
                width: constraints.maxWidth * score.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (!showLabel) return bar;

    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: kSpaceSM),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

/// A compact circular freshness indicator for tight spaces.
class FreshnessDot extends StatelessWidget {
  const FreshnessDot({super.key, required this.score, this.size = 8.0});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: freshnessColor(score),
        shape: BoxShape.circle,
      ),
    );
  }
}

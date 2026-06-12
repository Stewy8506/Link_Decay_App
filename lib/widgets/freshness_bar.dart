import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/freshness.dart';

/// An animated, color-coded horizontal bar indicating freshness score (0–1).
/// Features rounded track ends and a subtle pulse animation when critically low (< 15%).
class FreshnessBar extends StatefulWidget {
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
  State<FreshnessBar> createState() => _FreshnessBarState();
}

class _FreshnessBarState extends State<FreshnessBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.score < 0.15) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FreshnessBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score < 0.15) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = freshnessColor(widget.score);
    final label = freshnessLabel(widget.score);
    final cs = Theme.of(context).colorScheme;

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(widget.height),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * widget.score.clamp(0.0, 1.0);
          final filledBar = AnimatedContainer(
            duration: widget.animate ? kDurationSlow : Duration.zero,
            curve: Curves.easeOutCubic,
            height: widget.height,
            width: barWidth,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(widget.height),
            ),
          );

          return Stack(
            children: [
              Container(
                height: widget.height,
                width: constraints.maxWidth,
                color: cs.outline.withValues(alpha: 0.5),
              ),
              if (widget.score < 0.15)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _pulseAnimation.value,
                      child: filledBar,
                    );
                  },
                )
              else
                filledBar,
            ],
          );
        },
      ),
    );

    if (!widget.showLabel) return bar;

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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/google_fonts.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Page View Content ──────────────────────────────────────────────
          PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _WelcomeSlide(isActive: _currentPage == 0),
              _DecaySlide(isActive: _currentPage == 1),
              _AutomationSlide(isActive: _currentPage == 2),
              _NotificationSlide(
                isActive: _currentPage == 3,
                onDone: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                  );
                },
              ),
              _PrivacySlide(isActive: _currentPage == 4),
            ],
          ),

          // ── Skip Button (Top Right) ────────────────────────────────────────
          if (_currentPage < 4)
            Positioned(
              top: topPadding + kSpaceSM,
              right: kSpaceMD,
              child: TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: cs.onSurface.withValues(alpha: 0.5),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // ── Bottom Navigation Controls ─────────────────────────────────────
          Positioned(
            left: kSpaceMD,
            right: kSpaceMD,
            bottom: bottomPadding + kSpaceMD,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots Indicator
                Row(
                  children: List.generate(5, (index) {
                    final active = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? cs.onSurface
                            : cs.outline.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                // Next / Get Started Button
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (_currentPage < 4) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          ref
                              .read(onboardingCompletedProvider.notifier)
                              .completeOnboarding();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.onSurface,
                        foregroundColor: cs.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: _currentPage == 4 ? 24 : 16,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: _currentPage == 4
                            ? Text(
                                'Get Started',
                                key: const ValueKey('get_started'),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                key: ValueKey('arrow'),
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Concentric Circles Base Widget ───────────────────────────────────────────
Widget _buildConcentricCircles(BuildContext context, {required Widget child}) {
  final cs = Theme.of(context).colorScheme;
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.15),
            width: 1,
          ),
          shape: BoxShape.circle,
        ),
      ),
      Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          shape: BoxShape.circle,
        ),
      ),
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Center(child: child),
      ),
    ],
  );
}

// ── Dashed Circle Custom Painter for Welcome Slide ───────────────────────────
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const int dashCount = 20;
    final double dashWidth = (2 * pi * radius) / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = (i * 2 * pi) / dashCount;
      final double sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color;
}

// ── Slide 1: Welcome Slide ───────────────────────────────────────────────────
class _WelcomeSlide extends StatefulWidget {
  final bool isActive;
  const _WelcomeSlide({required this.isActive});

  @override
  State<_WelcomeSlide> createState() => _WelcomeSlideState();
}

class _WelcomeSlideState extends State<_WelcomeSlide>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _textController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    if (widget.isActive) {
      _textController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _WelcomeSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _textController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _textController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _rotationController,
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _DashedCirclePainter(
                    color: cs.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: cs.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: cs.outline.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.bookmark_border_rounded,
                      color: cs.onSurface.withValues(alpha: 0.6),
                      size: 44,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) => Opacity(
              opacity: _textFade.value,
              child: FractionalTranslation(
                translation: _textSlide.value,
                child: child,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Your inbox is decaying.',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'LinkShelf keeps it clean. Read links before they rot.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 2: Decay Badges Slide ──────────────────────────────────────────────
class _DecaySlide extends StatefulWidget {
  final bool isActive;
  const _DecaySlide({required this.isActive});

  @override
  State<_DecaySlide> createState() => _DecaySlideState();
}

class _DecaySlideState extends State<_DecaySlide>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimations = List.generate(3, (index) {
      final start = index * 0.15;
      final end = start + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _DecaySlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDecayBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildConcentricCircles(
            context,
            child: SizedBox(
              width: 80,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 1,
                    color: cs.outline.withValues(alpha: 0.5),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kFreshnessHigh,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kFreshnessMid,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kFreshnessLow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Fresh. Fading. Stale.',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Track the age of your links at a glance. Read or archive them before decay sets in.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimations[0],
                child: _buildDecayBadge('Fresh', kFreshnessHigh, Colors.black),
              ),
              const SizedBox(width: 8),
              ScaleTransition(
                scale: _scaleAnimations[1],
                child: _buildDecayBadge('Fading', kFreshnessMid, Colors.black),
              ),
              const SizedBox(width: 8),
              ScaleTransition(
                scale: _scaleAnimations[2],
                child: _buildDecayBadge('Stale', kFreshnessLow, Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Slide 3: Smart Organization ──────────────────────────────────────────────
class _AutomationSlide extends StatefulWidget {
  final bool isActive;
  const _AutomationSlide({required this.isActive});

  @override
  State<_AutomationSlide> createState() => _AutomationSlideState();
}

class _AutomationSlideState extends State<_AutomationSlide>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _slideAnimations = List.generate(3, (index) {
      final start = index * 0.15;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0.0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _opacityAnimations = List.generate(3, (index) {
      final start = index * 0.15;
      final end = start + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _AutomationSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTagChip(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildConcentricCircles(
            context,
            child: Icon(
              Icons.label_outline_rounded,
              color: cs.onSurface.withValues(alpha: 0.6),
              size: 40,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Smart tagging.',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Zero effort required. Links are automatically classified by source category and reading time.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimations[0].value,
                  child: FractionalTranslation(
                    translation: _slideAnimations[0].value,
                    child: _buildTagChip(context, 'Article'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimations[1].value,
                  child: FractionalTranslation(
                    translation: _slideAnimations[1].value,
                    child: _buildTagChip(context, 'Video'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimations[2].value,
                  child: FractionalTranslation(
                    translation: _slideAnimations[2].value,
                    child: _buildTagChip(context, '⚡ 5 min read'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Slide 4: Notifications Slide ─────────────────────────────────────────────
class _NotificationSlide extends StatefulWidget {
  final bool isActive;
  final VoidCallback onDone;
  const _NotificationSlide({required this.isActive, required this.onDone});

  @override
  State<_NotificationSlide> createState() => _NotificationSlideState();
}

class _NotificationSlideState extends State<_NotificationSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  late Animation<double> _bellRotation;
  bool _requested = false;
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bellRotation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: -0.15),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -0.15, end: 0.15),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.15, end: -0.1),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -0.1, end: 0.1),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.1, end: 0.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _bellController, curve: Curves.easeInOut),
        );

    if (widget.isActive) {
      _startBellWiggleLoop();
    }
  }

  void _startBellWiggleLoop() async {
    while (mounted && widget.isActive && !_requested) {
      await _bellController.forward();
      _bellController.reset();
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  void didUpdateWidget(covariant _NotificationSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startBellWiggleLoop();
    } else if (!widget.isActive && oldWidget.isActive) {
      _bellController.stop();
      _bellController.reset();
    }
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    setState(() => _requested = true);
    final granted = await NotificationService.instance.requestPermissions();
    setState(() {
      _granted = granted;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildConcentricCircles(
            context,
            child: AnimatedBuilder(
              animation: _bellRotation,
              builder: (context, child) => Transform.rotate(
                angle: _bellRotation.value,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _requested
                      ? (_granted
                            ? const Icon(
                                Icons.check_circle_outline_rounded,
                                color: kFreshnessHigh,
                                size: 44,
                                key: ValueKey('granted'),
                              )
                            : Icon(
                                Icons.notifications_active_rounded,
                                color: cs.primary,
                                size: 40,
                                key: const ValueKey('denied'),
                              ))
                      : Icon(
                          Icons.notifications_none_rounded,
                          color: cs.onSurface.withValues(alpha: 0.6),
                          size: 40,
                          key: const ValueKey('bell'),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Stay on track.',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Get notified before your links rot. Enable alerts for a daily check-in and weekly digests.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: SizedBox(
              height: 48,
              child: _requested
                  ? Center(
                      child: Text(
                        _granted
                            ? '✓ Notification Access Enabled'
                            : 'Access Denied (Continuing...)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _granted
                              ? kFreshnessHigh
                              : cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: _request,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.outline, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Enable Notifications',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 5: Privacy Slide with Custom Locking Padlock Painter ────────────────
class _PrivacySlide extends StatefulWidget {
  final bool isActive;
  const _PrivacySlide({required this.isActive});

  @override
  State<_PrivacySlide> createState() => _PrivacySlideState();
}

class _PrivacySlideState extends State<_PrivacySlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _lockController;
  late Animation<double> _lockAnimation;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _lockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.easeOutBack),
    );

    if (widget.isActive) {
      _lockController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _PrivacySlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _lockController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _lockController.reset();
    }
  }

  @override
  void dispose() {
    _lockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildConcentricCircles(
            context,
            child: AnimatedBuilder(
              animation: _lockAnimation,
              builder: (context, child) => CustomPaint(
                size: const Size(60, 60),
                painter: _LockPainter(
                  shackleProgress: _lockAnimation.value,
                  bodyColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  outlineColor: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Offline first.',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your reading lists never leave this device. No servers, no tracking, complete privacy.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Custom Locking Padlock Painter ───────────────────────────────────────────
class _LockPainter extends CustomPainter {
  final double shackleProgress; // 0.0 (open) to 1.0 (closed)
  final Color bodyColor;
  final Color outlineColor;

  _LockPainter({
    required this.shackleProgress,
    required this.bodyColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = outlineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final shacklePaint = Paint()
      ..color = outlineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // Shackle logic:
    // Open state: translated up by 8px and rotated open by ~14 degrees (0.25 radians).
    // Locked state: translated up by 0px, rotated 0 degrees.
    final double shackleYOffset = (1.0 - shackleProgress) * -8.0;
    final double shackleRotation = (1.0 - shackleProgress) * 0.25;

    canvas.save();
    canvas.translate(w * 0.35, h * 0.45);
    canvas.rotate(shackleRotation);
    canvas.translate(-w * 0.35, -h * 0.45 + shackleYOffset);

    final shacklePath = Path()
      ..moveTo(w * 0.35, h * 0.45)
      ..lineTo(w * 0.35, h * 0.30)
      ..arcTo(
        Rect.fromCircle(center: Offset(w * 0.5, h * 0.30), radius: w * 0.15),
        pi,
        pi,
        false,
      )
      ..lineTo(w * 0.65, h * 0.30 + (shackleProgress * (h * 0.15)));

    canvas.drawPath(shacklePath, shacklePaint);
    canvas.restore();

    // Lock Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.42, w * 0.40, h * 0.32),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, outlinePaint);

    // Keyhole
    final keyholePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.5, h * 0.54), 3, keyholePaint);
    final stemPath = Path()
      ..moveTo(w * 0.48, h * 0.54)
      ..lineTo(w * 0.52, h * 0.54)
      ..lineTo(w * 0.53, h * 0.62)
      ..lineTo(w * 0.47, h * 0.62)
      ..close();
    canvas.drawPath(stemPath, keyholePaint);
  }

  @override
  bool shouldRepaint(covariant _LockPainter oldDelegate) {
    return shackleProgress != oldDelegate.shackleProgress ||
        bodyColor != oldDelegate.bodyColor ||
        outlineColor != oldDelegate.outlineColor;
  }
}

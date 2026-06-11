import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';

/// Bottom sheet for snooze options.
class SnoozeSheet extends ConsumerWidget {
  const SnoozeSheet({super.key, required this.linkId});

  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceMD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text(
              'Snooze for',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: kSpaceXS),
            Text(
              'Decay pauses while snoozed.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: kSpaceLG),
            _SnoozeOption(
              icon: Icons.bedtime_outlined,
              label: '1 day',
              sublabel: 'Back tomorrow',
              duration: const Duration(days: 1),
              linkId: linkId,
            ),
            const SizedBox(height: kSpaceSM),
            _SnoozeOption(
              icon: Icons.calendar_view_week_outlined,
              label: '3 days',
              sublabel: 'Back in 3 days',
              duration: const Duration(days: 3),
              linkId: linkId,
            ),
            const SizedBox(height: kSpaceSM),
            _SnoozeOption(
              icon: Icons.calendar_month_outlined,
              label: '1 week',
              sublabel: 'Back next week',
              duration: const Duration(days: 7),
              linkId: linkId,
            ),
            const SizedBox(height: kSpaceSM),
            _CustomSnoozeOption(
              linkId: linkId,
            ),
            const SizedBox(height: kSpaceMD),
          ],
        ),
      ),
    );
  }
}

class _SnoozeOption extends ConsumerWidget {
  const _SnoozeOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.duration,
    required this.linkId,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Duration duration;
  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusMD),
        splashColor: cs.onSurface.withValues(alpha: 0.05),
        onTap: () async {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
          await ref
              .read(linkActionsProvider.notifier)
              .snooze(linkId, duration);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Snoozed for $label'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(kSpaceMD),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.outline.withValues(alpha: 0.25),
                      cs.outline.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(kRadiusSM),
                  border: Border.all(
                    color: cs.outline.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: cs.onSurface.withValues(alpha: 0.75),
                  size: 20,
                ),
              ),
              const SizedBox(width: kSpaceMD),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.25),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomSnoozeOption extends ConsumerWidget {
  const _CustomSnoozeOption({required this.linkId});

  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusMD),
        splashColor: cs.onSurface.withValues(alpha: 0.05),
        onTap: () async {
          HapticFeedback.lightImpact();
          final now = DateTime.now();
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: now.add(const Duration(days: 1)),
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context),
                child: child!,
              );
            },
          );

          if (!context.mounted) return;

          if (selectedDate != null) {
            final snoozeUntil = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              9, // default standard return time (9 AM)
            );
            final difference = snoozeUntil.difference(now);
            if (difference.isNegative) return;

            Navigator.of(context).pop();
            await ref.read(linkActionsProvider.notifier).snooze(linkId, difference);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Snoozed until ${_formatDate(snoozeUntil)}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(kSpaceMD),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.outline.withValues(alpha: 0.25),
                      cs.outline.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(kRadiusSM),
                  border: Border.all(
                    color: cs.outline.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.date_range_outlined,
                  color: cs.onSurface.withValues(alpha: 0.75),
                  size: 20,
                ),
              ),
              const SizedBox(width: kSpaceMD),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Date...',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    'Choose a specific return date',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.25),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

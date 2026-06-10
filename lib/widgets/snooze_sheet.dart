import 'package:flutter/material.dart';
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
                  color: kBorderDark,
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
                color: kTextPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: kSpaceXS),
            Text(
              'Decay pauses while snoozed.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: kTextSecondary,
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
    return Material(
      color: kCardDark,
      borderRadius: BorderRadius.circular(kRadiusMD),
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusMD),
        onTap: () async {
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
                  color: kAccentMuted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(kRadiusSM),
                ),
                child: Icon(icon, color: kAccentMuted, size: 20),
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
                      color: kTextPrimary,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: kTextTertiary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

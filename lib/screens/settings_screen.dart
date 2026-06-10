import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: kBackgroundDark,
            expandedHeight: 100,
            collapsedHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceMD),
              title: Text(
                'Settings',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.6,
                  height: 1.0,
                ),
              ),
            ),
          ),
          settingsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: kAccent)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $e', style: TextStyle(color: kFreshnessLow)),
              ),
            ),
            data: (settings) {
              final halfLife = settings?.halfLifeDays ?? kDefaultHalfLifeDays;
              final threshold = settings?.notificationThreshold ??
                  kDefaultNotificationThreshold;
              final notificationsOn =
                  settings?.notificationsEnabled ?? kDefaultNotificationsEnabled;

              return SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: kSpaceSM),

                  // ── Decay ────────────────────────────────────────────
                  _SectionHeader(label: 'Decay'),
                  _SettingCard(
                    children: [
                      _SliderRow(
                        icon: Icons.timer_outlined,
                        label: 'Half-life',
                        sublabel:
                            'Links are 50% fresh after ${halfLife.toStringAsFixed(0)} days',
                        value: halfLife,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(halfLifeDays: v);
                        },
                        valueLabel: '${halfLife.toStringAsFixed(0)} days',
                      ),
                    ],
                  ),

                  // ── Notifications ────────────────────────────────────
                  _SectionHeader(label: 'Notifications'),
                  _SettingCard(
                    children: [
                      _SwitchRow(
                        icon: Icons.notifications_outlined,
                        label: 'Daily reminders',
                        sublabel: 'Notified at 9 AM if links are stale',
                        value: notificationsOn,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(notificationsEnabled: v);
                        },
                      ),
                      const _Divider(),
                      _SliderRow(
                        icon: Icons.warning_amber_outlined,
                        label: 'Alert threshold',
                        sublabel:
                            'Notify when freshness drops below ${(threshold * 100).toStringAsFixed(0)}%',
                        value: threshold,
                        min: 0.05,
                        max: 0.9,
                        divisions: 17,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(notificationThreshold: v);
                        },
                        valueLabel: '${(threshold * 100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),

                  // ── Appearance ───────────────────────────────────────
                  _SectionHeader(label: 'Appearance'),
                  _SettingCard(
                    children: [
                      _SwitchRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark mode',
                        sublabel: 'Easier on the eyes at night',
                        value: settings?.isDarkMode ?? true,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(isDarkMode: v);
                        },
                      ),
                    ],
                  ),

                  // ── Freshness legend ─────────────────────────────────
                  _SectionHeader(label: 'Freshness Scale'),
                  _SettingCard(
                    children: [
                      _LegendRow(
                        color: kFreshnessHigh,
                        label: 'Fresh',
                        range: '> 66%',
                      ),
                      const _Divider(),
                      _LegendRow(
                        color: kFreshnessMid,
                        label: 'Fading',
                        range: '33% – 66%',
                      ),
                      const _Divider(),
                      _LegendRow(
                        color: kFreshnessLow,
                        label: 'Stale',
                        range: '< 33%',
                      ),
                      const _Divider(),
                      _LegendRow(
                        color: kFreshnessLow.withValues(alpha: 0.7),
                        label: 'Critical',
                        range: '< 25%',
                      ),
                    ],
                  ),

                  // ── About ────────────────────────────────────────────
                  _SectionHeader(label: 'About'),
                  _SettingCard(
                    children: [
                      _InfoRow(label: 'App', value: kAppName),
                      const _Divider(),
                      _InfoRow(label: 'Version', value: kAppVersion),
                      const _Divider(),
                      _InfoRow(
                        label: 'Storage',
                        value: 'Local SQLite (Drift)',
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Sub-components ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceSM),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: kTextTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: kBorderDark, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 0);
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.valueLabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceMD, kSpaceMD, kSpaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: kTextSecondary),
              const SizedBox(width: kSpaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
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
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  valueLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kAccent,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kTextSecondary),
          const SizedBox(width: kSpaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  sublabel,
                  style: GoogleFonts.inter(fontSize: 12, color: kTextSecondary),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.range,
  });

  final Color color;
  final String label;
  final String range;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: kSpaceMD),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kTextPrimary,
            ),
          ),
          const Spacer(),
          Text(
            range,
            style: GoogleFonts.inter(fontSize: 12, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kTextPrimary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}

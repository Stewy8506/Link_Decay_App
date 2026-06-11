import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';

import '../models/link_status.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';

class StatsDashboardPanel extends ConsumerWidget {
  const StatsDashboardPanel({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLinksAsync = ref.watch(allLinksProvider);
    final baseHalfLife = ref.watch(halfLifeDaysProvider);
    final decayCurveType = ref.watch(decayCurveTypeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return allLinksAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(kSpaceLG),
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (links) {
        if (links.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(kSpaceXL),
            alignment: Alignment.center,
            child: Text(
              'No stats available yet. Save and read links first!',
              style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.45)),
              textAlign: TextAlign.center,
            ),
          );
        }

        // ── Metrics Calculations ──────────────────────────────────────────
        final totalRead = links.where((l) => l.status == LinkStatus.read).length;
        final totalInbox = links.where((l) => l.status == LinkStatus.inbox).length;

        // Freshness Distribution
        int freshCount = 0;
        int fadingCount = 0;
        int staleCount = 0;
        final now = DateTime.now();

        for (final l in links.where((l) => l.status == LinkStatus.inbox)) {
          final score = computeFreshness(
            createdAt: l.createdAt,
            now: now,
            halfLifeDays: l.customHalfLifeDays ?? baseHalfLife,
            snoozedUntil: l.snoozedUntil,
            decayCurveType: decayCurveType,
          );
          if (score > 0.66) {
            freshCount++;
          } else if (score > 0.33) {
            fadingCount++;
          } else {
            staleCount++;
          }
        }

        // Top Domains
        final domainCounts = <String, int>{};
        for (final l in links) {
          domainCounts[l.domain] = (domainCounts[l.domain] ?? 0) + 1;
        }
        final sortedDomains = domainCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topDomains = sortedDomains.take(3).toList();

        // 7-Day Activity: Saved vs Read
        final savedActivity = List<int>.filled(7, 0);
        final readActivity = List<int>.filled(7, 0);
        final daysOfWeek = <String>[];

        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          daysOfWeek.add(_dayAbbreviation(date.weekday));
          
          // Count saved on this day
          savedActivity[6 - i] = links.where((l) => _isSameDay(l.createdAt, date)).length;
          
          // Count read on this day
          readActivity[6 - i] = links.where((l) => l.readAt != null && _isSameDay(l.readAt!, date)).length;
        }

        // Heatmap calculation (last 28 days)
        final dailyGoal = ref.watch(dailyReadingGoalProvider);
        final heatmapData = List<int>.filled(28, 0);
        final todayDateOnly = DateUtils.dateOnly(now);

        for (int i = 27; i >= 0; i--) {
          final date = todayDateOnly.subtract(Duration(days: i));
          heatmapData[27 - i] = links.where((l) => l.readAt != null && _isSameDay(l.readAt!, date)).length;
        }

        // Reading Streak
        final readDates = links
            .where((l) => l.readAt != null)
            .map((l) => DateUtils.dateOnly(l.readAt!))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

        int currentStreak = 0;
        if (readDates.isNotEmpty) {
          final today = DateUtils.dateOnly(now);
          final yesterday = today.subtract(const Duration(days: 1));
          
          if (readDates.contains(today) || readDates.contains(yesterday)) {
            currentStreak = 1;
            var checkDate = readDates.contains(today) ? today : yesterday;
            
            while (true) {
              checkDate = checkDate.subtract(const Duration(days: 1));
              if (readDates.contains(checkDate)) {
                currentStreak++;
              } else {
                break;
              }
            }
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: cs.outline, width: 0.5)),
          ),
          padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceSM, kSpaceMD, kSpaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title / Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined, size: 18, color: cs.onSurface),
                      const SizedBox(width: 8),
                      Text(
                        'Performance Insights',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                  )
                ],
              ),
              const Divider(height: 10),

              // Activity Chart
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kSpaceSM),
                child: Text(
                  'SAVED VS. READ (LAST 7 DAYS)',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.35),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildActivityBarChart(cs, daysOfWeek, savedActivity, readActivity),

              const SizedBox(height: kSpaceSM),

              // Grid Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(cs, 'Streak', '$currentStreak days', Icons.local_fire_department_outlined),
                  ),
                  const SizedBox(width: kSpaceSM),
                  Expanded(
                    child: _buildMetricCard(cs, 'Total Read', '$totalRead links', Icons.done_all),
                  ),
                  const SizedBox(width: kSpaceSM),
                  Expanded(
                    child: _buildMetricCard(cs, 'Inbox Active', '$totalInbox links', Icons.inbox_outlined),
                  ),
                ],
              ),

              const SizedBox(height: kSpaceSM),

              // Daily Reading Heatmap Grid
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'DAILY READING STREAK (GOAL: $dailyGoal/DAY)',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.35),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildHeatmapGrid(cs, heatmapData, dailyGoal),

              const SizedBox(height: kSpaceSM),

              // Freshness Distribution Progress Bar
              if (totalInbox > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'INBOX HEALTH',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.35),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildFreshnessDistribution(cs, totalInbox, freshCount, fadingCount, staleCount),
              ],

              // Top Domains list
              if (topDomains.isNotEmpty) ...[
                const SizedBox(height: kSpaceSM),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'TOP SOURCES',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.35),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: topDomains.map((e) {
                    return Chip(
                      label: Text('${e.key} (${e.value})'),
                      backgroundColor: cs.outline.withValues(alpha: 0.3),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      labelStyle: GoogleFonts.inter(fontSize: 11, color: cs.onSurface),
                    );
                  }).toList(),
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(ColorScheme cs, String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(kRadiusSM),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.45)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildFreshnessDistribution(
    ColorScheme cs,
    int total,
    int fresh,
    int fading,
    int stale,
  ) {
    final freshPct = fresh / total;
    final fadingPct = fading / total;
    final stalePct = stale / total;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(kRadiusSM),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        children: [
          // Stacked Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (fresh > 0) Expanded(flex: (freshPct * 100).round(), child: Container(color: kFreshnessHigh)),
                  if (fading > 0) Expanded(flex: (fadingPct * 100).round(), child: Container(color: kFreshnessMid)),
                  if (stale > 0) Expanded(flex: (stalePct * 100).round(), child: Container(color: kFreshnessLow)),
                ],
              ),
            ),
          ),
          const SizedBox(height: kSpaceSM),
          // Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendBadge(kFreshnessHigh, 'Fresh ($fresh)'),
              _buildLegendBadge(kFreshnessMid, 'Fading ($fading)'),
              _buildLegendBadge(kFreshnessLow, 'Stale ($stale)'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendBadge(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildHeatmapGrid(ColorScheme cs, List<int> heatmapData, int dailyGoal) {
    final weekLabels = ['3w ago', '2w ago', '1w ago', 'This wk'];
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(kRadiusSM),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(width: 50),
              ...List.generate(7, (i) => Expanded(
                child: Center(
                  child: Text(
                    dayLabels[i],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 6),
          ...List.generate(4, (weekIndex) {
            final label = weekLabels[weekIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: cs.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  ...List.generate(7, (dayIndex) {
                    final dataIndex = weekIndex * 7 + dayIndex;
                    final readCount = heatmapData[dataIndex];
                    
                    Color cellColor = cs.outline.withValues(alpha: 0.12);
                    if (readCount >= dailyGoal) {
                      cellColor = kFreshnessHigh;
                    } else if (readCount > 0) {
                      cellColor = kFreshnessHigh.withValues(
                        alpha: (readCount / dailyGoal).clamp(0.25, 0.75),
                      );
                    }

                    return Expanded(
                      child: Center(
                        child: Tooltip(
                          message: '$readCount read',
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: kSpaceMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '0 reads',
                style: GoogleFonts.inter(fontSize: 8.5, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: kFreshnessHigh.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Progress',
                style: GoogleFonts.inter(fontSize: 8.5, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: kFreshnessHigh,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Goal met ($dailyGoal+)',
                style: GoogleFonts.inter(fontSize: 8.5, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBarChart(
    ColorScheme cs,
    List<String> labels,
    List<int> saved,
    List<int> read,
  ) {
    int maxVal = 1;
    for (int i = 0; i < 7; i++) {
      if (saved[i] > maxVal) maxVal = saved[i];
      if (read[i] > maxVal) maxVal = read[i];
    }

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(kRadiusSM),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      padding: const EdgeInsets.all(kSpaceSM),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              return Container(
                height: 0.5,
                color: cs.outline.withValues(alpha: i == 3 ? 0.0 : 0.25),
              );
            }),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final sVal = saved[index];
                final rVal = read[index];

                final double sHt = (sVal / maxVal) * 65;
                final double rHt = (rVal / maxVal) * 65;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 6,
                            height: sHt.clamp(2.0, 65.0),
                            decoration: BoxDecoration(
                              color: cs.onSurface.withValues(alpha: 0.12),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: rHt.clamp(2.0, 65.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cs.primary,
                                  cs.primary.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _dayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'M';
      case DateTime.tuesday: return 'T';
      case DateTime.wednesday: return 'W';
      case DateTime.thursday: return 'T';
      case DateTime.friday: return 'F';
      case DateTime.saturday: return 'S';
      case DateTime.sunday: return 'S';
      default: return '';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'providers/providers.dart';
import 'screens/archive_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/constants.dart';

class ReadDecayApp extends ConsumerWidget {
  const ReadDecayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _selectedIndex = 0;

  static const _screens = [
    InboxScreen(),
    ArchiveScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Screen content
          AnimatedSwitcher(
            duration: kDurationNormal,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),

          // Floating pill navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingPillNavBar(
              selectedIndex: _selectedIndex,
              onTap: (i) {
                HapticFeedback.lightImpact();
                setState(() => _selectedIndex = i);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Pill Navigation Bar ─────────────────────────────────────────

class _FloatingPillNavBar extends StatelessWidget {
  const _FloatingPillNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.inbox_outlined, selectedIcon: Icons.inbox, label: 'Inbox'),
    _NavItem(icon: Icons.archive_outlined, selectedIcon: Icons.archive, label: 'Archive'),
    _NavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    // Outer pill colors — neutral, semi-transparent
    final pillBg = isDark
        ? const Color(0xFF1E1E1E).withValues(alpha: 0.92)
        : const Color(0xFFF0EFED).withValues(alpha: 0.92);
    final pillBorder = isDark
        ? const Color(0xFF2A2A2A).withValues(alpha: 0.6)
        : const Color(0xFFE0DFDD).withValues(alpha: 0.6);

    // Selected indicator pill — darker capsule behind active item
    final indicatorColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFD6D5D3);

    // Text/icon colors
    final selectedColor = isDark
        ? const Color(0xFFEDEDEC)
        : const Color(0xFF1C1917);
    final unselectedColor = isDark
        ? const Color(0xFF636363)
        : const Color(0xFF9C9A97);

    return Padding(
      // Float with margin from edges and bottom (respect safe area)
      padding: EdgeInsets.fromLTRB(40, 0, 40, 12 + bottomPadding),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: pillBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Animated indicator pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: _indicatorLeft(context),
                top: 6,
                bottom: 6,
                width: _indicatorWidth(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              // Nav items row
              Row(
                children: List.generate(_items.length, (i) {
                  final item = _items[i];
                  final isSelected = i == selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                key: ValueKey('${i}_$isSelected'),
                                size: 21,
                                color: isSelected ? selectedColor : unselectedColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? selectedColor : unselectedColor,
                                letterSpacing: 0.1,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _indicatorWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final pillWidth = screenWidth - 80; // 40px padding on each side
    return pillWidth / _items.length;
  }

  double _indicatorLeft(BuildContext context) {
    return _indicatorWidth(context) * selectedIndex;
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

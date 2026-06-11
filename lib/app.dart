import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'providers/providers.dart';
import 'screens/collections_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/constants.dart';
import 'utils/google_fonts.dart';
import 'widgets/add_link_sheet.dart';

class LinkShelfApp extends ConsumerWidget {
  const LinkShelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final activePalette = ref.watch(themePaletteProvider);
    final fontFamily = ref.watch(fontFamilyProvider);
    
    // Update global font family for local GoogleFonts delegator
    GoogleFonts.currentFont = fontFamily;
    final customAccentHex = ref.watch(customAccentColorProvider);
    final customBgHex = ref.watch(customBgColorProvider);

    final customAccentColor = parseHexColor(customAccentHex);
    final customBgColor = parseHexColor(customBgHex);

    return MaterialApp(
      title: kAppName,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(
        activePalette,
        customAccent: customAccentColor,
        customBg: customBgColor,
        fontFamily: fontFamily,
      ),
      darkTheme: buildDarkTheme(
        activePalette,
        customAccent: customAccentColor,
        customBg: customBgColor,
        fontFamily: fontFamily,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  int _selectedIndex = 0;

  static const _screens = [
    InboxScreen(),
    CollectionsScreen(), // Collections + Archive combined screen
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(widgetSyncProvider);
    final theme = Theme.of(context);
    final selectedIds = ref.watch(selectedLinkIdsProvider);

    final isMultiSelect = selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Screen content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.0, 0.03),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),

          // Bottom gradient fade overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: isMultiSelect ? 0.0 : 1.0,
              duration: kDurationNormal,
              curve: Curves.easeInOut,
              child: IgnorePointer(
                child: Container(
                  height: 140 + MediaQuery.of(context).viewPadding.bottom,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                        theme.scaffoldBackgroundColor,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating pill navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              offset: isMultiSelect ? const Offset(0, 1.5) : Offset.zero,
              duration: kDurationNormal,
              curve: Curves.easeInOut,
              child: _FloatingPillNavBar(
                selectedIndex: _selectedIndex,
                onTap: (i) {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedIndex = i);
                },
              ),
            ),
          ),

          // Floating Add Link FAB (placed on top of the bottom gradient fade overlay)
          Positioned(
            right: 16,
            bottom: 82 + MediaQuery.of(context).viewPadding.bottom,
            child: AnimatedScale(
              scale: (_selectedIndex == 0 && !isMultiSelect) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: (_selectedIndex == 0 && !isMultiSelect) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: _selectedIndex != 0 || isMultiSelect,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (_) => const AddLinkSheet(),
                        isScrollControlled: true,
                        useSafeArea: true,
                      );
                    },
                    backgroundColor: theme.colorScheme.onSurface,
                    foregroundColor: theme.colorScheme.surface,
                    elevation: 6,
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(
                      'Add link',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusXL),
                    ),
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

// ─── Floating Pill Navigation Bar ─────────────────────────────────────────

class _FloatingPillNavBar extends StatelessWidget {
  const _FloatingPillNavBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _navBarWidth = 260.0;
  static const _horizontalPadding = 6.0;

  static const _items = [
    _NavItem(
      icon: Icons.inbox_outlined,
      selectedIcon: Icons.inbox,
      label: 'Inbox',
    ),
    _NavItem(
      icon: Icons.folder_copy_outlined,
      selectedIcon: Icons.folder_copy,
      label: 'Folders',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    // Outer pill colors — neutral, semi-transparent
    final pillBg = cs.surfaceContainerHighest.withValues(alpha: 0.75);
    final pillBorder = cs.outline.withValues(alpha: 0.45);

    // Selected indicator pill — darker capsule behind active item
    final indicatorColor = isDark
        ? cs.outline.withValues(alpha: 0.4)
        : cs.outline.withValues(alpha: 0.25);

    // Text/icon colors
    final selectedColor = cs.onSurface;
    final unselectedColor = cs.onSurface.withValues(alpha: 0.45);

    final indicatorW = _indicatorWidth();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8 + bottomPadding),
        child: SizedBox(
          width: _navBarWidth,
          height: 58,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(color: pillBorder, width: 0.5),
                  ),
                  child: Stack(
                    children: [
                      // Animated indicator pill
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: _indicatorLeft(),
                        top: 5,
                        bottom: 5,
                        width: indicatorW,
                        child: Container(
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),

                      // Nav items row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _horizontalPadding,
                        ),
                        child: Row(
                          children: List.generate(_items.length, (i) {
                            final item = _items[i];
                            final isSelected = i == selectedIndex;

                            return _NavBarItemWidget(
                              item: item,
                              isSelected: isSelected,
                              onTap: () => onTap(i),
                              selectedColor: selectedColor,
                              unselectedColor: unselectedColor,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _indicatorWidth() {
    final innerWidth = _navBarWidth - (_horizontalPadding * 2);
    return innerWidth / _items.length;
  }

  double _indicatorLeft() {
    return _horizontalPadding + (_indicatorWidth() * selectedIndex);
  }
}

class _NavBarItemWidget extends StatefulWidget {
  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  State<_NavBarItemWidget> createState() => _NavBarItemWidgetState();
}

class _NavBarItemWidgetState extends State<_NavBarItemWidget> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _scale = 0.92),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            height: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.isSelected
                        ? widget.item.selectedIcon
                        : widget.item.icon,
                    key: ValueKey('${widget.isSelected}'),
                    size: 20,
                    color: widget.isSelected
                        ? widget.selectedColor
                        : widget.unselectedColor,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.isSelected
                        ? widget.selectedColor
                        : widget.unselectedColor,
                    letterSpacing: 0.1,
                  ),
                  child: Text(widget.item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

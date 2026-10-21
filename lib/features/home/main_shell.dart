import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/bottom_navbar.dart';
import '../../providers/app_state.dart';
import '../chatbot/coach_chat_screen.dart';
import 'home_screen.dart';
import '../schedule/schedule_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';
import '../achievements/badge_unlocked_dialog.dart';

class MainShell extends StatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentTab;
  final List<int> _tabHistory = [];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _tabHistory.add(_currentTab);
  }

  void _onTabSelect(int index) {
    if (_currentTab != index) {
      if (index == 0) {
        _tabHistory.clear();
        _tabHistory.add(0);
      } else {
        _tabHistory.remove(index);
        _tabHistory.add(index);
      }
      setState(() => _currentTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;

    // Check if a badge was just unlocked and show celebration dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.recentlyUnlockedBadge != null) {
        final badge = appState.recentlyUnlockedBadge!;
        appState.dismissBadgeDialog();
        showDialog(
          context: context,
          builder: (_) => BadgeUnlockedDialog(badge: badge),
        );
      }
    });

    final screens = [
      HomeScreen(onNavigateTab: _onTabSelect),
      const ScheduleScreen(),
      const NutritionScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    final canPop = _currentTab == 0;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_tabHistory.length > 1) {
          _tabHistory.removeLast(); // pop current tab
          final previousTab = _tabHistory.last;
          if (previousTab == 0) {
            _tabHistory.clear();
            _tabHistory.add(0);
          }
          setState(() => _currentTab = previousTab);
        } else if (_currentTab != 0) {
          _tabHistory.clear();
          _tabHistory.add(0);
          setState(() => _currentTab = 0);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
        body: Stack(
          children: [
            // Current Screen Tab with preserved state
            IndexedStack(
              index: _currentTab,
              children: screens,
            ),

            // Floating AI Coach Orb Button
            // SafeArea aware and positioned comfortably above bottom navigation bar
            Positioned(
              right: 18,
              bottom: 96,
              child: SafeArea(
                child: Semantics(
                  button: true,
                  label: 'Open FitQuest AI Coach',
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoachChatScreen()),
                      );
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.aiBlue.withValues(alpha: 0.40),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const AiOrb(
                        size: 56,
                        showGlow: true,
                        child: Text(
                          'AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Bottom Glass Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                currentIndex: _currentTab,
                onTap: _onTabSelect,
                isDark: isDark,
                language: appState.language,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

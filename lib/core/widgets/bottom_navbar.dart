import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_localizations.dart';

class BottomNavBarItem {
  final String keyName;
  final String defaultLabel;
  final IconData icon;

  const BottomNavBarItem({
    required this.keyName,
    required this.defaultLabel,
    required this.icon,
  });
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;
  final String language;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
    this.language = 'en',
  });

  static const List<BottomNavBarItem> items = [
    BottomNavBarItem(keyName: 'nav_home', defaultLabel: 'Home', icon: Icons.home_rounded),
    BottomNavBarItem(keyName: 'nav_schedule', defaultLabel: 'Schedule', icon: Icons.calendar_today_rounded),
    BottomNavBarItem(keyName: 'nav_nutrition', defaultLabel: 'Nutrition', icon: Icons.restaurant_rounded),
    BottomNavBarItem(keyName: 'nav_history', defaultLabel: 'History', icon: Icons.history_rounded),
    BottomNavBarItem(keyName: 'nav_profile', defaultLabel: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.55) : const Color(0xFF785A3C).withOpacity(0.18),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161210).withOpacity(0.82) : Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.9),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = currentIndex == index;
                final color = isSelected 
                    ? AppColors.energeticOrange 
                    : AppColors.mutedText(isDark);

                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.tr(item.keyName, language),
                          style: AppTextStyles.caption(isDark).copyWith(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

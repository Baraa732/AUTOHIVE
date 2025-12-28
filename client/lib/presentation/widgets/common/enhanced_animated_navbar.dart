import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EnhancedAnimatedNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final NavbarThemeData? theme;

  const EnhancedAnimatedNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.theme,
  });

  @override
  State<EnhancedAnimatedNavbar> createState() => _EnhancedAnimatedNavbarState();
}

class _EnhancedAnimatedNavbarState extends State<EnhancedAnimatedNavbar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );

    _indicatorAnimation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(EnhancedAnimatedNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _indicatorAnimation = Tween<double>(
        begin: oldWidget.currentIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = widget.theme ?? AppTheme.getNavbarTheme(isDark);
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / widget.items.length;

    return AnimatedBuilder(
      animation: _indicatorAnimation,
      builder: (context, child) {
        return Container(
          height: theme.navHeight,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(theme.radius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Floating indicator (smaller circle, no cutout)
              Positioned(
                top: -20,
                left: itemWidth * _indicatorAnimation.value + (itemWidth / 2) - (theme.indicatorSize / 2),
                child: Container(
                  width: theme.indicatorSize,
                  height: theme.indicatorSize,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.items[widget.currentIndex].activeIcon,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
              ),
              // Navigation items
              Row(
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = index == widget.currentIndex;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => widget.onTap(index),
                        splashColor: theme.accentColor.withValues(alpha: 0.15),
                        highlightColor: theme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: theme.navHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Fixed icon display - no overlapping
                              Icon(
                                isActive ? item.activeIcon : item.icon,
                                size: 22,
                                color: isActive ? Colors.transparent : theme.textDim,
                              ),
                              const SizedBox(height: 4),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isActive ? 1.0 : 0.0,
                                child: Text(
                                  item.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: theme.accentColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

# Theme Implementation Audit & Plan

## Overview
Audit of all 11 screens to identify which ones need theme support fixes and enhancements.

## Screens Status

### Screens WITH Partial/Complete Theme Support (8)
1. ✓ welcome_screen.dart - Complete (all colors, animations themed)
2. ✓ login_screen.dart - Complete (all colors, animations themed)
3. ⚠ register_screen.dart - Partial (main colors themed, some dropdowns may not be)
4. ✓ apartment_details_screen.dart - Complete (just implemented in Phase 1-4)
5. ⚠ modern_home_screen.dart - Partial (needs audit)
6. ⚠ create_booking_screen.dart - Partial (needs audit)
7. ⚠ add_apartment_screen.dart - Partial (needs audit)
8. ⚠ profile_screen.dart - Partial (needs audit)

### Screens MISSING Theme Support (3)
1. ❌ bookings_screen.dart - Partial (has isDark but incomplete)
2. ❌ main_navigation_screen.dart - Missing (hardcoded Colors.red for network indicator)
3. ❌ navigation_screen.dart - Missing (no theme at all)

## Required Changes Per Screen

### High Priority (Missing or Critical Issues)
- main_navigation_screen.dart: Fix network status indicator color
- navigation_screen.dart: Add theme support to Scaffold background
- bookings_screen.dart: Complete remaining color hardcodes

### Medium Priority (Audit & Complete)
- modern_home_screen.dart
- create_booking_screen.dart
- add_apartment_screen.dart
- profile_screen.dart

### Global Changes Needed
1. Ensure Scaffold backgroundColor uses AppTheme.getBackgroundColor()
2. Ensure AppBar uses AppTheme methods
3. Ensure TabBar indicator colors are themed
4. Ensure Card/Container backgrounds are themed
5. Ensure Text colors are themed
6. Ensure Icon colors are themed
7. Ensure Button colors are themed
8. Remove hardcoded Colors.white, Colors.black, specific hex codes
9. Use Theme.of(context).brightness or ref.watch(themeProvider)

## Implementation Strategy
1. Audit each screen for hardcoded colors
2. Replace with AppTheme methods
3. Ensure isDark detection is consistent
4. Test theme toggle on each screen
5. Verify all text/icons/buttons change with theme

## Theme Detection Pattern (Choose One)
Option A (Used in most screens):
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

Option B (Used in some ConsumerWidgets):
```dart
final isDarkMode = ref.watch(themeProvider);
```

Both work, but should be consistent per screen.

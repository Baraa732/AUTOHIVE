# Complete Dark/Light Mode Implementation - Requirements

## Feature Description
Implement comprehensive dark/light mode support across all 11 screens following system theme preference. Ensure ALL elements (text, icons, backgrounds, buttons, shadows) are themed appropriately.

## User Stories

### Story 1: System Theme Support
**Acceptance Criteria**:
- When user has dark theme enabled in device settings, app displays in dark mode
- When user has light theme enabled in device settings, app displays in light mode
- App automatically detects system theme changes and updates in real-time
- All elements change appropriately (backgrounds, text, icons, buttons, shadows)

### Story 2: Professional Dark Mode
**Acceptance Criteria**:
- Dark backgrounds use AppTheme colors (darkPrimary, darkSecondary, darkTertiary)
- Text is white/light (#FFFFFF or light gray)
- Icons are white/light colored
- Cards have dark backgrounds with subtle borders
- Shadows are visible on dark backgrounds
- Color contrast meets accessibility standards (WCAG AA)

### Story 3: Professional Light Mode
**Acceptance Criteria**:
- Light backgrounds use AppTheme colors (lightPrimary, lightSecondary)
- Text is dark (#1E293B)
- Icons are dark or brand colored
- Cards are light colored with subtle shadows
- Shadows are subtle and visible
- Color contrast meets accessibility standards (WCAG AA)

---

## Requirements

### Global Requirements
1. All screens must use `Theme.of(context).brightness == Brightness.dark` for theme detection
   - OR use `ref.watch(themeProvider)` if screen is ConsumerWidget
2. NO hardcoded colors except AppTheme constants:
   - ❌ Colors.white, Colors.black, Colors.grey
   - ❌ Color(0xFFABCDEF) arbitrary hex codes
   - ✅ AppTheme.primaryOrange, AppTheme.primaryBlue
   - ✅ AppTheme.getTextColor(isDark)
   - ✅ AppTheme.getCardColor(isDark)

3. All Scaffolds must use:
   - backgroundColor: AppTheme.getBackgroundColor(isDark)

4. All AppBars must use:
   - backgroundColor: AppTheme.getCardColor(isDark) or transparent
   - Title text: AppTheme.getTextColor(isDark)

5. All Cards/Containers must use:
   - Background: AppTheme.getCardColor(isDark)
   - Border: AppTheme.getBorderColor(isDark)

6. All Text must use:
   - color: AppTheme.getTextColor(isDark) for primary text
   - color: AppTheme.getSubtextColor(isDark) for secondary text

7. All Icons must use:
   - Dark mode: white or light colors
   - Light mode: dark or brand colors

8. Shadows must be:
   - Dark mode: darker colors with higher opacity
   - Light mode: lighter colors with lower opacity

### Per-Screen Requirements

#### 1. welcome_screen.dart
- ✓ COMPLETE - Already has full theme support
- No changes needed

#### 2. login_screen.dart
- ✓ COMPLETE - Already has full theme support
- No changes needed

#### 3. register_screen.dart
- NEEDS AUDIT: Check dropdown styling
- NEEDS AUDIT: Check all text/icon colors

#### 4. apartment_details_screen.dart
- ✓ COMPLETE - Just implemented in phases 1-4
- No changes needed

#### 5. modern_home_screen.dart
- ❌ NEEDS FIX: Hardcoded Color(0xFFff6f2d) and Color(0xFF4a90e2)
- ❌ NEEDS FIX: Colors.black hardcoded in shadows
- ❌ NEEDS FIX: Inconsistent theme detection (mix of patterns)

#### 6. create_booking_screen.dart
- ❌ NEEDS AUDIT & FIX: Check all colors
- ❌ NEEDS AUDIT & FIX: Check form styling
- ❌ NEEDS AUDIT & FIX: Check button colors

#### 7. add_apartment_screen.dart
- ❌ NEEDS AUDIT & FIX: Check all colors
- ❌ NEEDS AUDIT & FIX: Check form styling
- ❌ NEEDS AUDIT & FIX: Check image upload UI

#### 8. profile_screen.dart
- ❌ NEEDS AUDIT & FIX: Check all colors
- ❌ NEEDS AUDIT & FIX: Check button styling
- ❌ NEEDS AUDIT & FIX: Check list items

#### 9. bookings_screen.dart
- ⚠️ NEEDS FIXES: Has partial theme support
- ❌ NEEDS FIX: TabBar indicator colors
- ❌ NEEDS FIX: Booking status badge colors
- ❌ NEEDS FIX: Complete text colors

#### 10. main_navigation_screen.dart
- ❌ CRITICAL FIX: Network indicator hardcoded to Colors.red
- Must use themed error color

#### 11. navigation_screen.dart
- ❌ MISSING: No theme support at all
- Must add Scaffold background color
- Must ensure BottomNav is themed

---

## Success Criteria
1. ✅ All 11 screens have complete theme support
2. ✅ System theme is detected and respected
3. ✅ All text colors change with theme
4. ✅ All backgrounds change with theme
5. ✅ All icons change with theme
6. ✅ All buttons/interactive elements are themed
7. ✅ No hardcoded colors (except AppTheme)
8. ✅ flutter analyze shows no theme-related issues
9. ✅ Theme toggle in settings works across all screens
10. ✅ Accessibility standards met (proper contrast)

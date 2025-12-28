# Complete Dark/Light Mode Implementation Plan

## Implementation Phases

### Phase 1: Critical Fixes (Navigation & Core)
Fix the 3 screens that completely lack or have critical missing theme support.

#### [ ] Task 1.1: main_navigation_screen.dart
**Location**: `client/lib/presentation/screens/shared/main_navigation_screen.dart`

**Changes Required**:
1. Add theme detection at top of build()
2. Change network indicator from hardcoded Colors.red to themed error color
3. Use AppTheme methods for text color in indicator

**Specific Changes**:
- Line 36: `color: Colors.red` → themed error color (red in both modes)
- Line 39: `style: TextStyle(color: Colors.white)` → use AppTheme.getTextColor(isDark) if needed

**Verification**:
- Toggle theme and verify network indicator stays visible and themed
- Run: `flutter analyze`

---

#### [ ] Task 1.2: navigation_screen.dart
**Location**: `client/lib/presentation/screens/shared/navigation_screen.dart`

**Changes Required**:
1. Add theme detection to build()
2. Set Scaffold backgroundColor to use AppTheme
3. Ensure BottomNav uses theme colors (check AnimatedBottomNav widget)

**Specific Changes**:
- Add `final isDark = Theme.of(context).brightness == Brightness.dark;`
- Line 63-72: Add backgroundColor to Scaffold
- Check AnimatedBottomNav for theme support

**Verification**:
- Navigate between screens, verify background is themed
- Run: `flutter analyze`
- Visual check: Toggle theme at settings

---

#### [ ] Task 1.3: bookings_screen.dart - Complete Theming
**Location**: `client/lib/presentation/screens/shared/bookings_screen.dart`

**Changes Required**:
1. TabBar indicator colors must be themed
2. Booking status badges must be themed
3. Complete any remaining hardcoded colors
4. Ensure list item backgrounds are themed

**Specific Changes**:
- Find TabBar widget and set indicatorColor: AppTheme.primaryOrange
- Find status badge colors and use AppTheme methods
- Find any Colors.white or Colors.black and replace

**Verification**:
- Switch between My Bookings and Received Bookings tabs
- Verify tab indicator color is consistent
- Run: `flutter analyze`
- Toggle theme and verify all elements change

---

### Phase 2: Major Screen Fixes
Fix screens with partial theme implementation that need completion.

#### [ ] Task 2.1: modern_home_screen.dart - Complete Theming
**Location**: `client/lib/presentation/screens/shared/modern_home_screen.dart`

**Changes Required**:
1. Replace hardcoded Color(0xFFff6f2d) with AppTheme.primaryOrange
2. Replace hardcoded Color(0xFF4a90e2) with AppTheme.primaryBlue
3. Replace Colors.black.withValues(alpha:) with theme-aware shadow colors
4. Standardize theme detection (use one pattern consistently)
5. Ensure SearchBar is themed
6. Ensure apartment cards are themed

**Key Issues to Fix**:
- Line 182: Hardcoded gradient - OK to keep as-is (uses brand colors)
- Line 173: Colors.black shadow - use isDark ? AppTheme colors
- Line 231: Icon color hardcoded
- Line 302: Colors.black shadow - theme-aware

**Verification**:
- Run: `flutter analyze`
- Visual check: Dark mode apartment cards and search bar
- Light mode: same verification
- Toggle theme on home screen multiple times

---

#### [ ] Task 2.2: create_booking_screen.dart - Complete Audit & Fix
**Location**: `client/lib/presentation/screens/shared/create_booking_screen.dart`

**Changes Required**:
1. Audit all Text widget colors
2. Audit all Icon colors
3. Audit all Container/Card backgrounds
4. Audit form styling (TextFormField)
5. Audit button colors
6. Ensure date/time pickers are themed

**Verification**:
- Run: `flutter analyze`
- Visual check: Complete a booking flow in both themes
- Check form fields are readable in both modes
- Check buttons are visible and themed

---

#### [ ] Task 2.3: add_apartment_screen.dart - Complete Audit & Fix
**Location**: `client/lib/presentation/screens/shared/add_apartment_screen.dart`

**Changes Required**:
1. Audit all form field styling
2. Audit text colors
3. Audit button colors
4. Audit image upload UI
5. Audit dropdown styling
6. Audit location selectors

**Verification**:
- Run: `flutter analyze`
- Visual check: Form in dark mode is readable
- Visual check: Form in light mode looks professional
- Check image upload UI is clear in both modes

---

#### [ ] Task 2.4: profile_screen.dart - Complete Audit & Fix
**Location**: `client/lib/presentation/screens/shared/profile_screen.dart`

**Changes Required**:
1. Audit all text colors
2. Audit all button colors
3. Audit list item backgrounds
4. Audit user info section styling
5. Audit profile picture frame color
6. Audit logout button color

**Verification**:
- Run: `flutter analyze`
- Visual check: Profile info readable in dark mode
- Visual check: Buttons visible in light mode
- Check edit/logout buttons are properly themed

---

### Phase 3: Audit Minor Issues
Quick audit of remaining screens that mostly work.

#### [ ] Task 3.1: register_screen.dart - Audit & Minor Fixes
**Location**: `client/lib/presentation/screens/auth/register_screen.dart`

**Changes Required** (Likely Minor):
1. Audit dropdown/location selector colors
2. Verify image upload UI styling
3. Check all text colors are correct
4. Verify button colors match design

**Verification**:
- Run: `flutter analyze`
- Visual: Registration flow in both themes
- Dropdowns visible and readable

---

### Phase 4: Consistency & Testing
Final pass to ensure consistency and complete testing.

#### [ ] Task 4.1: Code Audit - Theme Pattern Consistency
**Changes Required**:
1. Ensure all screens use consistent theme detection:
   - Prefer: `final isDark = Theme.of(context).brightness == Brightness.dark;`
   - Acceptable: `final isDarkMode = ref.watch(themeProvider);`
2. Verify all AppTheme methods are used correctly
3. Run flutter analyze on all screens
4. Check for any remaining hardcoded colors

**Verification**:
- Run: `flutter analyze` on entire client package
- Grep search for remaining Color(0x, Colors.white, Colors.black usage
- No critical issues found

---

#### [ ] Task 4.2: Cross-Screen Theme Testing
**Test Plan**:
1. Launch app in dark mode:
   - [ ] Welcome screen looks professional
   - [ ] Login screen is readable
   - [ ] Home screen is themed
   - [ ] Bookings screen tabs work
   - [ ] Add apartment form is complete
   - [ ] Profile looks good
   
2. Launch app in light mode:
   - [ ] Same visual checks as above
   - [ ] Colors are appropriate for light background
   - [ ] Text is dark and readable
   - [ ] Icons are visible
   
3. Theme toggle at runtime:
   - [ ] Switch between dark/light modes
   - [ ] All screens update immediately
   - [ ] No colors lag or flicker

4. Navigation testing:
   - [ ] Navigate through all screens in dark mode
   - [ ] Navigate through all screens in light mode
   - [ ] Navigate while switching themes

---

#### [ ] Task 4.3: Build & Verify
**Final Verification**:
```bash
cd client
flutter clean
flutter pub get
flutter analyze                    # No theme-related issues
flutter build apk --debug          # Build succeeds
```

---

## Implementation Order

1. **Start with Phase 1** (Critical fixes) - 30 mins
2. **Then Phase 2** (Major screens) - 1-2 hours
3. **Then Phase 3** (Audit) - 30 mins
4. **Finally Phase 4** (Testing) - 1 hour

**Total Estimated Time**: 3-4 hours

## Success Indicators

- ✅ flutter analyze shows 0 theme-related errors
- ✅ All 11 screens themed in both dark and light modes
- ✅ No hardcoded colors (except AppTheme constants)
- ✅ Visual consistency across all screens
- ✅ Theme changes work in real-time
- ✅ All text is readable in both modes
- ✅ All buttons and interactive elements visible
- ✅ Shadows visible and appropriate for each theme

# Feature development workflow

---

## Workflow Steps

### [x] Step: Requirements

**Status**: COMPLETED

Created comprehensive Product Requirements Document covering:
- User stories with acceptance scenarios
- Visual design requirements
- Animation requirements  
- Functional requirements
- Technical requirements
- Success criteria

**Deliverable**: `requirements.md` - Defines all feature requirements and acceptance criteria

### [x] Step: Technical Specification

**Status**: COMPLETED

Created comprehensive Technical Specification covering:
- Technical context (Flutter 3.10.3, Riverpod, Material Design)
- Implementation brief with architecture decisions
- Source code structure and file organization
- Data contracts and widget interfaces
- 6 delivery phases with clear MVPs
- Detailed verification strategy for each phase
- Performance metrics and success criteria

**Deliverable**: `spec.md` - Technical implementation guide with 6 phases

### [x] Step: Implementation Plan

**Status**: COMPLETED & READY FOR IMPLEMENTATION

---

## Implementation Tasks

### [ ] Phase 1: Theme Setup - Add Navbar Colors to AppTheme

**Task Definition**:
Add `NavbarThemeData` class and navbar-specific color constants to the AppTheme class. This foundational phase establishes all color values and theme configuration needed by subsequent phases.

**Contracts to Implement**:
- Create `NavbarThemeData` class in `app_theme.dart`
- Add static getter method in `AppTheme` for navbar theme
- Define color constants: accent (#6CFF5B), background (#111), secondary (#8b5cf6), textLight (#f8fafc), textDim (#94a3b8)
- Define dimension constants: navHeight (72px), radius (22px), indicatorSize (60px), cutoutWidth (80px), cutoutHeight (40px)
- Define animation constants: transitionDuration (550ms), transitionCurve (cubic-bezier)

**Deliverable**: Updated `lib/core/theme/app_theme.dart` with navbar theme constants

**Verification Instructions**:
1. Open `lib/core/theme/app_theme.dart`
2. Verify `NavbarThemeData` class exists with all properties
3. Verify color values match design:
   - Accent: #6CFF5B
   - Background: #111
   - NavHeight: 72
   - Radius: 22
   - Duration: 550ms
4. Run: `flutter analyze` to check for errors
5. Verify both light and dark theme variants exist

---

### [ ] Phase 2: Basic Navbar Structure - Create EnhancedAnimatedNavbar Widget

**Task Definition**:
Create the `EnhancedAnimatedNavbar` widget with basic static structure. This widget will render the navbar container with 4 navigation items, icons, and labels without animations. The widget maintains the same API as the original `AnimatedBottomNav` for backward compatibility.

**Contracts to Use/Implement**:
- Use `BottomNavItem` from existing code (no changes)
- Use `NavbarThemeData` from Phase 1
- Implement `EnhancedAnimatedNavbar` widget interface:
  - Required: `currentIndex` (int), `onTap` (Function), `items` (List<BottomNavItem>)
  - Optional: `theme` (NavbarThemeData override)
- Return proper widget structure suitable for placement in Scaffold bottomNavigationBar

**Deliverable**: New file `lib/presentation/widgets/common/enhanced_animated_navbar.dart`

**Verification Instructions**:
1. Create temporary test by modifying `navigation_screen.dart` to use new widget
2. Run: `flutter run`
3. Verify navbar appears at bottom of screen
4. Verify all 4 items display: Home, Bookings, Add, Profile
5. Verify icons render correctly (use simple Icon widget, not animated yet)
6. Verify labels display below icons
7. Verify tap on items changes `currentIndex` (visual verification of backgroundColor change on tap)
8. Revert `navigation_screen.dart` temporary changes
9. Run: `flutter analyze` to check code quality

---

### [ ] Phase 3: Add Floating Indicator - Implement Circular Indicator Above Navbar

**Task Definition**:
Add a floating circular indicator that appears above the navbar. The indicator should be positioned based on the active `currentIndex`, sized at 60px diameter, and include a glow effect using shadow.

**Contracts to Use/Implement**:
- Use `NavbarThemeData.indicatorSize` (60px)
- Use `NavbarThemeData.accentColor` (#6CFF5B) for indicator background
- Implement glow effect using BoxShadow with green color
- Position indicator dynamically: `left = (screenWidth / itemCount) * currentIndex - (indicatorSize / 2)`
- Indicator should be positioned at `top = -26px` (above navbar)

**Deliverable**: Enhanced `EnhancedAnimatedNavbar` with floating indicator implementation

**Verification Instructions**:
1. Modify `navigation_screen.dart` to use `EnhancedAnimatedNavbar`
2. Run: `flutter run`
3. Verify floating indicator appears above navbar
4. Verify indicator is positioned above the active (first/Home) item initially
5. Tap on different items and verify indicator stays stationary (no animation yet)
6. Verify glow/shadow effect is visible around indicator
7. Verify indicator size is correct (~60px)
8. Verify indicator color matches accent color (#6CFF5B)
9. Verify indicator doesn't interfere with item taps
10. Check on different screen widths (use Device Preview or different emulator sizes)

---

### [ ] Phase 4: Add Curved Cutout - Implement NavbarPainter for Curved Shape

**Task Definition**:
Implement the curved cutout design using CustomPaint and a custom painter. The cutout creates an opening in the navbar background that aligns with the floating indicator position. The cutout should be 80px wide and 40px tall with smooth curves.

**Contracts to Use/Implement**:
- Create new file `lib/presentation/widgets/common/navbar_painter.dart`
- Implement `NavbarPainter` extending `CustomPainter`
- Accept parameters: `activeIndex`, `itemCount`, `accentColor`, `backgroundColor`, `cutoutWidth`, `cutoutHeight`
- Paint curved cutout path using Path with quadratic curves
- Calculate cutout position based on `activeIndex`

**Deliverable**: New file `navbar_painter.dart` and updated `EnhancedAnimatedNavbar` using CustomPaint

**Verification Instructions**:
1. Implement `NavbarPainter` class
2. Integrate CustomPaint into navbar background
3. Run: `flutter run`
4. Visual verification:
   - Curved cutout appears in navbar background
   - Cutout aligns with floating indicator
   - Cutout shape is smooth with no artifacts
   - Cutout is centered above active item
5. Tap different items and verify cutout position updates
6. Verify navbar still functions correctly (taps work)
7. Test on multiple screen sizes
8. Run: `flutter analyze`

---

### [ ] Phase 5: Add Smooth Animations - Implement AnimationController and Transitions

**Task Definition**:
Implement the complete animation system using AnimationController with 0.55s duration and cubic-bezier easing. Animate the indicator position, cutout shape, icon transformations (scale/translate), and label opacity/color changes.

**Contracts to Use/Implement**:
- Use `AnimationController` with duration 550ms
- Use cubic-bezier(0.4, 0, 0.2, 1) curve: `CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic)` (closest match in Flutter)
- Animate indicator position: Left position Tween
- Animate cutout path: Custom animation (requires NavbarPainter update)
- Animate icons: Scale (1.0 to 1.15) and translateY (-18px) for active items
- Animate labels: Opacity (0 to 1) and color transition for active items
- Update `didUpdateWidget` to trigger animation on `currentIndex` change

**Deliverable**: Updated `EnhancedAnimatedNavbar` with complete animation system

**Verification Instructions**:
1. Implement AnimationController and animations
2. Run: `flutter run --release` (to test performance)
3. Manual verification:
   - Switch between tabs
   - Observe indicator animates smoothly (should take ~550ms)
   - Observe cutout animates to new position
   - Observe icons scale and move upward when active
   - Observe labels fade in/out smoothly
   - Observe color transitions are smooth
4. Performance testing:
   - Use Flutter DevTools Performance tab
   - Monitor FPS while switching tabs rapidly
   - Target: 50+ FPS consistently
   - Check for dropped frames
5. Animation timing:
   - Use stopwatch or DevTools to verify ~550ms animation
6. Test on real device if available
7. Run: `flutter analyze`

---

### [ ] Phase 6: Integration & Final Polish - Replace Old Navbar and Test Integration

**Task Definition**:
Replace the current `AnimatedBottomNav` with `EnhancedAnimatedNavbar` in the navigation screen. Ensure seamless integration with existing screens, verify all navigation flows work correctly, and polish any remaining visual details.

**Contracts to Use/Implement**:
- Update `lib/presentation/screens/shared/navigation_screen.dart`
- Remove import of `AnimatedBottomNav` (or keep it but don't use)
- Update import to use `EnhancedAnimatedNavbar`
- Pass same `BottomNavItem` instances (no changes needed)
- Verify dark/light theme switching works
- Ensure backward compatibility (API remains same)

**Deliverable**: Fully integrated navbar replacing existing implementation

**Verification Instructions**:
1. Update `navigation_screen.dart` to import and use `EnhancedAnimatedNavbar`
2. Ensure BottomNavItem definitions remain unchanged
3. Run: `flutter run`
4. Integration testing:
   - Launch app
   - Verify navbar appears at bottom
   - Tap each item and verify screen changes:
     - Home → ModernHomeScreen
     - Bookings → BookingsScreen
     - Add → AddApartmentScreen
     - Profile → ProfileScreen
   - Verify active item indicator updates correctly
   - Verify active item persists when returning from other screens
5. Theme testing:
   - Toggle light/dark theme if available
   - Verify navbar colors update correctly
   - Verify accent color remains consistent
6. Visual comparison:
   - Compare with reference `navbar.html` design
   - Check colors match (#6CFF5B accent, dark background)
   - Check animations are smooth
   - Check overall polish and appearance
7. Performance testing:
   - Run in release mode: `flutter run --release`
   - Navigate between screens 10+ times
   - Monitor for any stuttering or jank
   - Check memory usage in DevTools
8. Responsiveness testing:
   - Test on multiple screen sizes (phone, tablet if available)
   - Verify navbar adapts properly
   - Verify all items remain clickable
9. Run: `flutter analyze` and `flutter test` (if applicable)
10. Check for any build warnings or errors

---

## Deliverables Summary

| Phase | Deliverable | Status |
|-------|-------------|--------|
| 1 | Theme Setup in `app_theme.dart` | ✅ Completed |
| 2 | New `enhanced_animated_navbar.dart` | ✅ Completed |
| 3 | Floating Indicator Implementation | ✅ Completed |
| 4 | New `navbar_painter.dart` + CustomPaint | ✅ Completed |
| 5 | Complete Animation System | ✅ Completed |
| 6 | Integration & Polish | ✅ Completed |

---

## Implementation Notes

- **Backward Compatibility**: The new widget maintains the same public API as `AnimatedBottomNav`, making it a drop-in replacement
- **Performance**: All animations use Flutter's built-in APIs (AnimationController, CustomPaint) for optimal performance
- **Theme Integration**: Colors and values pull from `NavbarThemeData` for consistency and maintainability
- **No New Dependencies**: Implementation uses only Flutter built-in features
- **Testing Approach**: Each phase has clear visual verification steps that can be executed manually
- **Reference**: Use `navbar.html` as visual reference for design validation

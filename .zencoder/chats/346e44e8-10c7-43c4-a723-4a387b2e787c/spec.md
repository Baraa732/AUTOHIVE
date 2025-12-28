# Technical Specification: Mobile Navbar Redesign

## Technical Context

**Language/Framework**: Flutter 3.10.3+
**Primary Dependencies**:
- `flutter` - UI framework
- `flutter_riverpod` (^2.4.9) - State management
- Material Design - Flutter built-in

**Existing Code**: 
- `lib/presentation/widgets/common/animated_bottom_nav.dart` - Current navbar implementation
- `lib/presentation/screens/shared/navigation_screen.dart` - Navigation container
- `lib/core/theme/app_theme.dart` - Theme constants and styling

**Target Device**: Mobile devices (primary), Android 7.0+, iOS 11.0+

## Technical Implementation Brief

### Architecture Decision
Replace the current `AnimatedBottomNav` widget with a new `EnhancedAnimatedNavbar` widget that:
1. Uses the existing Riverpod state management to track active tab
2. Leverages Flutter's built-in animation APIs (AnimationController, CustomPaint)
3. Implements the curved cutout and floating indicator using Stack with positioned elements
4. Maintains the same BottomNavItem contract for backward compatibility

### Key Technical Decisions

1. **Custom Paint for Curved Cutout**: Use CustomPaint widget instead of CSS-like approaches to create the curved cutout effect that adapts to different screen sizes
2. **AnimationController for Smooth Transitions**: Leverage Flutter's AnimationController with cubic-bezier curve for smooth indicator movement
3. **Stack-based Layout**: Use Stack positioning for the floating indicator to avoid affecting navbar height
4. **Theme Integration**: Extend existing AppTheme class to include new navbar-specific colors
5. **No New Dependencies**: Use only Flutter built-in APIs to minimize dependencies
6. **Backward Compatible**: Keep BottomNavItem structure and navigation logic intact

## Source Code Structure

```
lib/
├── presentation/
│   ├── widgets/
│   │   └── common/
│   │       ├── enhanced_animated_navbar.dart (NEW - main component)
│   │       ├── navbar_painter.dart (NEW - CustomPaint for curved cutout)
│   │       └── animated_bottom_nav.dart (EXISTING - keep for compatibility)
│   └── screens/
│       └── shared/
│           └── navigation_screen.dart (MODIFY - replace widget)
└── core/
    └── theme/
        └── app_theme.dart (MODIFY - add navbar colors)
```

## Contracts

### Data Models / Interfaces

#### BottomNavItem (Existing - No Changes Required)
```dart
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;
}
```

#### NavbarThemeData (New - Add to AppTheme)
```dart
class NavbarThemeData {
  final Color backgroundColor;
  final Color accentColor;
  final Color secondaryColor;
  final Color textLight;
  final Color textDim;
  final double navHeight;
  final double radius;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final double indicatorSize;
  final double cutoutWidth;
  final double cutoutHeight;
}
```

### Widget Interface

#### EnhancedAnimatedNavbar (Replaces AnimatedBottomNav)
```dart
class EnhancedAnimatedNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final NavbarThemeData? theme; // optional override

  const EnhancedAnimatedNavbar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.theme,
  });
}
```

### API Changes
- Navigation logic remains the same
- `BottomNavItem` structure unchanged
- Replacement is drop-in compatible with existing code

## Delivery Phases

### Phase 1: Theme Setup (Foundational)
**Deliverable**: Theme colors and constants defined
- Add `NavbarThemeData` to `AppTheme` class
- Define color constants matching the design (#6CFF5B accent, #111 background)
- Ensure theme values work for both light and dark modes

**Testing**: 
- Verify theme constants are correct
- Check color values match the design specification
- Ensure light/dark mode variants exist

### Phase 2: Basic Navbar Structure (MVP)
**Deliverable**: Static navbar with items and icons, without animations
- Create `EnhancedAnimatedNavbar` widget base structure
- Implement basic navbar container with proper spacing
- Add navigation items with icons and labels
- Ensure all 4 items (Home, Bookings, Add, Profile) render correctly

**Testing**:
- Visual verification: navbar appears at bottom with correct items
- Icons display correctly
- Labels display below icons
- Tap detection works (register taps)

### Phase 3: Floating Indicator (Core Feature)
**Deliverable**: Floating circular indicator above the navbar
- Implement positioned circular indicator element
- Add indicator positioning logic based on active item index
- Implement glow/shadow effect using BoxShadow
- Ensure indicator size matches design (60px)

**Testing**:
- Indicator appears above correct item
- Indicator position updates when active index changes
- Glow effect is visible
- Indicator is centered above the active item

### Phase 4: Curved Cutout Design (Core Feature)
**Deliverable**: Curved cutout in navbar that aligns with indicator
- Implement `NavbarPainter` using CustomPaint for curved shape
- Create cutout path that follows indicator position
- Ensure smooth rendering without artifacts
- Implement smooth animation of cutout path

**Testing**:
- Curved cutout appears above navbar
- Cutout position follows indicator
- Smooth animation (0.55s) when moving between items
- No visual artifacts or rendering issues

### Phase 5: Smooth Animations (UX Polish)
**Deliverable**: Complete animation system with easing curves
- Implement AnimationController with 0.55s duration
- Apply cubic-bezier(0.4, 0, 0.2, 1) curve
- Animate indicator movement
- Animate icon color and scale transitions
- Animate label opacity and color transitions
- Animate cutout path smoothly

**Testing**:
- Animation timing is 0.55s
- Easing curve matches design (cubic-bezier)
- Icons scale and translate when active
- Labels fade in/out smoothly
- No animation stuttering or jank (60fps)

### Phase 6: Integration & Polish (Finalization)
**Deliverable**: Fully integrated navbar with theme support
- Replace AnimatedBottomNav with EnhancedAnimatedNavbar in navigation_screen.dart
- Ensure integration with existing screens
- Add theme override support
- Verify backward compatibility
- Polish animations and visual details

**Testing**:
- All 4 screens navigate correctly
- Active tab persists across navigation
- Visual design matches reference navbar.html
- Performance is smooth on real devices
- Theme integration works (light/dark modes)

## Verification Strategy

### Phase-by-Phase Verification

#### Phase 1 Verification
```bash
# Manual inspection in code
1. Open lib/core/theme/app_theme.dart
2. Verify NavbarThemeData constants:
   - backgroundColor: #111 equivalent
   - accentColor: #6CFF5B equivalent
   - navHeight: 72px
   - radius: 22px
   - transitionDuration: 550ms
3. Confirm colors are correct using color hex checkers
```

#### Phase 2 Verification
```bash
# Visual inspection
1. Run the app: flutter run
2. Navigate to main_navigation_screen
3. Check navbar appears at bottom
4. Verify all 4 items display: Home, Bookings, Add, Profile
5. Verify icons render correctly
6. Verify labels display below icons
7. Tap each item and verify selection changes
```

#### Phase 3 Verification
```bash
# Visual inspection
1. Run: flutter run
2. Observe floating indicator above active item
3. Indicator should be 60px circle
4. Check glow effect around indicator
5. Switch between tabs and verify indicator moves to correct position
6. Verify indicator stays above navbar
```

#### Phase 4 Verification
```bash
# Visual inspection
1. Run: flutter run
2. Check curved cutout appears above navbar background
3. Cutout should align with floating indicator position
4. Tap different items and verify cutout animates to correct position
5. Check for any rendering artifacts or clipping issues
```

#### Phase 5 Verification
```bash
# Performance and animation testing
1. Run: flutter run --release
2. Use Flutter DevTools Performance tab
3. Switch between tabs rapidly, observe:
   - Animation timing (~550ms)
   - FPS remains above 50fps
   - No dropped frames
4. Manual verification:
   - Icons scale and translate smoothly
   - Labels fade in/out smoothly
   - Cutout animates smoothly
5. Test on real device (if available)
```

#### Phase 6 Verification
```bash
# Integration testing
1. Run: flutter run
2. Navigate through all 4 screens:
   - Home screen
   - Bookings screen
   - Add Apartment screen
   - Profile screen
3. Verify navigation works correctly
4. Verify active tab persists
5. Verify dark/light theme switching works
6. Verify navbar visual design matches requirements
7. Compare with reference navbar.html design
```

### Helper Scripts

Create a verification checklist file at `.zencoder/verification_checklist.md`:
```markdown
# Navbar Redesign Verification Checklist

## Visual Design
- [ ] Background color matches #111 or app theme equivalent
- [ ] Accent color matches #6CFF5B or app theme equivalent
- [ ] Border radius is 22px
- [ ] Navbar height is 72px

## Floating Indicator
- [ ] Indicator is 60px circle
- [ ] Positioned above navbar
- [ ] Shows above active tab
- [ ] Has glow/shadow effect

## Curved Cutout
- [ ] Cutout appears above navbar
- [ ] Aligns with indicator position
- [ ] Smooth animation when switching tabs

## Icons & Labels
- [ ] Home icon displays correctly
- [ ] Bookings icon displays correctly
- [ ] Add icon displays correctly
- [ ] Profile icon displays correctly
- [ ] Labels appear below icons
- [ ] Active item shows green accent
- [ ] Inactive items show dimmed color

## Animations
- [ ] Indicator animation duration is ~550ms
- [ ] Animation easing is smooth (cubic-bezier)
- [ ] Icons scale and translate when active
- [ ] Labels fade smoothly
- [ ] 60fps on release build
- [ ] No stuttering or jank

## Integration
- [ ] All 4 screens navigate correctly
- [ ] Active tab persists across navigation
- [ ] Theme switching works
- [ ] No crashes or errors
- [ ] Responsive on different screen sizes

## Design Comparison
- [ ] Visual matches reference navbar.html design
- [ ] Color scheme is consistent
- [ ] Animation feels responsive
- [ ] Overall polish meets expectations
```

### Performance Metrics
- **Animation Frame Rate**: Target 60fps on release build
- **Animation Duration**: 550ms ± 50ms for indicator movement
- **Tap Response Time**: < 100ms
- **Memory Impact**: < 5MB additional memory

### Sample Test Artifacts
- Reference design: `navbar.html` (provided by user)
- Test device screenshots for visual comparison
- Performance profiling data from Flutter DevTools

### Tools & Commands

```bash
# Run the app in debug mode
flutter run

# Run the app in release mode (performance testing)
flutter run --release

# Open Flutter DevTools for performance analysis
flutter pub global run devtools

# Run any existing tests
flutter test

# Check code analysis
flutter analyze

# Build the app
flutter build apk  # Android
flutter build ios  # iOS
```

## Success Definition

The feature is successful when:
1. ✅ Visual design matches the reference navbar.html as closely as possible
2. ✅ All animations are smooth and performant (60fps)
3. ✅ Navigation works seamlessly with existing screens
4. ✅ Code follows Flutter and project conventions
5. ✅ No performance regressions observed
6. ✅ Works responsively across device sizes
7. ✅ Integrates cleanly with existing Riverpod state management

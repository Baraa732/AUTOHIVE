# Technical Specification: Apartment Details Page Design Enhancement

## Technical Context

- **Language/Framework**: Flutter (Dart)
- **State Management**: Riverpod (flutter_riverpod) 
- **Theme System**: AppTheme class with static helper methods
- **Animation Framework**: Flutter's AnimationController with Riverpod integration
- **Target Platform**: Mobile (iOS/Android)
- **Design Reference Files**:
  - `client/lib/presentation/screens/auth/welcome_screen.dart` - Animation patterns
  - `client/lib/presentation/screens/auth/login_screen.dart` - Theme integration
  - `client/lib/presentation/screens/auth/register_screen.dart` - Form design
  - `client/lib/core/theme/app_theme.dart` - Color and gradient definitions
  - `client/lib/presentation/screens/shared/apartment_details_screen.dart` - Target file

## Technical Implementation Brief

### Animation System
- Implement dual AnimationController setup (one for content animations, one for background rotation)
- Use `TickerProviderStateMixin` for AnimationController lifecycle management
- Apply consistent animation curves: `Curves.easeOutCubic` for content, linear for background
- Durations: Main content ~800-1200ms, background rotation 20-second loop

### Theme Integration
- Replace hardcoded colors (Colors.white, Color(0xFF0e1330)) with AppTheme methods
- Use `ref.watch(themeProvider)` for real-time theme switching
- Apply AppTheme helper methods: `getBackgroundGradient()`, `getCardColor()`, `getTextColor()`, `getSubtextColor()`, `getBorderColor()`

### Geometric Background Elements
- Implement 2-3 rotating geometric shapes (circles and rounded rectangles)
- Use `Transform.rotate()` with animated rotation values
- Apply gradient fills with theme-aware opacity adjustments
- Position elements off-screen to avoid content overlap

### UI Components Enhancement
- Update `_buildInfoCard()` with gradient backgrounds instead of solid white with alpha
- Apply gradient styling to booking/edit buttons
- Add scale animations to interactive elements on entry
- Update login prompt styling with theme support

### Responsive Design
- Maintain SafeArea constraints
- Keep geometric elements positioned absolutely to avoid affecting layout
- Ensure readability with proper shadow/contrast for geometric overlays

## Source Code Structure

```
client/lib/presentation/screens/shared/apartment_details_screen.dart
├── _ApartmentDetailsScreenState (extends ConsumerStatefulWidget)
│   ├── Animation Controllers
│   │   ├── _backgroundController (20s loop)
│   │   └── _rotationAnimation (calculated from backgroundController)
│   ├── Lifecycle Methods
│   │   ├── _initAnimations()
│   │   ├── _loadDetails()
│   │   ├── _loadUser()
│   │   └── dispose()
│   ├── Build Method
│   │   ├── CustomScrollView with SliverAppBar
│   │   ├── _buildImageGallery() - PageView with animations
│   │   ├── _buildAnimatedBackground() - Geometric shapes
│   │   ├── Content Section (with theme support)
│   │   │   ├── Title and location
│   │   │   ├── Price display
│   │   │   ├── Info cards (beds, baths, area)
│   │   │   ├── Description
│   │   │   └── Action buttons
│   │   └── Theme toggle support via Riverpod
```

## Contracts

### Animation Contracts
```dart
// Main content animations
AnimationController _animationController;  // 800-1200ms
Animation<double> _fadeAnimation;          // 0 -> 1
Animation<Offset> _slideAnimation;         // (0, 0.3) -> (0, 0)
Animation<double> _scaleAnimation;         // 0.8 -> 1

// Background rotation animation  
AnimationController _backgroundController; // 20s loop
Animation<double> _rotationAnimation;      // 0 -> 1 (continuous)
```

### Theme Method Contracts
```dart
// Required usage of AppTheme methods
AppTheme.getBackgroundGradient(bool isDark)   // LinearGradient
AppTheme.getCardColor(bool isDark)            // Color
AppTheme.getTextColor(bool isDark)            // Color
AppTheme.getSubtextColor(bool isDark)         // Color
AppTheme.getBorderColor(bool isDark)          // Color
AppTheme.primaryOrange                        // #ff6f2d
AppTheme.primaryBlue                          // #4a90e2
```

### Color and Gradient Contracts
```dart
// Dark mode (isDark = true)
- Background: Gradient from #0F0F23 → #1A1A2E → #16213E
- Cards: #2A2A3E with semi-transparent white gradient
- Text: White (#FFFFFF)
- Subtext: White with 70% opacity (#B3FFFFFF)
- Geometric element opacities: 0.3-0.5 (dark), 0.1-0.2 (light)

// Light mode (isDark = false)
- Background: Gradient from #F8FAFC → #E2E8F0
- Cards: #F1F5F9 with white gradient
- Text: #1E293B
- Subtext: #64748B
- Geometric element opacities: 0.1-0.2
```

## Delivery Phases

### Phase 1: Animation Foundation (Minimal Viable Product)
**Deliverable**: Apartment details screen with content fade-in and slide animations

**Tasks**:
1. Add _animationController and related animations to initState
2. Wrap main content in FadeTransition and SlideTransition
3. Add scale animations to key UI elements (title, buttons)
4. Implement animation disposal in dispose()
5. Apply animations to: title, location, price, info cards, buttons

**Verification**:
- Content should fade in and slide up on screen load
- Animations should be smooth with no jank
- Duration should be 800-1200ms
- Test in both debug and release builds

---

### Phase 2: Background Animation and Geometric Elements
**Deliverable**: Animated background with rotating geometric shapes matching auth screens

**Tasks**:
1. Add _backgroundController for continuous rotation
2. Create _buildAnimatedBackground() method with 3 geometric shapes:
   - Large rotating circle (top-right, 150x150)
   - Rounded rectangle (top-left, 100x100)
   - Small rotating circle (bottom-right, 60x60)
3. Use Transform.rotate() with animation values
4. Apply gradient fills to shapes
5. Stack animated background behind main content

**Verification**:
- Geometric shapes should rotate continuously at different speeds
- No performance impact (use AnimatedBuilder only for background)
- Shapes should be visible but not interfere with content readability
- Test rotation smoothness across 60fps

---

### Phase 3: Theme System Integration
**Deliverable**: Apartment details page supports dark/light theme switching

**Tasks**:
1. Replace all hardcoded colors with AppTheme methods
2. Remove hardcoded Color(0xFF0e1330) from AppBar background
3. Use ref.watch(themeProvider) to get isDark boolean
4. Update geometric shapes to use theme-aware opacity values
5. Update info cards with theme-aware styling
6. Update buttons with theme-aware colors
7. Update text colors (title, description, location) with theme support
8. Update login prompt styling with theme colors

**Verification**:
- Toggle theme and verify all elements change appropriately
- Dark mode: Check contrast and opacity levels
- Light mode: Check readability and color appropriateness
- Test on both devices and emulator

---

### Phase 4: Enhanced Visual Polish (Final Polish)
**Deliverable**: Complete design enhancement with gradient buttons and styled info cards

**Tasks**:
1. Apply gradient backgrounds to info cards
2. Add shadow effects to cards matching AppTheme.buttonDecoration
3. Apply gradient fill to booking/edit buttons
4. Add smooth transitions for button hover states (if applicable)
5. Update login prompt with card styling
6. Fine-tune geometric element positioning for visual hierarchy
7. Add subtle animations to interactive elements

**Verification**:
- Info cards should have gradient backgrounds
- Buttons should have gradient fills and shadows
- All interactive elements should respond smoothly to interaction
- Visual consistency with auth screens

---

## Verification Strategy

### Build and Lint Commands
```bash
cd client
flutter analyze                    # Static analysis
flutter pub get                    # Dependency check
flutter build apk --debug          # Build verification
```

### Manual Testing Checklist

#### Animation Testing
- [ ] Content fades in on screen load
- [ ] Content slides up with fade
- [ ] Scale animations apply to key elements
- [ ] Background geometric shapes rotate continuously
- [ ] No animation jank or stuttering
- [ ] Animations play once on load, background repeats

#### Theme Testing
- [ ] Toggle dark/light theme from settings
- [ ] All colors change appropriately in dark mode
- [ ] All colors change appropriately in light mode
- [ ] Text remains readable in both modes
- [ ] Geometric shapes opacity adjusts per theme

#### Responsive Testing
- [ ] Layout works on small phones (375x667)
- [ ] Layout works on large phones (414x896)
- [ ] SafeArea respected on all devices
- [ ] Geometric shapes don't obscure content
- [ ] Scrolling behavior unchanged

#### Visual Consistency Testing
- [ ] Compare with welcome_screen.dart styling
- [ ] Compare with login_screen.dart animations
- [ ] Compare with register_screen.dart theme usage
- [ ] Verify color values match AppTheme constants
- [ ] Verify gradient directions match reference screens

### Device Testing
- Test on minimum supported Flutter version
- Test on both iOS and Android
- Test on various screen sizes (small, medium, large)
- Test dark and light theme modes
- Test with slow animations enabled (accessibility)

### Performance Verification
- Monitor frame rate during animation (target 60fps)
- Check memory usage with DevTools
- Verify no animation frame drops during scrolling
- Test on low-end devices if possible

---

## Implementation Notes

### Animation Patterns from Reference Screens

**Welcome Screen Pattern**:
```dart
late AnimationController _animationController;
late AnimationController _backgroundController;

void _initAnimations() {
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );
  _backgroundController = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();
}
```

**Application to Apartment Details**:
- Keep _backgroundController for geometric shapes
- Add _animationController for content entry animations
- Apply FadeTransition + SlideTransition to main content
- Wrap content in AnimatedBuilder for animation triggers

### Theme Integration Pattern from Login Screen

**Reference Pattern**:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
// OR
final isDarkMode = ref.watch(themeProvider);
```

**Application to Apartment Details**:
- Use `ref.watch(themeProvider)` (Riverpod pattern already in file)
- Pass `isDark` to all helper methods building UI
- Use AppTheme methods instead of literal Colors

### Color Palette
- **Orange**: #ff6f2d (primary action, highlights)
- **Blue**: #4a90e2 (secondary, animations)
- **Green**: #10B981 (success states, booking confirmation)
- **Dark Primary**: #0F0F23 (dark mode background)
- **Light Primary**: #F8FAFC (light mode background)

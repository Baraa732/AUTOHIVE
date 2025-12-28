# Feature Specification: Mobile Navbar Redesign with Advanced Animations

## Overview
Redesign the mobile navigation bar to match the modern, sleek design from the reference navbar.html file. The new navbar will feature a floating circular indicator with glow effects, curved cutout design, and smooth animations that enhance the user experience.

## User Stories

### User Story 1 - Visual Navigation with Active Indicator
**As a** user navigating the app, **I want to** clearly see which section I'm currently viewing with a prominent visual indicator, **so that** I always know my current location in the app.

**Acceptance Scenarios**:
1. **Given** I'm on the Home screen, **When** I view the navbar, **Then** a floating circular indicator displays above the Home icon with a green accent color and glow effect
2. **Given** I tap on the Bookings tab, **When** the screen transitions, **Then** the floating indicator smoothly animates to above the Bookings icon
3. **Given** the navbar is active, **When** I look at the indicator, **Then** I see a subtle glow/shadow effect around it

### User Story 2 - Smooth Navigation Transitions
**As a** user, **I want to** experience smooth, responsive animations when switching between navigation tabs, **so that** the app feels polished and responsive.

**Acceptance Scenarios**:
1. **Given** I tap a navigation item, **When** the transition occurs, **Then** the indicator animates smoothly using cubic-bezier easing
2. **Given** the navbar is animating, **When** I tap another item, **Then** the animation completes smoothly without jarring movements
3. **Given** I'm using the app regularly, **When** I switch tabs multiple times, **Then** the animations maintain consistent timing and fluidity

### User Story 3 - Visual Consistency with App Theme
**As a** user of the AUTOHIVE app, **I want to** see the navbar styled consistently with the app's dark theme and green accent color, **so that** the design feels cohesive throughout the app.

**Acceptance Scenarios**:
1. **Given** I'm in dark mode, **When** I view the navbar, **Then** it uses dark background (#111 or similar) with white/light icons
2. **Given** an item is active, **When** I view the navbar, **Then** the accent color is green (#6CFF5B or similar) matching the design
3. **Given** I'm viewing a secondary item, **When** I look at its icon, **Then** it displays in a dimmed color (not active)

### User Story 4 - Icon and Label Display
**As a** user, **I want to** see both icons and labels for navigation items, **so that** I can quickly identify each section.

**Acceptance Scenarios**:
1. **Given** I'm viewing the navbar at rest, **When** a navigation item is inactive, **Then** only the icon is prominent
2. **Given** I hover or focus on an icon, **When** I look below it, **Then** a label appears with smooth opacity animation
3. **Given** an item is active, **When** I view the navbar, **Then** both the icon and label display in the accent color

## Requirements

### Visual Design Requirements
- **Background**: Dark background color matching the app's theme (#111 or equivalent)
- **Accent Color**: Bright green accent color for active states (#6CFF5B or equivalent)
- **Secondary Color**: Purple/secondary color for highlights (optional, from design)
- **Floating Indicator**: Circular floating element above the navbar showing the active tab
- **Indicator Effects**: Glow/shadow effect around the indicator for depth
- **Curved Cutout**: Curved cutout in the navbar bar that follows the indicator position
- **Border Radius**: Rounded corners on navbar (22px from reference design)

### Animation Requirements
- **Transition Timing**: 0.55s cubic-bezier(.4, 0, .2, 1) for smooth indicator movement
- **Icon Animation**: Icons scale and translate upward when active
- **Label Animation**: Labels fade in/out with color change based on active state
- **Hover Effects**: Non-active items should have subtle hover effects

### Functional Requirements
- **Navigation Items**: Home, Bookings, Add (List), Profile
- **Icon Support**: Use FontAwesome icons matching the design
- **Touch Responsiveness**: Taps register immediately with visual feedback
- **State Persistence**: Navbar remembers the active item across screen navigation
- **Responsive Design**: Navbar adapts to different screen sizes

### Technical Requirements
- **Flutter Implementation**: Use Flutter widgets and animations
- **Riverpod State Management**: Integrate with existing state management
- **Theme Integration**: Support both light and dark themes
- **Performance**: Smooth 60fps animations on target devices
- **Backward Compatibility**: Maintain existing navigation functionality

## Success Criteria

1. ✅ The navbar displays with dark background and green accent color matching the HTML design
2. ✅ Floating circular indicator appears above the navbar, positioned above the active item
3. ✅ Indicator animates smoothly (0.55s) when switching between navigation items
4. ✅ Glow/shadow effect is visible around the indicator
5. ✅ Curved cutout in the navbar follows the indicator position
6. ✅ Icons display with labels below them
7. ✅ Active items show in green accent color, inactive items in dimmed color
8. ✅ All four navigation items (Home, Bookings, Add, Profile) function correctly
9. ✅ Animations maintain 60fps performance on real devices
10. ✅ Navbar integrates seamlessly with existing app screens
11. ✅ Design works responsively on various screen sizes
12. ✅ Visual design matches the reference navbar.html as closely as possible

## Design Notes

### Color Palette
- Background: `#111` (very dark gray/black)
- Accent: `#6CFF5B` (bright lime green)
- Secondary: `#8b5cf6` (purple for accents)
- Text Light: `#f8fafc` (off-white)
- Text Dim: `#94a3b8` (light gray)

### Key Visual Elements
1. **Floating Indicator**: 60px circle positioned above the navbar
2. **Curved Cutout**: 80px wide curved section that creates the opening
3. **Glow Effect**: Drop shadow with green color for visual depth
4. **Icon Size**: 22px for normal icons
5. **Label Font Size**: 10px uppercase text

### Animation Curve
`cubic-bezier(0.4, 0, 0.2, 1)` - Material smooth easing

## Constraints & Considerations

- Must maintain backward compatibility with existing screens
- Should not introduce new dependencies unless necessary
- Performance must not degrade on lower-end devices
- Animations should respect device accessibility settings (if available)

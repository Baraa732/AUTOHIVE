# Feature Specification: Apartment Details Page Design Enhancement

## User Stories

### User Story 1 - Consistent Design Language
**Acceptance Scenarios**:

1. **Given** I'm viewing an apartment details page, **When** the page loads, **Then** I see animations matching the welcome/login/register screens (fade-in, slide-up, scale effects)
2. **Given** I'm on the apartment details page in dark mode, **When** I toggle to light mode, **Then** the design adapts with appropriate theme colors
3. **Given** I'm viewing the apartment header, **When** the page is displayed, **Then** I see animated geometric shapes (circles and rounded rectangles) in the background similar to auth screens

### User Story 2 - Enhanced Visual Polish
**Acceptance Scenarios**:

1. **Given** I'm viewing apartment info cards (beds, baths, area), **When** they appear on screen, **Then** they have styled gradient backgrounds and animations
2. **Given** I'm viewing the booking button, **When** the page loads, **Then** it has gradient styling and shadow effects matching the auth screens
3. **Given** I'm scrolling through apartment details, **When** the content appears, **Then** text elements fade in with slide transitions for a smooth experience

---

## Requirements

### Design System Requirements
- Apply the AUTOHIVE design system used in Welcome, Login, and Register screens
- Support dark and light themes using `AppTheme` methods
- Use the primary color scheme: Orange (#ff6f2d) and Blue (#4a90e2)
- Implement gradient backgrounds matching existing screens
- Add animated geometric elements (rotating circles and rounded rectangles)

### Animation Requirements
- Entry animations: fade-in with slide-up effect for main content
- Animated background with rotating geometric shapes
- Smooth transitions for interactive elements
- Duration: ~800-1200ms for main animations, 20-second loop for background rotation

### Theme Support
- Dark mode: Darker gradients with semi-transparent geometric shapes
- Light mode: Lighter gradients with appropriate opacity adjustments
- Consistent use of AppTheme methods: `getBackgroundGradient()`, `getCardColor()`, `getTextColor()`, `getSubtextColor()`, `getBorderColor()`

### Visual Hierarchy
- Enhanced info cards with gradient styling
- Styled buttons with gradients and shadows
- Proper spacing and typography alignment
- Visual feedback for interactive elements

---

## Success Criteria

1. ✅ Apartment details page matches design aesthetic of auth screens
2. ✅ All animations (entrance, background rotation) work smoothly
3. ✅ Dark/Light theme toggle works correctly across all elements
4. ✅ Responsive design maintained for mobile devices
5. ✅ Geometric background elements visible without impacting readability
6. ✅ No performance degradation from animations
7. ✅ Color gradients and shadows render correctly on different devices

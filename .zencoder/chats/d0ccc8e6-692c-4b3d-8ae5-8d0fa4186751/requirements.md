# Feature Specification: Home Screen Apartment Card Design Redesign

## Overview
Fix the apartment card layout on the home screen to match the apartment details screen design. The image should cover the full width of the card panel, and the favorite button should overlay on top of the image in the top-right corner.

---

## User Stories

### User Story 1 - View Apartments with Proper Card Layout
**Acceptance Scenarios**:

1. **Given** the user is on the home screen, **When** apartments are displayed in the list, **Then** each apartment card should have the image covering the full width of the card panel (not leaving space on the sides)

2. **Given** an apartment card is displayed, **When** the user looks at the card, **Then** the favorite button should appear as a white circular button overlaid on top of the image in the top-right corner

3. **Given** a user is viewing an apartment card, **When** the card is compared with the apartment details screen, **Then** the layout structure should be consistent with the details screen design

---

## Requirements

### Functional Requirements
1. **Image Display**: Apartment images must cover the full width of the card panel with proper rounded corners at the top
2. **Favorite Button Positioning**: The favorite button must be positioned absolutely in the top-right corner of the image, overlaying on top of it
3. **Button Styling**: The favorite button should:
   - Be displayed as a white circular container
   - Have a red heart icon (filled when favorited, outline when not)
   - Include box shadow for visual separation from the image
   - Support favorite/unfavorite functionality
4. **Apartment Details**: Card details (title, location, amenities, price, owner) should remain displayed below the image
5. **Responsive Design**: The layout should adapt properly across different screen sizes

### Non-Functional Requirements
1. **Performance**: No performance degradation compared to previous implementation
2. **Code Quality**: Lint checks pass without new errors
3. **Consistency**: Layout should match the apartment details screen design pattern
4. **Accessibility**: Heart icon button should be easily tappable (48x48dp minimum touch area)

---

## Success Criteria

1. ✅ Apartment card image covers full width of the card panel
2. ✅ Favorite button overlays on top-right of the image (not beside it)
3. ✅ Favorite button has proper white background and shadow
4. ✅ Favorite/unfavorite functionality works correctly
5. ✅ Layout is consistent with apartment details screen
6. ✅ Card details are properly displayed below the image
7. ✅ Lint analysis shows no new errors
8. ✅ Design works across light and dark themes
9. ✅ Card navigation to details screen still functions correctly

---

## Design Notes

- **Image Height**: 200px (maintains aspect ratio with full-width constraint)
- **Card Margin**: 16px horizontal, 6px vertical
- **Border Radius**: 16px with top-only rounded corners on image
- **Favorite Button**: Positioned at top: 8px, right: 8px with white background and circular shape
- **Color Scheme**: White button with red heart icon, maintains theme compatibility for dark/light modes

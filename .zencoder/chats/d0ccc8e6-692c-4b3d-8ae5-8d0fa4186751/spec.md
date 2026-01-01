# Technical Specification: Home Screen Apartment Card Design Redesign

## Technical Context

- **Language**: Dart 3.10.3+
- **Framework**: Flutter (Material Design 3)
- **State Management**: Riverpod 2.4.9
- **Primary Dependencies**:
  - `flutter_riverpod`: State management for favorites
  - `cached_network_image`: Image caching and loading
  - Custom `AppCachedNetworkImage` widget for consistent image handling
  - Theme system using `themeProvider` for dark/light mode support

## Technical Implementation Brief

The apartment card redesign involves restructuring the layout to use a `Stack` widget hierarchy:

1. **Card Container**: Base card with gradient background, border, and shadow
2. **Stack Layout**: Contains image layer and positioned favorite button overlay
3. **Image Layer**: Full-width image with `ClipRRect` for rounded corners
4. **Overlay Layer**: Positioned favorite button button using `Positioned` widget

Key decision: Move the favorite button from inside the image widget (`_buildApartmentImage`) to the card's Stack level. This ensures proper z-index layering and maintains consistent positioning.

The implementation reuses existing components:
- `AppCachedNetworkImage` for image loading with caching
- `favoriteProvider` from Riverpod for favorite state management
- Theme utilities for consistent styling across light/dark modes
- Consumer widget for reactive favorite state updates

---

## Source Code Structure

```
lib/presentation/screens/shared/enhanced_home_screen.dart
├── _buildApartmentCard()
│   ├── Stack
│   │   ├── _buildApartmentImage()
│   │   └── Positioned (favorite button overlay)
│   └── Padding
│       └── Details Section (title, location, amenities, price)
├── _buildApartmentImage()
│   └── ClipRRect
│       └── AppCachedNetworkImage
└── _buildStatusBadge()
    (Availability status badge)
```

---

## Contracts

### Modified Widgets

#### 1. `_buildApartmentCard(Apartment apartment, int index) → Widget`
**Changes**:
- Restructured main Column to include Stack for image + overlay
- Added Stack with _buildApartmentImage and Positioned favorite button
- Moved favorite button logic from _buildApartmentImage to Positioned widget

**Returns**: GestureDetector wrapping Container with the redesigned layout

**Dependencies**:
- `favoriteProvider`: For favorite state management
- `themeProvider`: For theme colors
- `Apartment` model: Data structure for apartment info
- `ApartmentDetailsScreen`: Navigation target

---

#### 2. `_buildApartmentImage(Apartment apartment) → Widget`
**Changes**:
- Removed nested Stack that previously contained favorite button
- Simplified to return ClipRRect with AppCachedNetworkImage
- Removed all favorite button positioning logic

**Returns**: ClipRRect wrapping Container with cached image or placeholder

**Dependencies**:
- `AppCachedNetworkImage`: For network image caching
- `AppConfig.getImageUrlSync()`: For image URL resolution

---

#### 3. Positioned Favorite Button (New Structure)
**Location**: Inside Stack at card level (lines 833-879 in enhanced_home_screen.dart)

**Properties**:
```dart
Positioned(
  top: 8,      // Padding from top of image
  right: 8,    // Padding from right of image
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [...]
    ),
    child: IconButton(...)
  )
)
```

---

## Delivery Phases

### Phase 1: Layout Restructuring (COMPLETED)
**Deliverable**: Apartment card with full-width image and overlaid favorite button

**Implementation**:
- Restructure `_buildApartmentCard()` to use Stack layout
- Create Positioned favorite button overlay in Stack
- Simplify `_buildApartmentImage()` to remove nested Stack
- Ensure favorite/unfavorite functionality works correctly
- Maintain consistent styling with theme system

**Verification**:
- Visual inspection on different devices/emulators
- Lint analysis passes (`flutter analyze`)
- No new errors or warnings introduced
- Favorite button click functionality verified

---

## Verification Strategy

### Manual Verification Steps

1. **Build and Run**:
   ```bash
   cd client
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Visual Inspection**:
   - Open home screen
   - Verify apartment cards display with full-width images
   - Verify favorite button appears in top-right corner of image
   - Compare layout with apartment details screen
   - Test on different screen sizes (phone, tablet)
   - Test in light and dark themes

3. **Functionality Verification**:
   - Click favorite button to add apartment to favorites
   - Verify heart icon changes from outline to filled
   - Click again to remove from favorites
   - Verify snackbar notifications appear
   - Verify navigation to details screen still works

4. **Code Quality**:
   ```bash
   cd client
   flutter analyze lib/presentation/screens/shared/enhanced_home_screen.dart
   ```
   - No new errors or warnings
   - Existing deprecation warnings are pre-existing (safe to ignore)

### Testing Checklist

- [ ] Image covers full card width on 320dp screen
- [ ] Image covers full card width on 480dp screen
- [ ] Image covers full card width on tablet (600dp+)
- [ ] Favorite button positioned at top-right (8px offset)
- [ ] Favorite button is clickable and responsive
- [ ] Favorite/unfavorite state toggles correctly
- [ ] Theme colors adapt correctly in dark mode
- [ ] Card details display correctly below image
- [ ] Card navigation works when tapping card
- [ ] No performance regression in list scrolling

---

## Implementation Notes

### Code Reuse
- Leverages existing `AppCachedNetworkImage` widget
- Uses established `favoriteProvider` from Riverpod
- Maintains consistent theme system usage
- Follows existing button and container styling patterns

### Design Consistency
- Matches apartment details screen layout pattern
- Uses same image sizing (200px height)
- Consistent card spacing and padding
- White button with shadow for proper visual hierarchy

### Performance Considerations
- Stack layout is lightweight and performant
- No additional API calls or state management changes
- Image caching remains unchanged
- Positioned widget is efficient for single overlay

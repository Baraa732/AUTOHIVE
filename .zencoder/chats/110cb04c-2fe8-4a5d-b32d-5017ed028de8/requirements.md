# Feature Specification: Fix Governorate Selector Overflow in Add Apartment Screen

## User Stories

### User Story 1 - Fix Layout Overflow in Location Section

**Acceptance Scenarios**:

1. **Given** the user is on the "Add Apartment" screen, **When** they scroll to the "Location" section, **Then** the Governorate and City dropdowns should be visible side-by-side without any horizontal overflow.
2. **Given** a small screen device, **When** the "Add Apartment" screen is rendered, **Then** the location selectors should adjust their width to fit the screen without overflowing.

---

## Requirements

1. **Fix Overflow**: Resolve the 12-pixel right overflow in the `_buildLocationSection` of `AddApartmentScreen`.
2. **Responsive Design**: Ensure the fix does not break the layout on larger screens and maintains the side-by-side layout if possible, or wraps if necessary.
3. **Consistency**: Maintain the existing styling (icons, borders, colors) of the dropdown selectors.

## Success Criteria

1. No "A RenderFlex overflowed by 12 pixels on the right" (or similar) error in the Flutter debug console.
2. The Location section is visually correct and contained within its parent container.

# Technical Specification: Fix Governorate Selector Overflow

## Technical Context
- **Language/Framework**: Flutter (Dart)
- **Component**: `AddApartmentScreen` in `client/lib/presentation/screens/shared/add_apartment_screen.dart`
- **Issue**: `RenderFlex` overflow (12 pixels) in the Location section's `Row` containing two `DropdownButtonFormField` widgets. The overflow occurs because the internal `Row` of the `DropdownButton` (containing the selected value and dropdown icon) exceeds the available width, especially with the `prefixIcon` present in the `InputDecoration`.

## Technical Implementation Brief
To resolve the overflow, we will:
1. Ensure `isExpanded: true` is set on both `DropdownButtonFormField` widgets to allow the selected text to truncate if necessary.
2. Adjust the `prefixIcon` or layout if `isExpanded` alone doesn't fix it. 
3. Consider wrapping the `Row` in a `Wrap` widget or using a `Column` for the selectors on very narrow screens, although the plan suggests fixing the current layout.
4. Set `isDense: true` in the `InputDecoration` to reduce internal padding if needed.

## Source Code Structure
- `client/lib/presentation/screens/shared/add_apartment_screen.dart`: Modify `_buildLocationSection` and potentially `_getInputDecoration`.

## Contracts
No changes to data models or APIs are required. This is a UI-only fix.

## Delivery Phases
1. **Phase 1: Apply Layout Fixes**: Update `_buildLocationSection` with `isExpanded: true` and layout adjustments.
2. **Phase 2: Verification**: Verify the fix on simulated screen widths or by checking for RenderFlex errors.

## Verification Strategy
- **Manual Verification**: Run the app and navigate to the "Add Apartment" screen. Verify that the Location section no longer shows the overflow warning.
- **Helper Script**: Create a small Flutter test script (if possible in this environment) or instructions to verify the widget constraints. Since I can't easily run a full Flutter UI test with visual feedback here, I will rely on code analysis and ensuring the `isExpanded` property is correctly applied, which is the standard fix for this specific Flutter error.
- **Lint**: Run `flutter analyze` if available to ensure no regressions.

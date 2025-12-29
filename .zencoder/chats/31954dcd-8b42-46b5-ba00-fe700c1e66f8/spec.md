# Technical Specification: Sliver-Based Home Page Architecture

## Technical Context
- **Language**: Dart with Flutter framework
- **Primary Dependencies**: Riverpod (state management), Flutter Material widgets
- **Existing Architecture**: Column + ListView with manual scroll controller
- **Theme System**: Custom AppTheme with dark/light mode support
- **Animation Framework**: AnimationController with Tween animations

## Technical Implementation Brief

### Current Architecture Issues
The existing `ModernHomeScreen` uses a Column wrapping a ListView, which doesn't provide optimal scrolling behavior for sticky headers. The search/filter UI is inside a static header that scrolls away.

### Solution Approach
Convert to **CustomScrollView** with **SliverAppBar** for the sticky header containing search and filters, followed by **SliverList** for apartments.

**Key Technical Decisions**:
1. Use `SliverAppBar` with `floating: true, pinned: true` for the sticky header
2. Keep existing animations by wrapping them within the sliver context
3. Use `SliverList` with filtered apartment data instead of ListView.builder
4. Maintain `RefreshIndicator` wrapper around CustomScrollView for pull-to-refresh
5. Preserve all filter/search logic in `_applyFilters()` method
6. Keep AnimationController instances for header entrance animations
7. Use same card building logic within SliverList itemBuilder

### Architecture Diagram
```
RefreshIndicator
└── CustomScrollView
    ├── SliverAppBar (floating: true, pinned: true)
    │   └── Header with search + filters + animations
    └── SliverList
        └── Apartment cards (gridDelegate or itemBuilder)
```

## Source Code Structure

### Files to Modify
1. **`client/lib/presentation/screens/shared/modern_home_screen.dart`** - Main refactor
   - Replace Column + ListView structure with CustomScrollView
   - Move header to SliverAppBar flexibleSpace
   - Convert ListView.builder to SliverList

### No New Files Required
- Reuse existing theme utilities (AppTheme)
- Reuse existing API service (ApiService)
- Reuse existing widgets (AppCachedNetworkImage, ThemeToggleButton)

## Contracts

### No Data Model Changes
All existing data models remain unchanged:
- `Apartment` model structure unchanged
- API response handling unchanged
- Filter/search logic unchanged

### Widget Interface Changes
- Internal only: `_buildApartmentsList()` refactored to use CustomScrollView
- Public interface: `ModernHomeScreen` remains unchanged

## Delivery Phases

### Phase 1: Refactor to CustomScrollView (MVP)
**Goal**: Convert existing UI to sliver structure while preserving all functionality

**Deliverable**:
- Replace Column + ListView with CustomScrollView
- Create SliverAppBar with existing header content
- Convert ListView.builder to SliverList.builder
- Verify all filters, search, and navigation work identically

**Verification**:
- Run `flutter analyze` to ensure no lint errors
- Manual testing: Load app, scroll apartments, verify header sticks
- Verify filters work: Select location/price, confirm filtering
- Verify search works: Type in search, confirm results update
- Verify animations: Check header entrance animation plays smoothly

### Phase 2: Polish and Optimization
**Goal**: Fine-tune visual consistency and performance

**Deliverable**:
- Adjust SliverAppBar height and expand behavior
- Ensure smooth animation transitions when header becomes sticky
- Test with 50+ apartments for performance
- Verify dark/light theme consistency

**Verification**:
- Scroll performance test: 60 FPS maintained while scrolling
- Theme switch: Toggle dark/light mode, verify no visual glitches
- Empty/Loading states: Test with filter that returns no results

## Verification Strategy

### 1. Lint Verification
```bash
cd client
flutter analyze
```
Expected: No errors or warnings

### 2. Manual Testing Checklist
Create test script or manual verification steps:

**Scroll & Header Stickiness**:
- [ ] Load home page
- [ ] Scroll down 3-4 apartment cards
- [ ] Verify search bar + filters stay visible at top
- [ ] Continue scrolling to bottom
- [ ] Verify header remains sticky throughout

**Filtering & Search**:
- [ ] Type in search bar, verify results filter in real-time
- [ ] Change location filter, verify apartments update
- [ ] Change price filter, verify apartments update
- [ ] Combine filters, verify results are correct
- [ ] Clear filters, verify all apartments show

**Animations**:
- [ ] Load page, verify header slides in from top
- [ ] Observe smooth entrance animation
- [ ] Verify no animation jank during scroll

**Theme Support**:
- [ ] Load page in light mode, scroll, verify colors
- [ ] Toggle to dark mode, scroll, verify colors consistent
- [ ] Toggle back to light mode, verify no visual artifacts

**Navigation & Interactions**:
- [ ] Click apartment card, verify navigation to details
- [ ] Click owner profile, verify dialog shows
- [ ] Pull to refresh, verify apartments reload

**Edge Cases**:
- [ ] Empty results: Apply filter with no matches, verify "No apartments found" message
- [ ] Loading state: Verify spinner during data load
- [ ] Network error: Verify error handling works

### 3. Build Verification
```bash
cd client
flutter build apk --debug
# or
flutter run
```
Expected: App builds and runs without errors

### Helper Scripts
None required - Flutter provides built-in testing capabilities via `flutter analyze` and manual UI testing.

### Sample Input Artifacts
- Use real API data from running instance
- Or mock data if API unavailable
- Test with various apartment counts (5, 50, 100+)

## Testing Commands to Run

```bash
# Lint check
flutter analyze

# Run the app
flutter run

# Run tests (if any exist)
flutter test
```

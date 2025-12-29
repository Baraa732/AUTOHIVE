# Feature Specification: Sliver-Based Home Page Architecture

## Overview
Refactor the home page to use a CustomScrollView with Sliver widgets to improve scrolling performance, enhance UI interactions, and provide a sticky header for search and filtering functionality.

## User Stories

### User Story 1 - Search and Filter Persist While Scrolling
**Acceptance Scenarios**:

1. **Given** user is on home page with apartment list, **When** user scrolls down through apartments, **Then** search bar and filters remain visible at the top (sticky header)
2. **Given** user has apartments visible, **When** user applies a filter or searches, **Then** the filtered results load smoothly without page jump

### User Story 2 - Smooth Scrolling Experience
**Acceptance Scenarios**:

1. **Given** user loads the home page with 50+ apartments, **When** user scrolls through the list, **Then** scroll performance is smooth with no jank
2. **Given** user is scrolling, **When** reaching the bottom of the list, **Then** new content loads seamlessly without interruption

### User Story 3 - Visual Consistency
**Acceptance Scenarios**:

1. **Given** user scrolls and the header becomes sticky, **When** header state changes, **Then** animations continue smoothly without visual glitches
2. **Given** dark mode is enabled, **When** user scrolls and header sticks, **Then** colors and styling remain consistent

## Requirements

### Functional Requirements
1. **Sliver Architecture**: Convert the existing Column + ListView structure to CustomScrollView with multiple slivers
2. **Sticky Header**: Search bar and filters should stick to the top during scroll
3. **Animated Header**: Preserve existing header animations while adapting to sliver context
4. **Search Functionality**: Search must work seamlessly with sliver list filtering
5. **Filter Dropdowns**: Location and Price filters must remain functional
6. **Apartment Cards**: Display apartment cards with all existing information and interactions
7. **Empty State**: Show appropriate message when no apartments match filters
8. **Loading State**: Display loading indicator during data fetch
9. **Refresh**: Pull-to-refresh functionality must work with CustomScrollView

### Non-Functional Requirements
1. **Performance**: Improve scroll performance compared to Column + ListView approach
2. **Compatibility**: Maintain dark/light theme support
3. **Consistency**: Preserve all existing animations and styling
4. **Accessibility**: Maintain proper semantic structure

## Success Criteria

1. ✅ Home page uses CustomScrollView with at least 2 slivers (header and list)
2. ✅ Search bar and filters remain sticky at the top during scroll
3. ✅ All existing filtering and search functionality works identically
4. ✅ Apartment cards render smoothly without performance degradation
5. ✅ Animations (header entry, card animations) continue to work
6. ✅ Dark/light theme switching works seamlessly
7. ✅ Pull-to-refresh works with the new architecture
8. ✅ Loading and empty states display correctly
9. ✅ No TypeScript/Dart lint or compilation errors
10. ✅ All existing feature functionalities preserved (owner profile, navigation, etc.)

# Localization Implementation Guide

## Overview
This guide explains how to implement English/Arabic language switching with automatic RTL/LTR support in the AUTOHIVE Flutter application.

## Features Implemented
- ✅ English and Arabic language support
- ✅ Automatic RTL (Right-to-Left) for Arabic
- ✅ Automatic LTR (Left-to-Right) for English
- ✅ Persistent language selection
- ✅ Static text translation only (dynamic content remains unchanged)

## Files Created/Modified

### 1. New Files Created:
- `lib/core/localization/app_localizations.dart` - Translation strings
- `lib/presentation/providers/locale_provider.dart` - Language state management
- `lib/presentation/screens/auth/login_screen_localized.dart` - Example implementation

### 2. Modified Files:
- `pubspec.yaml` - Added flutter_localizations
- `lib/main.dart` - Added localization support and RTL/LTR handling

## How to Use

### Step 1: Run Flutter Pub Get
```bash
cd client
flutter pub get
```

### Step 2: Using Translations in Your Screens

```dart
import '../../../core/localization/app_localizations.dart';

class YourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('home')), // Translates to 'Home' or 'الرئيسية'
      ),
      body: Column(
        children: [
          Text(l10n.translate('welcome_back')),
          Text(l10n.translate('phone_number')),
          // Dynamic content (user data) stays as-is
          Text(userName), // This won't be translated
        ],
      ),
    );
  }
}
```

### Step 3: Adding Language Toggle Button

```dart
import '../../providers/locale_provider.dart';

// In your widget:
IconButton(
  icon: const Icon(Icons.language),
  onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
)
```

### Step 4: Adding New Translations

Edit `lib/core/localization/app_localizations.dart`:

```dart
static final Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'your_new_key': 'Your English Text',
    // ... existing translations
  },
  'ar': {
    'your_new_key': 'النص العربي الخاص بك',
    // ... existing translations
  },
};
```

Then use it:
```dart
Text(l10n.translate('your_new_key'))
```

## Available Translations

### Authentication
- welcome_back, sign_in_to_continue, your_home_awaits
- phone_number, password, enter_your_password
- login, register, create_account, join_us_today
- first_name, last_name, confirm_password
- select_role, tenant, landlord

### Navigation
- home, favorites, bookings, profile

### Settings
- settings, language, theme, dark_mode, light_mode
- logout, account, notifications

### Common
- search, filter, apply, cancel, save, delete, edit
- back, next, done, loading, error, success
- confirm, yes, no, ok

### Validation Messages
- phone_required, phone_invalid, password_required
- first_name_required, last_name_required
- passwords_not_match, role_required

## RTL/LTR Behavior

The app automatically switches text direction based on the selected language:
- **English (en)**: Left-to-Right (LTR)
- **Arabic (ar)**: Right-to-Left (RTL)

This affects:
- Text alignment
- Icon positions
- Navigation drawer direction
- Input field cursor position
- Scroll direction

## Example Implementation

See `lib/presentation/screens/auth/login_screen_localized.dart` for a complete example of:
- Using translations
- Adding language toggle button
- Handling RTL/LTR layouts
- Translating validation messages

## Updating Existing Screens

To update an existing screen:

1. Import localization:
```dart
import '../../../core/localization/app_localizations.dart';
```

2. Get localization instance:
```dart
final l10n = AppLocalizations.of(context);
```

3. Replace hardcoded strings:
```dart
// Before:
Text('Phone Number')

// After:
Text(l10n.translate('phone_number'))
```

4. Keep dynamic content unchanged:
```dart
// User data, API responses, etc. - NO translation
Text(user.name)
Text(apartment.address)
```

## Testing

1. Run the app
2. Navigate to login screen
3. Click the language icon (🌐) in the header
4. Observe:
   - Text changes to Arabic/English
   - Layout direction changes (RTL/LTR)
   - Input fields align correctly
   - Buttons and icons reposition

## Notes

- Language preference is saved locally using SharedPreferences
- The app remembers the selected language on restart
- Only static UI elements are translated
- User-generated content and API data remain in their original language
- The AUTOHIVE brand name is never translated

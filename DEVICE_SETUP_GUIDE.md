# AUTOHIVE Device Setup Guide

## Backend Setup for Device Testing

### 1. Start Laravel Backend
```bash
cd server
php artisan serve --host=0.0.0.0 --port=8000
```

**Important**: Always use `--host=0.0.0.0` to allow external connections from physical devices.

### 2. Your Current Network Configuration
- **Ethernet IP**: `10.65.2.42` (for wired connection)
- **Hotspot IP**: `192.168.137.1` (for mobile hotspot)
- **Emulator IP**: `10.0.2.2` (for Android Studio emulator)

## Frontend Setup

### For Android Studio Emulator
1. Open Android Studio
2. Start an Android Virtual Device (AVD)
3. Run the Flutter app:
```bash
cd client
flutter run
```
The app will automatically use `http://10.0.2.2:8000/api`

### For Physical Device (USB Debugging)
1. Enable Developer Options on your phone:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. Connect your phone via USB
3. Run the Flutter app:
```bash
cd client
flutter run
```
The app will automatically detect and use your network IP.

### For Physical Device (Wireless)
1. Connect your phone to the same WiFi network as your computer
2. Or enable mobile hotspot on your phone and connect your computer to it
3. Run the Flutter app:
```bash
cd client
flutter run
```

## Troubleshooting Connection Issues

### If you get "Connection Failed" error:

1. **Check Backend Status**:
   ```bash
   # Make sure backend is running with correct host
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **Test Backend Manually**:
   - Open browser and go to: `http://10.65.2.42:8000/api`
   - You should see a response (not an error page)

3. **Check Firewall**:
   - Windows Firewall might block connections
   - Allow PHP through Windows Firewall
   - Or temporarily disable firewall for testing

4. **Reset App Connection**:
   - Clear app data or reinstall the app
   - The app will automatically test all configured URLs

### Network-Specific Solutions:

**For Ethernet Connection (10.65.2.42)**:
- Ensure your phone is on the same network
- Backend URL: `http://10.65.2.42:8000/api`

**For Mobile Hotspot (192.168.137.1)**:
- Enable hotspot on your phone
- Connect your computer to the phone's hotspot
- Backend URL: `http://192.168.137.1:8000/api`

**For Android Emulator**:
- Use Android Studio's built-in emulator
- Backend URL: `http://10.0.2.2:8000/api`

## Quick Commands

### Start Backend (Always use this for device testing):
```bash
cd server
php artisan serve --host=0.0.0.0 --port=8000
```

### Run Flutter App:
```bash
cd client
flutter run
```

### Check Connected Devices:
```bash
flutter devices
```

### Run on Specific Device:
```bash
flutter run -d <device-id>
```

## Connection Manager Features

The app automatically:
- Tests multiple IP addresses
- Caches the working URL
- Falls back to emulator IP if others fail
- Retries connections in the background

Your configured URLs (in priority order):
1. `http://10.0.2.2:8000/api` (Android Emulator)
2. `http://10.65.2.42:8000/api` (Your Ethernet IP)
3. `http://192.168.137.1:8000/api` (Your Hotspot IP)
4. `http://127.0.0.1:8000/api` (Localhost)
5. `http://localhost:8000/api` (Alternative localhost)
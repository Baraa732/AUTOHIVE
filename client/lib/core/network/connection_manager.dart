import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionManager {
  // Simple URLs for Android Emulator
  static const List<String> _urls = [
    'http://10.0.2.2:8000/api',       // Android Emulator (Laravel default)
    'http://127.0.0.1:8000/api',      // Localhost
    'http://localhost:8000/api',      // Alternative localhost
    'http://192.168.1.100:8000/api',  // Local network IP (adjust as needed)
  ];

  static String? _workingUrl;
  static const String _urlCacheKey = 'cached_working_url';
  static bool _isTestingUrls = false;

  static Future<String> getWorkingUrl() async {
    // Return cached URL immediately if available
    if (_workingUrl != null) {
      return _workingUrl!;
    }

    // Try to get cached URL from storage
    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString(_urlCacheKey);
    
    if (cachedUrl != null) {
      _workingUrl = cachedUrl;
      // Test in background without blocking
      _testUrlInBackground(cachedUrl);
      return cachedUrl;
    }

    // Use default URL immediately for Android emulator
    const defaultUrl = 'http://10.0.2.2:8000/api';
    _workingUrl = defaultUrl;
    
    // Test URLs in background
    _testUrlsInBackground();
    
    return defaultUrl;
  }

  static void _testUrlInBackground(String url) async {
    if (_isTestingUrls) return;
    _isTestingUrls = true;
    
    try {
      final isWorking = await _testUrl(url);
      if (!isWorking) {
        // If cached URL doesn't work, find a working one
        await _findWorkingUrl();
      }
    } finally {
      _isTestingUrls = false;
    }
  }

  static void _testUrlsInBackground() async {
    if (_isTestingUrls) return;
    _isTestingUrls = true;
    
    try {
      await _findWorkingUrl();
    } finally {
      _isTestingUrls = false;
    }
  }

  static Future<void> _findWorkingUrl() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (String url in _urls) {
      if (await _testUrl(url)) {
        _workingUrl = url;
        await prefs.setString(_urlCacheKey, url);
        return;
      }
    }
  }

  static Future<bool> _testUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 3)); // Increased timeout for better stability
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static void resetConnection() {
    _workingUrl = null;
    _isTestingUrls = false;
    // Clear cached URL when resetting
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_urlCacheKey);
    });
  }

  static String? get currentUrl => _workingUrl;
}

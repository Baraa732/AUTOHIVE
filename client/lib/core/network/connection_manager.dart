import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionManager {
  // URLs for different connection types
  static const List<String> _urls = [
    'http://10.0.2.2:8000/api',       // Android Emulator (Laravel default)
    'http://10.65.2.42:8000/api',     // Your current Ethernet IP for physical devices
    'http://192.168.137.1:8000/api',  // Your hotspot IP for physical devices
    'http://127.0.0.1:8000/api',      // Localhost
    'http://localhost:8000/api',      // Alternative localhost
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
      print('📌 Using cached URL: $cachedUrl');
      _workingUrl = cachedUrl;
      // Verify in background without blocking
      _testUrlInBackground(cachedUrl);
      return cachedUrl;
    }

    // No cached URL, need to find working one
    print('🔍 No cached URL, searching for working backend...');
    await _findWorkingUrl();
    
    // Return found URL or default
    return _workingUrl ?? 'http://10.0.2.2:8000/api';
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
    print('🔍 Searching for working backend URL...');
    
    for (String url in _urls) {
      if (await _testUrl(url)) {
        _workingUrl = url;
        await prefs.setString(_urlCacheKey, url);
        print('✅ Found working URL: $url');
        return;
      }
    }
    print('❌ No working URL found!');
  }

  static Future<bool> _testUrl(String url) async {
    try {
      print('🔍 Testing URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      final isWorking = response.statusCode == 200;
      print('${isWorking ? '✅' : '❌'} URL $url - Status: ${response.statusCode}');
      return isWorking;
    } catch (e) {
      print('❌ URL $url - Error: $e');
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

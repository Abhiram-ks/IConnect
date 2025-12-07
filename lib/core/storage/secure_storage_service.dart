import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service for storing sensitive data like access tokens
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey = 'expires_at';

  /// Store access token
  static Future<void> storeAccessToken(String token, {String? expiresAt}) async {
    await _storage.write(key: _accessTokenKey, value: token);
    if (expiresAt != null) {
      await _storage.write(key: _expiresAtKey, value: expiresAt);
    }
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get expiration time
  static Future<String?> getExpiresAt() async {
    return await _storage.read(key: _expiresAtKey);
  }

  /// Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Clear all stored tokens and expiration data
  static Future<void> clearAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
  }

  /// Check if user is logged in and token is valid
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Check if token has expired
    final expiresAt = await getExpiresAt();
    if (expiresAt != null && expiresAt.isNotEmpty) {
      try {
        final expirationDate = DateTime.parse(expiresAt);
        if (DateTime.now().isAfter(expirationDate)) {
          // Token expired, clear it
          await clearAllTokens();
          return false;
        }
      } catch (e) {
        // If parsing fails, assume token is still valid
        return true;
      }
    }

    return true;
  }
}



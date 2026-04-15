import 'package:iconnect/core/storage/local_storage_service.dart';

/// Secure Storage Service
///
/// Token-based Shopify auth has been removed. Login state is now tracked via
/// [LocalStorageService.isLoggedIn]. This class is kept as a thin shim so
/// call-sites that still reference [SecureStorageService.isLoggedIn] compile
/// without changes until they are migrated.
class SecureStorageService {
  /// Returns `true` when the user is logged in (delegates to [LocalStorageService]).
  static Future<bool> isLoggedIn() async {
    return LocalStorageService.isLoggedIn;
  }
}

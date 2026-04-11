import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  static bool _checkedThisSession = false;
  static VersionStatus? _cachedStatus;

  final _db = FirebaseFirestore.instance;

  Future<VersionStatus> checkVersion() async {
    // Already checked this session — return cached result
    if (_checkedThisSession && _cachedStatus != null) {
      return _cachedStatus!;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final doc =
          await _db.collection('app_config').doc('version_control').get();

      if (!doc.exists) {
        _checkedThisSession = true;
        _cachedStatus = const VersionStatus.upToDate();
        return _cachedStatus!;
      }

      final data = doc.data()!;
      final minimumVersion = data['minimum_version'] ?? '1.0.0';
      final forceUpdate = data['force_update'] ?? false;
      final message =
          data['update_message'] ??
          'A new update is required to continue using the app.';
      final storeUrl =
          Platform.isAndroid
              ? data['play_store_url'] ?? ''
              : data['app_store_url'] ?? '';

      if (forceUpdate && _isVersionLower(currentVersion, minimumVersion)) {
        _cachedStatus = VersionStatus.forceUpdate(
          message: message,
          storeUrl: storeUrl,
          currentVersion: currentVersion,
          minimumVersion: minimumVersion,
        );
      } else {
        _cachedStatus = const VersionStatus.upToDate();
      }

      _checkedThisSession = true;
      return _cachedStatus!;
    } catch (e) {
      // Fail silently — never block the user due to a check failure
      _checkedThisSession = true;
      _cachedStatus = const VersionStatus.upToDate();
      return _cachedStatus!;
    }
  }

  bool _isVersionLower(String current, String minimum) {
    try {
      final c = current.split('.').map(int.parse).toList();
      final m = minimum.split('.').map(int.parse).toList();

      // Pad to 3 parts in case version is "1.0" instead of "1.0.0"
      while (c.length < 3) c.add(0);
      while (m.length < 3) m.add(0);

      for (int i = 0; i < 3; i++) {
        if (c[i] < m[i]) return true;
        if (c[i] > m[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Call this on logout or app restart to reset the session flag
  static void reset() {
    _checkedThisSession = false;
    _cachedStatus = null;
  }
}

class VersionStatus {
  final bool needsUpdate;
  final String? message;
  final String? storeUrl;
  final String? currentVersion;
  final String? minimumVersion;

  const VersionStatus._({
    required this.needsUpdate,
    this.message,
    this.storeUrl,
    this.currentVersion,
    this.minimumVersion,
  });

  const VersionStatus.upToDate() : this._(needsUpdate: false);

  factory VersionStatus.forceUpdate({
    required String message,
    required String storeUrl,
    required String currentVersion,
    required String minimumVersion,
  }) => VersionStatus._(
    needsUpdate: true,
    message: message,
    storeUrl: storeUrl,
    currentVersion: currentVersion,
    minimumVersion: minimumVersion,
  );
}

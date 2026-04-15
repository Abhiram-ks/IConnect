import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// All SharedPreferences keys in one place.
/// Never use raw strings — always reference this class.
class StorageKeys {
  const StorageKeys._();

  // ── Firebase user ──────────────────────────────────────────────────────────
  /// Firebase Auth UID — used for Firestore queries
  static const String firebaseUid = 'firebase_uid';

  // ── Shopify / profile ──────────────────────────────────────────────────────
  static const String userEmail     = 'user_email';
  static const String userFirstName = 'user_first_name';
  static const String userLastName  = 'user_last_name';

  // ── Session ────────────────────────────────────────────────────────────────
  /// True when the user is logged in via Firebase.
  static const String isLoggedIn = 'is_logged_in';

  // ── Coupon ─────────────────────────────────────────────────────────────────
  /// The welcome coupon code assigned to this device install. Empty = no coupon.
  static const String couponCode = 'coupon_code';

  /// True once the coupon has been redeemed at checkout.
  static const String couponUsed = 'coupon_used';
}

/// Thin wrapper around [SharedPreferences].
///
/// **Usage pattern**
/// ```dart
/// // 1. Call once in main() before runApp():
/// await LocalStorageService.init();
///
/// // 2. Read anywhere — synchronous, no await:
/// final uid  = LocalStorageService.uid;
/// final code = LocalStorageService.couponCode;
///
/// // 3. React to coupon eligibility changes in widgets:
/// ValueListenableBuilder<bool>(
///   valueListenable: LocalStorageService.couponEligible,
///   builder: (_, eligible, __) => eligible ? BannerWidget() : SizedBox.shrink(),
/// );
///
/// // 4. Write (still async — SharedPreferences requires it):
/// await LocalStorageService.storeUserData(firebaseUid: uid, email: email);
///
/// // 5. Clear on logout:
/// await LocalStorageService.clearAll();
/// ```
class LocalStorageService {
  LocalStorageService._();

  static late SharedPreferences _prefs;

  /// Notifier updated whenever coupon eligibility changes.
  /// `true`  = user has an assigned, un-used coupon → show banner.
  /// `false` = no coupon, or already used → hide banner.
  ///
  /// Widgets should use [ValueListenableBuilder] on this — no Firestore reads,
  /// no open stream connections, zero network cost.
  static final ValueNotifier<bool> couponEligible = ValueNotifier(false);

  // ── Init ──────────────────────────────────────────────────────────────────

  /// Must be called once in [main] before [runApp].
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Restore notifier from persisted state so the banner is correct on
    // cold start without any network call.
    _refreshCouponNotifier();
  }

  // ── Synchronous getters — no await needed anywhere ────────────────────────

  static bool    get isLoggedIn  => _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  static String? get uid         => _prefs.getString(StorageKeys.firebaseUid);
  static String? get email       => _prefs.getString(StorageKeys.userEmail);
  static String? get firstName   => _prefs.getString(StorageKeys.userFirstName);
  static String? get lastName    => _prefs.getString(StorageKeys.userLastName);
  static String? get couponCode  => _prefs.getString(StorageKeys.couponCode);
  static bool    get couponUsed  => _prefs.getBool(StorageKeys.couponUsed) ?? false;

  /// Display name built from first + last name; falls back to email.
  static String get displayName {
    final full = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return full.isNotEmpty ? full : (email ?? '');
  }

  // ── Writers ───────────────────────────────────────────────────────────────

  /// Set the logged-in flag.
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(StorageKeys.isLoggedIn, value);
  }

  /// Persist any combination of user identity fields.
  /// Only writes keys whose value is non-null — safe for partial updates.
  static Future<void> storeUserData({
    String? firebaseUid,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    if (firebaseUid != null) await _prefs.setString(StorageKeys.firebaseUid, firebaseUid);
    if (email     != null) await _prefs.setString(StorageKeys.userEmail,     email);
    if (firstName != null) await _prefs.setString(StorageKeys.userFirstName, firstName);
    if (lastName  != null) await _prefs.setString(StorageKeys.userLastName,  lastName);
  }

  /// Persist coupon state and update [couponEligible] notifier immediately.
  ///
  /// Call this from [CouponService] whenever coupon data changes:
  /// - After assigning a coupon at signup → `storeCouponData(code: 'ABC', used: false)`
  /// - After redeeming at checkout       → `storeCouponData(used: true)`
  static Future<void> storeCouponData({
    String? code,
    bool?   used,
  }) async {
    if (code != null) await _prefs.setString(StorageKeys.couponCode, code);
    if (used != null) await _prefs.setBool(StorageKeys.couponUsed,   used);
    _refreshCouponNotifier();
  }

  /// Remove all user-related keys and reset the coupon notifier.
  /// Call this on logout — clears both identity and coupon state.
  static Future<void> clearAll() async {
    await _prefs.remove(StorageKeys.isLoggedIn);
    await _prefs.remove(StorageKeys.firebaseUid);
    await _prefs.remove(StorageKeys.userEmail);
    await _prefs.remove(StorageKeys.userFirstName);
    await _prefs.remove(StorageKeys.userLastName);
    await _prefs.remove(StorageKeys.couponCode);
    await _prefs.remove(StorageKeys.couponUsed);
    couponEligible.value = false;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static void _refreshCouponNotifier() {
    final code = couponCode;
    final used = couponUsed;
    couponEligible.value = code != null && code.trim().isNotEmpty && !used;
  }
}

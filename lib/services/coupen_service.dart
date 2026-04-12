import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconnect/core/storage/local_storage_service.dart';

class CouponService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Assigns a welcome coupon if the user is under the global cap.
  ///
  /// **Requires** a document at `app_config/coupon_settings` (create it in the
  /// Firebase console if missing). Without it, this returns `null` and does nothing.
  /// Suggested fields: `install_count` (number, start at 0), `max_installs` (number),
  /// `is_active` (bool), `coupon_code` (string).
  Future<String?> getOrAssignCoupon() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userRef = _db.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    final existing = userDoc.data()?['coupon_code'];
    if (userDoc.exists && existing != null && '$existing'.isNotEmpty) {
      return existing is String ? existing : existing.toString();
    }

    final configRef = _db.collection('app_config').doc('coupon_settings');

    return _db.runTransaction<String?>((txn) async {
      final userSnap = await txn.get(userRef);
      final inTxn = userSnap.data()?['coupon_code'];
      if (userSnap.exists && inTxn != null && '$inTxn'.isNotEmpty) {
        return inTxn is String ? inTxn : inTxn.toString();
      }

      final configSnap = await txn.get(configRef);
      if (!configSnap.exists || configSnap.data() == null) return null;
      final data = configSnap.data()!;

      final int count = (data['install_count'] as num?)?.toInt() ?? 0;
      final int max = (data['max_installs'] as num?)?.toInt() ?? 100;
      final bool active = data['is_active'] as bool? ?? true;
      final String code = (data['coupon_code'] as String?)?.trim() ?? '';

      if (!active || count >= max || code.isEmpty) return null;

      txn.update(configRef, {'install_count': FieldValue.increment(1)});
      txn.set(
        userRef,
        {
          'coupon_code': code,
          'coupon_assigned_at': FieldValue.serverTimestamp(),
          'install_counted': true,
          'coupon_used': false,
          'coupon_used_at': null,
        },
        SetOptions(merge: true),
      );

      return code;
    }).then((code) async {
      // Cache immediately so the banner shows without a second Firestore read.
      if (code != null) {
        await LocalStorageService.storeCouponData(code: code, used: false);
      }
      return code;
    });
  }

  /// Returns the user's assigned coupon code **only if**:
  ///   - the user is logged in to Firebase,
  ///   - they were assigned a coupon during signup (app-only path), and
  ///   - they have not yet used it.
  ///
  /// Returns `null` in every other case so callers never need to null-guard.
  Future<String?> getUserCoupon() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snap = await _db.collection('users').doc(user.uid).get();
      final data = snap.data();
      if (data == null) return null;

      final bool alreadyUsed = data['coupon_used'] as bool? ?? false;
      if (alreadyUsed) return null;

      final String? code = (data['coupon_code'] as String?)?.trim();
      final result = (code != null && code.isNotEmpty) ? code : null;

      // Populate local cache so widgets never need a Firestore read.
      await LocalStorageService.storeCouponData(
        code: code ?? '',
        used: alreadyUsed,
      );

      return result;
    } catch (e) {
      log('CouponService.getUserCoupon error: $e');
      return null;
    }
  }

  /// Marks the user's coupon as used after a successful purchase.
  /// Safe to call even if the user never had a coupon — exits early in that case.
  Future<void> markCouponUsed() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final snap = await userRef.get();
      final data = snap.data();

      // Nothing to update if there is no coupon or it is already marked used.
      if (data == null || data['coupon_code'] == null) return;
      if (data['coupon_used'] as bool? ?? false) return;

      await userRef.update({
        'coupon_used': true,
        'coupon_used_at': FieldValue.serverTimestamp(),
      });

      // Update local cache instantly — notifier fires, banner disappears
      // without waiting for a Firestore round-trip.
      await LocalStorageService.storeCouponData(used: true);
      log('CouponService: coupon marked as used for uid=${user.uid}');
    } catch (e) {
      log('CouponService.markCouponUsed error: $e');
    }
  }
}

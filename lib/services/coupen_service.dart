import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    });
  }
}

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconnect/core/storage/local_storage_service.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_state.dart';
import 'package:iconnect/services/coupen_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Auth Cubit - Manages authentication state and operations
///
/// Auth is Firebase-only. No Shopify customer token is stored or used.
/// Login state is persisted as a boolean in [LocalStorageService.isLoggedIn].
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _checkAuthStatus();
  }

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> _checkAuthStatus() async {
    if (LocalStorageService.isLoggedIn) {
      emit(const AuthLoginSuccess());
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────────

  /// Sign in with email and password using Firebase only.
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        // Fetch firstName/lastName from Firestore (stored during signup).
        String? firstName;
        String? lastName;
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (doc.exists) {
            final data = doc.data()!;
            firstName = data['firstName'] as String?;
            lastName = data['lastName'] as String?;
          }
        } catch (e) {
          log('login: Firestore profile fetch failed (non-critical): $e');
        }

        await LocalStorageService.storeUserData(
          firebaseUid: uid,
          email: email,
          firstName: firstName?.isNotEmpty == true ? firstName : null,
          lastName: lastName?.isNotEmpty == true ? lastName : null,
        );
      }
      await LocalStorageService.setLoggedIn(true);

      // Fire-and-forget: tag Shopify customer as mobile app user.
      _tagMobileAppUser();

      // Populate coupon cache.
      await CouponService().getUserCoupon();

      emit(const AuthLoginSuccess());
    } on FirebaseAuthException catch (e) {
      log('login: Firebase error (${e.code})');
      emit(AuthError(_getFirebaseLoginError(e)));
    } catch (e) {
      emit(AuthError(_getUserFriendlyError(e.toString())));
    }
  }

  String _getFirebaseLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email. Please sign up.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-disabled':
        return 'Your account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Invalid email or password. Please try again.';
    }
  }

  String _getUserFriendlyError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('network') || lower.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (lower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (lower.contains('too many')) {
      return 'Too many attempts. Please try again later.';
    }
    return error;
  }

  // ── Signup ──────────────────────────────────────────────────────────────────

  /// Create a Firebase account and send a verification email.
  /// The user is NOT logged in until they verify their email.
  Future<void> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    emit(AuthLoading());
    try {
      final firebaseAuth = FirebaseAuth.instance;

      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://iconnect-qatar-shop.firebaseapp.com/__/auth/action',
        handleCodeInApp: false,
        androidPackageName: 'com.iconnect.application',
        androidInstallApp: false,
        androidMinimumVersion: '21',
      );

      await userCredential.user?.sendEmailVerification(actionCodeSettings);

      // Sign out immediately — the user must verify first.
      await firebaseAuth.signOut();

      emit(
        AuthEmailVerificationPending(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(
          const AuthError(
            'This email is already registered. Please login instead.',
          ),
        );
      } else {
        emit(AuthError(_getFirebaseErrorMessage(e)));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Email Verification ──────────────────────────────────────────────────────

  /// Check that the email is verified, then complete account creation.
  Future<void> verifyEmailAndSignup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    emit(AuthOtpVerificationLoading());
    try {
      final firebaseAuth = FirebaseAuth.instance;

      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.reload();
      final user = firebaseAuth.currentUser;

      if (user != null && user.emailVerified) {
        await LocalStorageService.storeUserData(
          firebaseUid: user.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );

        await _createFirestoreUser(
          email: email,
          firstName: firstName,
          lastName: lastName,
        );

        await LocalStorageService.setLoggedIn(true);

        // Fire-and-forget tagging.
        _tagMobileAppUser();

        emit(const AuthSignupSuccess());
      } else {
        await firebaseAuth.signOut();
        emit(
          const AuthError(
            'Email not verified yet. Please check your email and click the verification link.',
          ),
        );
      }
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      emit(AuthError(_getFirebaseErrorMessage(e)));
    }
  }

  // ── Resend verification ─────────────────────────────────────────────────────

  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      final firebaseAuth = FirebaseAuth.instance;

      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user?.emailVerified == false) {
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://iconnect-qatar-shop.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
          androidPackageName: 'com.iconnect.application',
          androidInstallApp: false,
          androidMinimumVersion: '21',
        );

        await userCredential.user?.sendEmailVerification(actionCodeSettings);
        await firebaseAuth.signOut();
        emit(
          const AuthError(
            'Verification email resent successfully. Please check your inbox.',
          ),
        );
      } else {
        emit(const AuthError('Email is already verified.'));
      }
    } catch (e) {
      emit(AuthError(_getFirebaseErrorMessage(e)));
    }
  }

  // ── Forgot Password ─────────────────────────────────────────────────────────

  /// Send a Firebase password-reset email.
  Future<void> forgotPassword({required String email}) async {
    emit(AuthForgotPasswordLoading());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(AuthForgotPasswordEmailSent(email));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getForgotPasswordError(e)));
    } catch (e) {
      emit(AuthError('Failed to send reset email. Please try again.'));
    }
  }

  String _getForgotPasswordError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Failed to send reset email. Please try again.';
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.signOut();
      await LocalStorageService.clearAll();
      await WebViewCookieManager().clearCookies();
    } catch (_) {
      await LocalStorageService.clearAll();
      await WebViewCookieManager().clearCookies();
    } finally {
      emit(AuthInitial());
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Create (or merge-update) the Firestore user document.
  Future<void> _createFirestoreUser({
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Firebase user not found after verification');

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Assign coupon if eligible (first 100 installs).
    await CouponService().getOrAssignCoupon();
  }

  /// Calls the `tagMobileAppUser` Cloud Function. Always fire-and-forget.
  void _tagMobileAppUser() {
    FirebaseFunctions.instanceFor(region: 'asia-south1')
        .httpsCallable('tagMobileAppUser')
        .call()
        .then((_) => log('mobile_app_user Shopify tag applied'))
        .catchError(
          (e) => log('mobile_app_user Shopify tagging failed (non-critical): $e'),
        );
  }

  String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'invalid-action-code':
          return 'Invalid or expired verification code.';
        case 'expired-action-code':
          return 'Verification code has expired. Please request a new one.';
        default:
          return error.message ?? 'An error occurred. Please try again.';
      }
    }
    return error.toString();
  }
}

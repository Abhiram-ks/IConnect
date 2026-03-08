import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconnect/core/storage/secure_storage_service.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:iconnect/features/auth/domain/usecases/login_usecase.dart';
import 'package:iconnect/features/auth/domain/usecases/signup_usecase.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_state.dart';
import 'package:iconnect/features/profile/domain/usecases/get_profile_usecase.dart';

/// Auth Cubit - Manages authentication state and operations
class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase loginUsecase;
  final SignupUsecase signupUsecase;
  final GetProfileUsecase getProfileUsecase;

  AuthCubit({
    required this.loginUsecase,
    required this.signupUsecase,
    required this.getProfileUsecase,
  }) : super(AuthInitial()) {
    _checkAuthStatus();
  }

  /// Check authentication status on initialization
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await SecureStorageService.isLoggedIn();
    if (isLoggedIn) {
      final token = await SecureStorageService.getAccessToken();
      final expiresAt = await SecureStorageService.getExpiresAt();
      if (token != null) {
        emit(
          AuthLoginSuccess(
            AuthEntity(accessToken: token, expiresAt: expiresAt),
          ),
        );
      }
    }
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final result = await loginUsecase(
        LoginParams(email: email, password: password),
      );

      result.fold(
        (failure) {
          emit(AuthError(_getUserFriendlyLoginError(failure.message)));
        },
        (authEntity) async {
          // Store access token in secure storage
          await SecureStorageService.storeAccessToken(
            authEntity.accessToken,
            expiresAt: authEntity.expiresAt,
          );
          emit(AuthLoginSuccess(authEntity));
        },
      );
    } catch (e) {
      emit(AuthError(_getUserFriendlyLoginError(e.toString())));
    }
  }

  /// Convert API error messages to user-friendly messages
  String _getUserFriendlyLoginError(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();
    
    if (lowerError.contains('unidentified customer') || 
        lowerError.contains('customer not found') ||
        lowerError.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (lowerError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (lowerError.contains('too many')) {
      return 'Too many login attempts. Please try again later.';
    } else if (lowerError.contains('account disabled') || lowerError.contains('account locked')) {
      return 'Your account has been disabled. Please contact support.';
    }
    
    return errorMessage;
  }

  /// Signup - sends verification email without creating Firebase user yet
  Future<void> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    emit(AuthLoading());
    try {
      final firebaseAuth = FirebaseAuth.instance;
      
      // Create temporary Firebase user to send verification email
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Configure action code settings with your Firebase domain
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://iconnect-qatar-shop.firebaseapp.com/__/auth/action',
        handleCodeInApp: false,
        androidPackageName: 'com.iconnect.application',
        androidInstallApp: false,
        androidMinimumVersion: '21',
      );

      // Send verification email with proper settings
      await userCredential.user?.sendEmailVerification(actionCodeSettings);

      // Immediately sign out - user will sign in after verification
      await firebaseAuth.signOut();

      // Emit state to navigate to OTP screen
      emit(AuthEmailVerificationPending(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(const AuthError('This email is already registered. Please login instead.'));
      } else {
        emit(AuthError(_getFirebaseErrorMessage(e)));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Verify email and complete signup
  Future<void> verifyEmailAndSignup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    emit(AuthOtpVerificationLoading());
    try {
      final firebaseAuth = FirebaseAuth.instance;
      
      // Sign in to check verification status
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user to get latest verification status
      await userCredential.user?.reload();
      final user = firebaseAuth.currentUser;

      if (user != null && user.emailVerified) {
        // Email is verified, NOW create account in backend
        await _completeSignup(email, password, firstName, lastName);
        
        // Keep Firebase user signed in for now, will be managed by backend token
      } else {
        // Email not verified yet, sign out
        await firebaseAuth.signOut();
        emit(const AuthError('Email not verified yet. Please check your email and click the verification link.'));
      }
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      emit(AuthError(_getFirebaseErrorMessage(e)));
    }
  }

  /// Complete signup after email verification - creates backend account
  Future<void> _completeSignup(
    String email,
    String password,
    String? firstName,
    String? lastName,
  ) async {
    try {
      // Create account in your backend system
      final result = await signupUsecase(
        SignupParams(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );

      result.fold(
        (failure) async {
          // Backend signup failed, optionally delete Firebase user
          // Uncomment below if you want to delete Firebase user on backend failure
          // try {
          //   final user = FirebaseAuth.instance.currentUser;
          //   await user?.delete();
          // } catch (e) {
          //   // Ignore deletion errors
          // }
          emit(AuthError(failure.message));
        },
        (authEntity) async {
          if (authEntity.accessToken.isEmpty) {
            // Backend signup successful but no token, login to get token
            await login(email: email, password: password);
          } else {
            // Store backend access token
            await SecureStorageService.storeAccessToken(
              authEntity.accessToken,
              expiresAt: authEntity.expiresAt,
            );
            emit(AuthSignupSuccess(authEntity));
          }
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      final firebaseAuth = FirebaseAuth.instance;
      
      // Sign in to resend verification
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user?.emailVerified == false) {
        // Configure action code settings with your Firebase domain
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://iconnect-qatar-shop.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
          androidPackageName: 'com.iconnect.application',
          androidInstallApp: false,
          androidMinimumVersion: '21',
        );
        
        await userCredential.user?.sendEmailVerification(actionCodeSettings);
        await firebaseAuth.signOut();
        emit(const AuthError('Verification email resent successfully. Please check your inbox.'));
      } else {
        emit(const AuthError('Email is already verified.'));
      }
    } catch (e) {
      emit(AuthError(_getFirebaseErrorMessage(e)));
    }
  }

  /// Get user-friendly error messages
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



  /// Logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear all secure storage data
      await SecureStorageService.clearAllTokens();
      emit(AuthInitial());
    } catch (e) {
      // Even if there's an error, clear the state
      emit(AuthInitial());
    }
  }

  /// Load user profile
  Future<void> loadProfile() async {
    final currentState = state;
    AuthEntity? authEntity;

    // Get auth entity from current state
    if (currentState is AuthLoginSuccess) {
      authEntity = currentState.authEntity;
    } else if (currentState is AuthSignupSuccess) {
      authEntity = currentState.authEntity;
    } else if (currentState is AuthProfileLoading) {
      authEntity = currentState.authEntity;
    }

    if (authEntity == null) {
      emit(AuthError('User not authenticated'));
      return;
    }

    emit(AuthProfileLoading(authEntity));

    try {
      final result = await getProfileUsecase(NoParams());

      result.fold(
        (failure) {
          // On error, revert to previous success state without profile
          if (currentState is AuthLoginSuccess) {
            emit(AuthLoginSuccess(authEntity!));
          } else if (currentState is AuthSignupSuccess) {
            emit(AuthSignupSuccess(authEntity!));
          }
          emit(AuthError(failure.message));
        },
        (profile) {
          // Update state with profile data
          if (currentState is AuthLoginSuccess ||
              currentState is AuthProfileLoading) {
            emit(AuthLoginSuccess(authEntity!, profile: profile));
          } else if (currentState is AuthSignupSuccess) {
            emit(AuthSignupSuccess(authEntity!, profile: profile));
          }
        },
      );
    } catch (e) {
      // On error, revert to previous success state without profile
      if (currentState is AuthLoginSuccess) {
        emit(AuthLoginSuccess(authEntity));
      } else if (currentState is AuthSignupSuccess) {
        emit(AuthSignupSuccess(authEntity));
      }
      emit(AuthError(e.toString()));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:iconnect/core/storage/secure_storage_service.dart';
import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:iconnect/features/auth/domain/usecases/login_usecase.dart';
import 'package:iconnect/features/auth/domain/usecases/signup_usecase.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_state.dart';

/// Auth Cubit - Manages authentication state and operations
class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase loginUsecase;
  final SignupUsecase signupUsecase;

  AuthCubit({
    required this.loginUsecase,
    required this.signupUsecase,
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
        emit(AuthLoginSuccess(
          AuthEntity(
            accessToken: token,
            expiresAt: expiresAt,
          ),
        ));
      }
    }
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final result = await loginUsecase(
        LoginParams(email: email, password: password),
      );

      result.fold(
        (failure) {
          emit(AuthError(failure.message));
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
      emit(AuthError(e.toString()));
    }
  }

  /// Signup with email and password
  Future<void> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    emit(AuthLoading());
    try {
      final result = await signupUsecase(
        SignupParams(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );

      result.fold(
        (failure) {
          emit(AuthError(failure.message));
        },
        (authEntity) async {
          // After signup, automatically login to get access token
          // Note: Shopify signup doesn't return token, so we need to login
          if (authEntity.accessToken.isEmpty) {
            // Auto-login after successful signup
            await login(email: email, password: password);
          } else {
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

  /// Logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      // Clear all secure storage data
      await SecureStorageService.clearAllTokens();
      emit(AuthInitial());
    } catch (e) {
      // Even if there's an error, clear the state
      emit(AuthInitial());
    }
  }
}


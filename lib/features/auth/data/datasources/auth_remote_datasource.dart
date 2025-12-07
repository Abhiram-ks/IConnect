import 'package:iconnect/features/auth/data/models/auth_model.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Abstract Auth Remote Data Source
abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String email,
    required String password,
  });

  Future<AuthModel> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });
}

/// Auth Remote Data Source Implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  AuthRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await graphQLService.customerLogin(
        email: email,
        password: password,
      );
      return AuthModel.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthModel> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final result = await graphQLService.customerSignup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      return AuthModel.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }
}



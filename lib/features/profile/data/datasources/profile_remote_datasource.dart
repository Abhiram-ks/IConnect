import 'package:iconnect/core/storage/secure_storage_service.dart';
import 'package:iconnect/features/profile/data/models/profile_model.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Abstract Profile Remote Data Source
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
}

/// Profile Remote Data Source Implementation
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  ProfileRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final accessToken = await SecureStorageService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please login again.');
      }

      final result = await graphQLService.getCustomer(
        customerAccessToken: accessToken,
      );
      return ProfileModel.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }
}


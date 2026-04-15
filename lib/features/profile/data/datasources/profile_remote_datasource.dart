import 'package:iconnect/features/profile/data/models/profile_model.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Abstract Profile Remote Data Source
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
}

/// Profile Remote Data Source Implementation
///
/// Profile retrieval via Shopify Storefront API is no longer supported since
/// the app uses Firebase-only auth (no Shopify customer access token).
/// Callers should read profile data from [LocalStorageService] or Firestore.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  ProfileRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<ProfileModel> getProfile() async {
    throw Exception(
      'Shopify profile retrieval is disabled. '
      'Read user data from LocalStorageService or Firestore instead.',
    );
  }
}

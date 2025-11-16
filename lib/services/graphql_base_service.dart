import 'package:dio/dio.dart' as dio;
import 'package:graphql_flutter/graphql_flutter.dart'
    hide NetworkException, ServerException;
import 'package:iconnect/services/api_exception.dart';
import 'package:iconnect/services/key_store.dart';

/// Base GraphQL Service for Shopify Storefront API
/// Provides core functionality for all GraphQL operations with proper error handling
abstract class GraphQLBaseService {
  late final GraphQLClient _client;
  late final dio.Dio _dio;

  GraphQLBaseService() {
    _initializeDio();
    _initializeClient();
  }

  /// Initialize Dio instance with proper configuration
  void _initializeDio() {
    _dio = dio.Dio(
      dio.BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        validateStatus: (status) => true, // Accept all status codes
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onError: (error, handler) {
          // Log errors for debugging
          return handler.next(error);
        },
      ),
    );
  }

  /// Initialize GraphQL client with Shopify Storefront API configuration
  void _initializeClient() {
    // Create HttpLink for GraphQL requests
    final httpLink = HttpLink(
      SecureKeyStore.graphQLEndpoint,
      defaultHeaders: SecureKeyStore.storefrontHeaders,
    );

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.noCache,
          error: ErrorPolicy.all,
        ),
        mutate: Policies(
          fetch: FetchPolicy.noCache,
          error: ErrorPolicy.all,
        ),
      ),
      queryRequestTimeout: const Duration(seconds: 20),
    );
  }

  /// Get GraphQL client instance
  GraphQLClient get client => _client;

  /// Execute GraphQL query with comprehensive error handling
  ///
  /// Returns the data portion of the response
  /// Throws appropriate exceptions for errors
  Future<Map<String, dynamic>> executeQuery(
    String query, {
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(query),
        variables: variables ?? {},
        fetchPolicy: fetchPolicy ?? FetchPolicy.noCache,
      );

      final result = await _client.query(options);

      // Handle errors in result
      if (result.hasException) {
        _handleException(result.exception!);
      }

      // Check for data
      if (result.data == null) {
        throw ApiException(message: 'No data returned from query');
      }

      // Check for userErrors in response (Shopify specific)
      _checkUserErrors(result.data!);

      return result.data!;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Query execution failed: ${e.toString()}');
    }
  }

  /// Execute GraphQL mutation with comprehensive error handling
  ///
  /// Returns the data portion of the response
  /// Throws appropriate exceptions for errors
  Future<Map<String, dynamic>> executeMutation(
    String mutation, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? {},
      );

      final result = await _client.mutate(options);

      // Handle errors in result
      if (result.hasException) {
        _handleException(result.exception!);
      }

      // Check for data
      if (result.data == null) {
        throw ApiException(message: 'No data returned from mutation');
      }

      // Check for userErrors in mutation response (Shopify specific)
      _checkUserErrors(result.data!);

      return result.data!;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Mutation execution failed: ${e.toString()}');
    }
  }

  /// Handle GraphQL exceptions
  void _handleException(OperationException exception) {
    // Handle link exception (network errors)
    if (exception.linkException != null) {
      final linkException = exception.linkException;

      // Check if it's a network error
      if (linkException is NetworkException ||
          linkException.toString().contains('network') ||
          linkException.toString().contains('connection')) {
        throw NetworkException(
          message: 'No internet connection. Please check your network.',
        );
      }

      throw ApiException(
        message: 'Network error: ${linkException.toString()}',
      );
    }

    // Handle GraphQL errors
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final message = error.message;
      final extensions = error.extensions;
      final statusCode = extensions?['statusCode'] as int?;
      final errorCode = extensions?['code'] as String?;

      // Handle specific status codes
      if (statusCode == 401) {
        throw UnauthorizedException(message: message);
      }

      if (statusCode == 402) {
        throw ShopFrozenException(message: message);
      }

      if (statusCode == 403) {
        throw ShopForbiddenException(message: message);
      }

      if (statusCode == 404) {
        throw NotFoundException(message: message);
      }

      if (statusCode == 423) {
        throw ShopLockedException(message: message);
      }

      if (statusCode == 430) {
        throw SecurityRejectionException(message: message);
      }

      if (statusCode != null && statusCode >= 500) {
        throw ServerException(
          message: message,
          statusCode: statusCode,
        );
      }

      // Handle GraphQL-specific errors with error codes
      if (errorCode != null) {
        throw GraphQLException.fromResponse({
          'errors': [
            {
              'message': message,
              'extensions': extensions,
            }
          ]
        }, statusCode: statusCode);
      }

      throw ApiException(
        message: message,
        statusCode: statusCode,
      );
    }

    // Generic exception
    throw ApiException(message: exception.toString());
  }

  /// Check for userErrors in Shopify mutation responses
  /// Shopify mutations return userErrors instead of throwing exceptions
  void _checkUserErrors(Map<String, dynamic> data) {
    // Find first mutation result with userErrors
    for (final entry in data.entries) {
      if (entry.value is Map<String, dynamic>) {
        final mutationData = entry.value as Map<String, dynamic>;

        // Check for customerUserErrors
        if (mutationData.containsKey('customerUserErrors')) {
          final errors = mutationData['customerUserErrors'] as List?;
          if (errors != null && errors.isNotEmpty) {
            final errorMessages =
                errors.map((e) => e['message'] as String).join(', ');
            throw ApiException(message: errorMessages);
          }
        }

        // Check for checkoutUserErrors
        if (mutationData.containsKey('checkoutUserErrors')) {
          final errors = mutationData['checkoutUserErrors'] as List?;
          if (errors != null && errors.isNotEmpty) {
            final errorMessages =
                errors.map((e) => e['message'] as String).join(', ');
            throw ApiException(message: errorMessages);
          }
        }

        // Check for userErrors (generic)
        if (mutationData.containsKey('userErrors')) {
          final errors = mutationData['userErrors'] as List?;
          if (errors != null && errors.isNotEmpty) {
            final errorMessages =
                errors.map((e) => e['message'] as String).join(', ');
            throw ApiException(message: errorMessages);
          }
        }
      }
    }
  }

  /// Dispose client resources
  void dispose() {
    _dio.close();
  }
}

/// Concrete implementation of GraphQL Service for Shopify Storefront API
class ShopifyGraphQLService extends GraphQLBaseService {
  /// Singleton instance
  static final ShopifyGraphQLService _instance =
      ShopifyGraphQLService._internal();

  factory ShopifyGraphQLService() => _instance;

  ShopifyGraphQLService._internal();

  /// Fetch products with pagination
  Future<Map<String, dynamic>> getProducts({
    int first = 20,
    String? after,
    String? query,
  }) async {
    const queryString = r'''
      query GetProducts($first: Int!, $after: String, $query: String) {
        products(first: $first, after: $after, query: $query) {
          edges {
            node {
              id
              title
              description
              handle
              featuredImage {
                url
              }
              images(first: 5) {
                edges {
                  node {
                    url
                  }
                }
              }
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
              compareAtPriceRange {
                minVariantPrice {
                  amount
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    ''';

    return executeQuery(
      queryString,
      variables: {
        'first': first,
        if (after != null) 'after': after,
        if (query != null) 'query': query,
      },
    );
  }

  /// Fetch product by handle
  Future<Map<String, dynamic>> getProductByHandle(String handle) async {
    const queryString = r'''
      query GetProductByHandle($handle: String!) {
        product(handle: $handle) {
          id
          title
          description
          descriptionHtml
          handle
          featuredImage {
            url
          }
          images(first: 10) {
            edges {
              node {
                url
              }
            }
          }
          variants(first: 10) {
            edges {
              node {
                id
                title
                price {
                  amount
                  currencyCode
                }
                compareAtPrice {
                  amount
                }
                availableForSale
                image {
                  url
                }
              }
            }
          }
        }
      }
    ''';

    return executeQuery(queryString, variables: {'handle': handle});
  }

  /// Fetch collections
  Future<Map<String, dynamic>> getCollections({int first = 10}) async {
    const queryString = r'''
      query GetCollections($first: Int!) {
        collections(first: $first) {
          edges {
            node {
              id
              title
              handle
              description
              image {
                url
              }
            }
          }
        }
      }
    ''';

    return executeQuery(queryString, variables: {'first': first});
  }

  /// Create checkout
  Future<Map<String, dynamic>> createCheckout({
    required List<Map<String, dynamic>> lineItems,
  }) async {
    const mutationString = r'''
      mutation CheckoutCreate($input: CheckoutCreateInput!) {
        checkoutCreate(input: $input) {
          checkout {
            id
            webUrl
            lineItems(first: 10) {
              edges {
                node {
                  title
                  quantity
                }
              }
            }
          }
          checkoutUserErrors {
            message
            field
          }
        }
      }
    ''';

    return executeMutation(
      mutationString,
      variables: {
        'input': {
          'lineItems': lineItems,
        }
      },
    );
  }

  /// Customer login
  Future<Map<String, dynamic>> customerLogin({
    required String email,
    required String password,
  }) async {
    const mutationString = r'''
      mutation CustomerLogin($input: CustomerAccessTokenCreateInput!) {
        customerAccessTokenCreate(input: $input) {
          customerAccessToken {
            accessToken
            expiresAt
          }
          customerUserErrors {
            message
            field
          }
        }
      }
    ''';

    return executeMutation(
      mutationString,
      variables: {
        'input': {
          'email': email,
          'password': password,
        }
      },
    );
  }

  /// Customer signup
  Future<Map<String, dynamic>> customerSignup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    const mutationString = r'''
      mutation CustomerCreate($input: CustomerCreateInput!) {
        customerCreate(input: $input) {
          customer {
            id
            email
            firstName
            lastName
          }
          customerUserErrors {
            message
            field
          }
        }
      }
    ''';

    return executeMutation(
      mutationString,
      variables: {
        'input': {
          'email': email,
          'password': password,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
        }
      },
    );
  }
}

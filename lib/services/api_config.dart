// API Configuration Constants
// This file contains non-sensitive configuration values

class ApiConfig {
  // Shopify Configuration
  static const String shopifyApiVersion = '2024-10';
  
  // API Endpoints
  static String graphQLEndpoint(String storeUrl, String version) => 
      '$storeUrl/api/$version/graphql.json';
  
  // HTTP Headers Template
  static Map<String, String> buildStorefrontHeaders(String accessToken) => {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': accessToken,
      };
  
  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String authError = 'Authentication failed';
  static const String serverError = 'Server error occurred';
}


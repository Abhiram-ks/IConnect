class SecureKeyStore {
  static const String storeUrl = 'https://iconnect-qatar.myshopify.com';
  static const String apiVersion = '2024-10';
  
  // Shopify API Keys (Storefront API - Safe for frontend)
  static const String storefrontAccessToken = '17c369561a65a34837693d70665df6d9';
  
  // Admin API Credentials (NEVER expose these in production frontend)
  // These should only be used in backend/server-side code
  static const String _apiKey = '66810dfc4bdfff4a0620efd32a150ae2';
  static const String _apiSecretKey = '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';
  
  // Getters for API configuration
  static String get graphQLEndpoint => '$storeUrl/api/$apiVersion/graphql.json';
  
  static Map<String, String> get storefrontHeaders => {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': storefrontAccessToken,
      };
  
  // Note: Admin API should never be called from frontend
  // This is here for reference only - use only in backend
  static String get adminAPIKey => _apiKey;
  static String get adminAPISecret => _apiSecretKey;
}


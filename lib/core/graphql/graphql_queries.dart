/// GraphQL Query constants for Shopify Storefront API
class GraphQLQueries {
  // ========== PRODUCT QUERIES ==========

  /// Get all products with pagination
  static const String getProducts = r'''
    query GetProducts($first: Int!, $after: String, $query: String) {
      products(first: $first, after: $after, query: $query) {
        edges {
          node {
            id
            title
            description
            handle
            vendor
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
              maxVariantPrice {
                amount
                currencyCode
              }
            }
            compareAtPriceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            availableForSale
          }
          cursor
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  ''';

  /// Get product by handle
  static const String getProductByHandle = r'''
    query GetProductByHandle($handle: String!) {
      product(handle: $handle) {
        id
        title
        description
        descriptionHtml
        handle
        vendor
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
                currencyCode
              }
              availableForSale
              image {
                url
              }
            }
          }
        }
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
          maxVariantPrice {
            amount
            currencyCode
          }
        }
        availableForSale
      }
    }
  ''';

  /// Get product by ID
  static const String getProductById = r'''
    query GetProductById($id: ID!) {
      product(id: $id) {
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
                currencyCode
              }
              availableForSale
              image {
                url
              }
            }
          }
        }
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
          maxVariantPrice {
            amount
            currencyCode
          }
        }
        availableForSale
      }
    }
  ''';

  // ========== COLLECTION QUERIES ==========

  /// Get all collections
  static const String getCollections = r'''
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
              altText
            }
          }
        }
      }
    }
  ''';

  /// Get featured collections for banners (collections with images)
  static const String getFeaturedCollections = r'''
    query GetFeaturedCollections($first: Int!) {
      collections(first: $first, query: "image:*") {
        edges {
          node {
            id
            title
            handle
            description
            image {
              url
              altText
            }
            products(first: 1) {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
      }
    }
  ''';

  /// Get collection by handle with products
  static const String getCollectionByHandle = r'''
    query GetCollectionByHandle($handle: String!, $first: Int!) {
      collection(handle: $handle) {
        id
        title
        description
        handle
        image {
          url
        }
        products(first: $first) {
          edges {
            node {
              id
              title
              description
              handle
              featuredImage {
                url
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
                  currencyCode
                }
              }
              availableForSale
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  ''';

  // ========== CUSTOMER MUTATIONS ==========

  /// Customer signup
  static const String customerCreate = r'''
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

  /// Customer login
  static const String customerLogin = r'''
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

  /// Customer logout
  static const String customerLogout = r'''
    mutation CustomerLogout($customerAccessToken: String!) {
      customerAccessTokenDelete(customerAccessToken: $customerAccessToken) {
        deletedAccessToken
        deletedCustomerAccessTokenId
        userErrors {
          message
          field
        }
      }
    }
  ''';

  /// Get customer orders
  static const String getCustomerOrders = r'''
    query GetCustomerOrders($customerAccessToken: String!, $first: Int!) {
      customer(customerAccessToken: $customerAccessToken) {
        id
        email
        firstName
        lastName
        orders(first: $first) {
          edges {
            node {
              id
              name
              orderNumber
              processedAt
              totalPrice {
                amount
                currencyCode
              }
              lineItems(first: 10) {
                edges {
                  node {
                    title
                    quantity
                    variant {
                      price {
                        amount
                        currencyCode
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  // ========== CART MUTATIONS (Modern Shopify Cart API) ==========

  /// Create cart
  static const String cartCreate = r'''
    mutation CartCreate($input: CartInput!) {
      cartCreate(input: $input) {
        cart {
          id
          checkoutUrl
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      title
                    }
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                    image {
                      url
                    }
                  }
                }
              }
            }
          }
          cost {
            subtotalAmount {
              amount
              currencyCode
            }
            totalAmount {
              amount
              currencyCode
            }
          }
        }
        userErrors {
          field
          message
        }
      }
    }
  ''';

  /// Get cart by ID
  static const String getCart = r'''
    query GetCart($id: ID!) {
      cart(id: $id) {
        id
        checkoutUrl
        lines(first: 50) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
                  id
                  title
                  product {
                    title
                  }
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                  image {
                    url
                  }
                }
              }
            }
          }
        }
        cost {
          subtotalAmount {
            amount
            currencyCode
          }
          totalAmount {
            amount
            currencyCode
          }
        }
      }
    }
  ''';

  /// Add lines to cart
  static const String cartLinesAdd = r'''
    mutation CartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
      cartLinesAdd(cartId: $cartId, lines: $lines) {
        cart {
          id
          checkoutUrl
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      title
                    }
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                    image {
                      url
                    }
                  }
                }
              }
            }
          }
          cost {
            subtotalAmount {
              amount
              currencyCode
            }
            totalAmount {
              amount
              currencyCode
            }
          }
        }
        userErrors {
          field
          message
        }
      }
    }
  ''';

  /// Update cart lines
  static const String cartLinesUpdate = r'''
    mutation CartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart {
          id
          checkoutUrl
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      title
                    }
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                    image {
                      url
                    }
                  }
                }
              }
            }
          }
          cost {
            subtotalAmount {
              amount
              currencyCode
            }
            totalAmount {
              amount
              currencyCode
            }
          }
        }
        userErrors {
          field
          message
        }
      }
    }
  ''';

  /// Remove lines from cart
  static const String cartLinesRemove = r'''
    mutation CartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart {
          id
          checkoutUrl
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      title
                    }
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                    image {
                      url
                    }
                  }
                }
              }
            }
          }
          cost {
            subtotalAmount {
              amount
              currencyCode
            }
            totalAmount {
              amount
              currencyCode
            }
          }
        }
        userErrors {
          field
          message
        }
      }
    }
  ''';

  // ========== BRAND/VENDOR QUERIES ==========

  /// Get all unique vendors (brands) from products
  /// This query fetches products and extracts unique vendors with their product count
  static const String getBrands = r'''
    query GetBrands($first: Int!) {
      products(first: $first) {
        edges {
          node {
            vendor
          }
        }
      }
    }
  ''';

  /// Get products by vendor (brand)
  static const String getProductsByVendor = r'''
    query GetProductsByVendor($first: Int!, $after: String, $vendor: String!) {
      products(first: $first, after: $after, query: $vendor) {
        edges {
          node {
            id
            title
            description
            handle
            vendor
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
              maxVariantPrice {
                amount
                currencyCode
              }
            }
            compareAtPriceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            availableForSale
          }
          cursor
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  ''';
}

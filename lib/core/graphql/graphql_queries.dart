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

  // ========== CHECKOUT MUTATIONS ==========

  /// Create checkout
  static const String checkoutCreate = r'''
    mutation CheckoutCreate($input: CheckoutCreateInput!) {
      checkoutCreate(input: $input) {
        checkout {
          id
          webUrl
          lineItems(first: 10) {
            edges {
              node {
                id
                title
                quantity
                variant {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
          totalPrice {
            amount
            currencyCode
          }
        }
        checkoutUserErrors {
          message
          field
        }
      }
    }
  ''';

  /// Add line items to checkout
  static const String checkoutLineItemsAdd = r'''
    mutation CheckoutLineItemsAdd($checkoutId: ID!, $lineItems: [CheckoutLineItemInput!]!) {
      checkoutLineItemsAdd(checkoutId: $checkoutId, lineItems: $lineItems) {
        checkout {
          id
          webUrl
          lineItems(first: 10) {
            edges {
              node {
                id
                title
                quantity
                variant {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
          totalPrice {
            amount
            currencyCode
          }
        }
        checkoutUserErrors {
          message
          field
        }
      }
    }
  ''';

  /// Update line items in checkout
  static const String checkoutLineItemsUpdate = r'''
    mutation CheckoutLineItemsUpdate($checkoutId: ID!, $lineItems: [CheckoutLineItemUpdateInput!]!) {
      checkoutLineItemsUpdate(checkoutId: $checkoutId, lineItems: $lineItems) {
        checkout {
          id
          webUrl
          lineItems(first: 10) {
            edges {
              node {
                id
                title
                quantity
                variant {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
          totalPrice {
            amount
            currencyCode
          }
        }
        checkoutUserErrors {
          message
          field
        }
      }
    }
  ''';

  /// Remove line items from checkout
  static const String checkoutLineItemsRemove = r'''
    mutation CheckoutLineItemsRemove($checkoutId: ID!, $lineItemIds: [ID!]!) {
      checkoutLineItemsRemove(checkoutId: $checkoutId, lineItemIds: $lineItemIds) {
        checkout {
          id
          webUrl
          lineItems(first: 10) {
            edges {
              node {
                id
                title
                quantity
                variant {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
          totalPrice {
            amount
            currencyCode
          }
        }
        checkoutUserErrors {
          message
          field
        }
      }
    }
  ''';
}


/// GraphQL Query constants for Shopify Storefront API
class GraphQLQueries {
  // ========== PRODUCT QUERIES ==========

  /// Get all products with pagination
  static const String getProducts = r'''
    query GetProducts($first: Int!, $after: String, $query: String, $sortKey: ProductSortKeys, $reverse: Boolean) {
      products(first: $first, after: $after, query: $query, sortKey: $sortKey, reverse: $reverse) {
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
    query GetCollectionByHandle($handle: String!, $first: Int!, $after: String) {
      collection(handle: $handle) {
        id
        title
        description
        handle
        image {
          url
        }
        products(first: $first, after: $after) {
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

  /// Get brands from metaobjects
  static const String getBrandsFromMetaobjects = r'''
    query GetBrandsFromMetaobjects($first: Int!) {
      metaobjects(type: "brand", first: $first) {
        nodes {
          id
          handle
          name: field(key: "name") {
            value
          }
          image: field(key: "image") {
            reference {
              ... on MediaImage {
                image {
                  url
                  altText
                }
              }
            }
          }
          category: field(key: "category") {
            reference {
              ... on Collection {
                handle
              }
            }
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

  /// Get product recommendations
  static const String getProductRecommendations = r'''
    query GetProductRecommendations($productId: ID!) {
      productRecommendations(productId: $productId) {
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
    }
  ''';

  // ========== HOME BANNER QUERIES ==========

  /// Get home banners from metaobjects
  static const String getHomeBanners = r'''
    query GetHomeBanners($first: Int!) {
      metaobjects(type: "home_banner", first: $first) {
        nodes {
          handle
          title: field(key: "title") {
            value
          }
          image: field(key: "image") {
            reference {
              ... on MediaImage {
                image {
                  url
                  altText
                }
              }
            }
          }
          category: field(key: "category") {
            reference {
              ... on Collection {
                handle
              }
            }
          }
        }
      }
    }
  ''';

  // ========== OFFER BLOCKS QUERIES ==========

  /// Get offer blocks from metaobjects
  static const String getOfferBlocks = r'''
    query GetOfferBlocks {
      metaobjects(type: "offer_section", first: 20) {
        edges {
          node {
            id
            title: field(key: "title") {
              value
            }
            heroImage: field(key: "hero_image") {
              reference {
                ... on MediaImage {
                  image {
                    url
                    altText
                  }
                }
              }
            }
            button: field(key: "button_link") {
              value
            }
            featured_collection_title: field(key: "featured_collection_title") {
              value
            }
            featured_collection: field(key: "featured_collection") {
              reference {
                ... on Collection {
                  id
                  handle
                  title
                }
              }
            }
            items: field(key: "items") {
              references(first: 20) {
                nodes {
                  ... on Metaobject {
                    itemImage: field(key: "image") {
                      reference {
                        ... on MediaImage {
                          image {
                            url
                            altText
                          }
                        }
                      }
                    }
                    itemCollection: field(key: "collection") {
                      reference {
                        ... on Collection {
                          id
                          handle
                          title
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
    }
  ''';

  // ========== HOME SCREEN QUERIES ==========

  /// Get home screen sections
  static const String getHomeScreen = r'''
    query GetHomeScreen {
      metaobjects(type: "home_screen", first: 10) {
        nodes {
          id
          handle
          collectionTitle: field(key: "collection_title") {
            value
          }
          featuredCollection: field(key: "featured_collection") {
            reference {
              ... on Collection {
                id
                handle
                title
                image {
                  url
                  altText
                }
              }
            }
          }
          horizontalBanners: field(key: "horizontal_banners") {
            references(first: 10) {
              nodes {
                ...BannerFields
              }
            }
          }
          verticalBanners: field(key: "vertical_banners") {
            references(first: 10) {
              nodes {
                ...BannerFields
              }
            }
          }
        }
      }
    }

    fragment BannerFields on Metaobject {
      id
      handle
      image: field(key: "image") {
        reference {
          ... on MediaImage {
            image {
              url
              altText
            }
          }
        }
      }
      actionType: field(key: "action") {
        value
      }
      product: field(key: "product") {
        reference {
          ... on Product {
            id
            handle
            title
            featuredImage {
              url
            }
          }
        }
      }
      collection: field(key: "collection") {
        reference {
          ... on Collection {
            id
            handle
            title
            image {
              url
            }
          }
        }
      }
      page: field(key: "page") {
        reference {
          ... on Metaobject {
            title: field(key: "page") {
              value
            }
          }
        }
      }
    }
  ''';

  // ========== MENU QUERIES ==========

  /// Get menu by handle
  static const String getMenu = r'''
    query GetMenu($menuHandle: String!) {
      menu(handle: $menuHandle) {
        title
        items {
          title
          url
          items {
            title
            url
          }
        }
      }
    }
  ''';

  // ========== CUSTOMER QUERIES ==========

  /// Get customer profile information
  static const String getCustomer = r'''
    query GetCustomer($customerAccessToken: String!) {
      customer(customerAccessToken: $customerAccessToken) {
        id
        email
        firstName
        lastName
        phone
        defaultAddress {
          id
          address1
          address2
          city
          province
          zip
          country
        }
        addresses(first: 10) {
          edges {
            node {
              id
              address1
              address2
              city
              province
              zip
              country
            }
          }
        }
      }
    }
  ''';

  /// Get customer orders
  static const String getCustomerOrders = r'''
    query GetCustomerOrders($customerAccessToken: String!, $first: Int!, $after: String) {
      customer(customerAccessToken: $customerAccessToken) {
        orders(first: $first, after: $after) {
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
              fulfillmentStatus
              financialStatus
              lineItems(first: 10) {
                edges {
                  node {
                    title
                    quantity
                    originalTotalPrice {
                      amount
                      currencyCode
                    }
                    variant {
                      id
                      title
                      image {
                        url
                      }
                    }
                  }
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
    }
  ''';

  // ========== CHECKOUT MUTATIONS ==========

  /// Create cart for Shopify checkout flow (modern Cart API)
  static const String createCart = r'''
    mutation CreateCart($input: CartInput!) {
      cartCreate(input: $input) {
        cart {
          id
          checkoutUrl
          totalQuantity
          cost {
            totalAmount {
              amount
              currencyCode
            }
            subtotalAmount {
              amount
              currencyCode
            }
          }
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
                  }
                }
              }
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
}

const functions = require("firebase-functions/v1");
const admin     = require("firebase-admin");
const axios     = require("axios");

admin.initializeApp();

// ─────────────────────────────────────────────────────────────────────────────
// Config — read from functions/.env (never commit that file to git)
// ─────────────────────────────────────────────────────────────────────────────
function shopifyConfig() {
  const domain = process.env.SHOPIFY_STORE_DOMAIN;
  const token  = process.env.SHOPIFY_ADMIN_ACCESS_TOKEN;
  if (!domain || !token) {
    throw new Error("SHOPIFY_STORE_DOMAIN or SHOPIFY_ADMIN_ACCESS_TOKEN missing from .env");
  }
  return { domain, token };
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Low-level wrapper around the Shopify Admin GraphQL API.
 */
async function shopifyAdminQuery(query, variables = {}) {
  const { domain, token } = shopifyConfig();
  const url = `https://${domain}/admin/api/2024-01/graphql.json`;

  const response = await axios.post(
    url,
    { query, variables },
    {
      headers: {
        "Content-Type": "application/json",
        "X-Shopify-Access-Token": token,
      },
    }
  );

  const json = response.data;

  if (json.errors && json.errors.length > 0) {
    throw new Error(`Shopify GraphQL error: ${json.errors[0].message}`);
  }

  return json.data;
}

/**
 * Find a Shopify customer by email.
 * Returns { id, tags } or null if not found.
 */
async function findShopifyCustomerByEmail(email) {
  const query = `
    query findCustomer($query: String!) {
      customers(first: 1, query: $query) {
        edges {
          node {
            id
            tags
          }
        }
      }
    }
  `;

  const data  = await shopifyAdminQuery(query, { query: `email:${email}` });
  const edges = data?.customers?.edges ?? [];

  if (edges.length === 0) return null;

  return edges[0].node; // { id: "gid://shopify/Customer/xxx", tags: [...] }
}

/**
 * Add a tag to a Shopify customer without removing their existing tags.
 * No-op if the tag is already present.
 */
async function addTagToCustomer(customerId, newTag) {
  // Fetch current tags first so we don't overwrite them.
  const getQuery = `
    query getCustomer($id: ID!) {
      customer(id: $id) {
        id
        tags
      }
    }
  `;

  const getData      = await shopifyAdminQuery(getQuery, { id: customerId });
  const existingTags = getData?.customer?.tags ?? [];

  if (existingTags.includes(newTag)) {
    return { alreadyTagged: true };
  }

  const updatedTags = [...existingTags, newTag];

  const updateMutation = `
    mutation customerUpdate($input: CustomerInput!) {
      customerUpdate(input: $input) {
        customer {
          id
          tags
        }
        userErrors {
          field
          message
        }
      }
    }
  `;

  const updateData = await shopifyAdminQuery(updateMutation, {
    input: { id: customerId, tags: updatedTags },
  });

  const userErrors = updateData?.customerUpdate?.userErrors ?? [];
  if (userErrors.length > 0) {
    throw new Error(`Shopify userError: ${userErrors[0].message}`);
  }

  return { alreadyTagged: false };
}

// ─────────────────────────────────────────────────────────────────────────────
// TRIGGER: Auto-tag every new Firebase Auth user as mobile_app_user in Shopify.
//
// Fires automatically when signup() in AuthCubit calls
// createUserWithEmailAndPassword — no Flutter call needed for new signups.
// ─────────────────────────────────────────────────────────────────────────────
exports.onUserCreated = functions.region("asia-south1").auth.user().onCreate(async (user) => {
  const email = user.email;
  if (!email) {
    console.warn(`onUserCreated: no email for uid ${user.uid}, skipping.`);
    return;
  }

  try {
    const customer = await findShopifyCustomerByEmail(email);

    if (!customer) {
      // Shopify account doesn't exist yet — the signup flow creates it
      // shortly after. tagMobileAppUser callable handles tagging on first login.
      console.log(`onUserCreated: no Shopify customer for ${email} yet.`);
      return;
    }

    const result = await addTagToCustomer(customer.id, "mobile_app_user");
    if (result.alreadyTagged) {
      console.log(`onUserCreated: ${email} already has mobile_app_user tag.`);
    } else {
      console.log(`onUserCreated: mobile_app_user tag added for ${email}.`);
    }
  } catch (error) {
    console.error("onUserCreated: error tagging customer:", email, error);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// CALLABLE: Tag an existing Shopify customer as mobile_app_user.
//
// Called from AuthCubit._tagMobileAppUser() during login and after signup.
// Uses the caller's Firebase Auth token email to look up the Shopify customer
// — no customer ID needs to be passed from the app.
//
// Safe to call multiple times: no-op if the tag is already present.
//
// Flutter usage:
//   FirebaseFunctions.instance.httpsCallable('tagMobileAppUser').call();
// ─────────────────────────────────────────────────────────────────────────────
exports.tagMobileAppUser = functions.region("asia-south1").https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");
  }

  const email = context.auth.token.email;
  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "Authenticated user has no email.");
  }

  try {
    const customer = await findShopifyCustomerByEmail(email);

    if (!customer) {
      console.warn(`tagMobileAppUser: no Shopify customer found for ${email}.`);
      return { success: false, reason: "customer_not_found" };
    }

    const result = await addTagToCustomer(customer.id, "mobile_app_user");

    if (result.alreadyTagged) {
      console.log(`tagMobileAppUser: ${email} already tagged.`);
    } else {
      console.log(`tagMobileAppUser: mobile_app_user tag added for ${email}.`);
    }

    return { success: true, alreadyTagged: result.alreadyTagged };
  } catch (error) {
    console.error("tagMobileAppUser: error:", email, error);
    throw new functions.https.HttpsError("internal", "Failed to tag Shopify customer.");
  }
});

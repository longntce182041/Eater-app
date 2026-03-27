require("dotenv").config();

function createUnavailablePayOS(reason) {
  const errorMessage =
    reason || "PayOS is unavailable. Please install @payos/node and configure env vars.";

  return {
    createPaymentLink: async () => {
      throw new Error(errorMessage);
    },
    verifyPaymentWebhookData: (payload) => payload,
    confirmWebhook: async () => {
      throw new Error(errorMessage);
    },
  };
}

let payOS;

try {
  // Lazy load so backend can still boot when payment SDK is missing.
  const PayOS = require("@payos/node");
  payOS = new PayOS(
    process.env.PAYOS_CLIENT_ID,
    process.env.PAYOS_API_KEY,
    process.env.PAYOS_CHECKSUM_KEY,
  );

  const webhookUrl = process.env.PAYOS_WEBHOOK_URL;
  if (webhookUrl && typeof payOS.confirmWebhook === "function") {
    payOS
      .confirmWebhook(webhookUrl)
      .then(() => {
        console.log(`[PayOS] Webhook confirmed: ${webhookUrl}`);
      })
      .catch((error) => {
        console.error("[PayOS] Failed to confirm webhook URL:", error.message);
      });
  }
} catch (error) {
  console.warn("[PayOS] SDK unavailable:", error.message);
  payOS = createUnavailablePayOS(
    "PayOS SDK unavailable. Install @payos/node to enable payment features.",
  );
}

module.exports = payOS;

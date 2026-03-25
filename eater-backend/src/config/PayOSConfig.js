const PayOS = require("@payos/node");
require("dotenv").config();
const payOS = new PayOS(
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

module.exports = payOS;

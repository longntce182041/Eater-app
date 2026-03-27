const payOS = require("../../config/PayOSConfig");
const UserPro = require("../../models/userPro");

const PLAN_TYPES = {
  MONTHLY: "monthly",
  YEARLY: "yearly",
};

const PRO_MONTHLY_DURATION_DAYS = Number(
  process.env.PRO_MONTHLY_DURATION_DAYS || process.env.PRO_DURATION_DAYS || 30,
);
const PRO_YEARLY_DURATION_DAYS = Number(
  process.env.PRO_YEARLY_DURATION_DAYS || 365,
);

const PRO_MONTHLY_PRICE = Number(
  process.env.PRO_MONTHLY_PRICE || process.env.PRO_PLAN_PRICE || 49000,
);
const PRO_YEARLY_PRICE = Number(
  process.env.PRO_YEARLY_PRICE || PRO_MONTHLY_PRICE * 12 * 0.8,
);

const MONTHLY_BENEFITS = [
  "Personalized AI meal plans",
  "Advanced nutrition insights",
  "Priority nutritionist support",
  "Faster recipe recommendations",
];

const YEARLY_BENEFITS = [
  ...MONTHLY_BENEFITS,
  "Save more with yearly pricing",
  "Long-term progress tracking",
];

function resolvePlanBenefits(planType) {
  return planType === PLAN_TYPES.YEARLY ? YEARLY_BENEFITS : MONTHLY_BENEFITS;
}

function resolveProPlans() {
  return {
    [PLAN_TYPES.MONTHLY]: {
      planType: PLAN_TYPES.MONTHLY,
      amount: PRO_MONTHLY_PRICE,
      durationDays: PRO_MONTHLY_DURATION_DAYS,
      label: "Pro Monthly",
      benefits: MONTHLY_BENEFITS,
    },
    [PLAN_TYPES.YEARLY]: {
      planType: PLAN_TYPES.YEARLY,
      amount: PRO_YEARLY_PRICE,
      durationDays: PRO_YEARLY_DURATION_DAYS,
      label: "Pro Yearly",
      benefits: YEARLY_BENEFITS,
    },
  };
}

function getPlanConfig(planType) {
  const normalizedPlanType = String(
    planType || PLAN_TYPES.MONTHLY,
  ).toLowerCase();
  const plans = resolveProPlans();
  const selectedPlan = plans[normalizedPlanType];

  if (!selectedPlan) {
    const error = new Error(
      `Invalid planType. Supported: ${Object.keys(plans).join(", ")}`,
    );
    error.statusCode = 400;
    throw error;
  }

  if (
    !Number.isFinite(selectedPlan.amount) ||
    selectedPlan.amount <= 0 ||
    !Number.isFinite(selectedPlan.durationDays) ||
    selectedPlan.durationDays <= 0
  ) {
    const error = new Error("Invalid Pro plan configuration");
    error.statusCode = 500;
    throw error;
  }

  return selectedPlan;
}

function getDurationDaysBySubscription(subscription) {
  const duration = Number(subscription?.plan_duration_days);
  return Number.isFinite(duration) && duration > 0
    ? duration
    : PRO_MONTHLY_DURATION_DAYS;
}

function buildOrderCode() {
  return Date.now() + Math.floor(Math.random() * 1000);
}

function normalizeWebhookData(payload) {
  if (payload && typeof payload === "object" && payload.data) {
    return payload.data;
  }
  return payload || {};
}

function isPaymentSuccessful(data) {
  // Accepts both string and number for code/status, checks for all common success values
  if (!data) return false;
  const code = (data.code || data.paymentCode || "")
    .toString()
    .trim()
    .toUpperCase();
  const status = (data.status || data.desc || data.paymentStatus || "")
    .toString()
    .trim()
    .toUpperCase();
  // Log for debugging
  console.log("[isPaymentSuccessful] code:", code, "status:", status);
  return (
    code === "00" ||
    code === "0" ||
    status === "PAID" ||
    status === "SUCCESS" ||
    status === "COMPLETED" ||
    status === "THANH TOAN THANH CONG" ||
    status === "paid" ||
    status === "success" ||
    status === "completed" ||
    status === "thanh toan thanh cong"
  );
}

// Remove duplicate/old handlePayOSWebhook definition above

async function createProCheckout(userId, options = {}) {
  if (!userId) {
    const error = new Error("User ID is required");
    error.statusCode = 400;
    throw error;
  }

  const plan = getPlanConfig(options.planType);
  const amount = Number(options.amount ?? plan.amount);
  if (!Number.isFinite(amount) || amount <= 0) {
    const error = new Error("Invalid payment amount");
    error.statusCode = 400;
    throw error;
  }

  const returnUrl = options.returnUrl || process.env.PAYOS_RETURN_URL;
  const cancelUrl = options.cancelUrl || process.env.PAYOS_CANCEL_URL;

  if (!returnUrl || !cancelUrl) {
    const error = new Error("Missing PAYOS_RETURN_URL or PAYOS_CANCEL_URL");
    error.statusCode = 500;
    throw error;
  }

  const orderCode = buildOrderCode();
  const shortOrderCode = String(orderCode).slice(-6);
  const description =
    options.description ||
    `Nang cap ${plan.planType} #${shortOrderCode}`.slice(0, 25);

  const paymentData = {
    orderCode,
    amount,
    description,
    returnUrl,
    cancelUrl,
    expiredAt: Math.floor(Date.now() / 1000) + 15 * 60,
  };

  const paymentLinkData = await payOS.createPaymentLink(paymentData);

  await UserPro.findOneAndUpdate(
    { payos_order_code: orderCode },
    {
      userId,
      isActive: true,
      startDate: new Date(),
      endDate: new Date(Date.now() + plan.durationDays * 24 * 60 * 60 * 1000),
      plan_type: plan.planType,
      plan_duration_days: plan.durationDays,
      plan_amount: amount,
      payos_order_code: orderCode,
      payos_payment_link: paymentLinkData.checkoutUrl,
      payos_qr_code: paymentLinkData.qrCode,
    },
    {
      upsert: true,
      setDefaultsOnInsert: true,
      new: true,
    },
  );

  return {
    orderCode,
    planType: plan.planType,
    durationDays: plan.durationDays,
    amount,
    checkoutUrl: paymentLinkData.checkoutUrl,
    qrCode: paymentLinkData.qrCode,
  };
}

async function handlePayOSWebhook(webhookBody) {
  console.log("[Webhook] PayOS webhook received");
  const verified =
    typeof payOS.verifyPaymentWebhookData === "function"
      ? payOS.verifyPaymentWebhookData(webhookBody)
      : webhookBody;
  console.log("[Webhook] Verified data:", JSON.stringify(verified, null, 2));

  const data = normalizeWebhookData(verified);
  const orderCode = Number(data.orderCode);

  if (!Number.isFinite(orderCode)) {
    const error = new Error("Invalid orderCode in webhook payload");
    error.statusCode = 400;
    throw error;
  }

  if (!isPaymentSuccessful(data)) {
    console.log("[Webhook] Payment is not successful. Data:", data);
    return {
      processed: false,
      orderCode,
      message: "Payment is not successful",
    };
  }

  const subscription = await UserPro.findOne({ payos_order_code: orderCode });
  if (!subscription) {
    console.log("[Webhook] Subscription not found for orderCode:", orderCode);
    return {
      processed: false,
      orderCode,
      message: "Order not found",
    };
  }

  if (subscription.isActive) {
    console.log(
      "[Webhook] Subscription already active for orderCode:",
      orderCode,
    );
    return {
      processed: true,
      orderCode,
      alreadyActive: true,
    };
  }

  const now = new Date();
  const durationDays = getDurationDaysBySubscription(subscription);

  const existingActive = await UserPro.findOne({
    userId: subscription.userId,
    isActive: true,
    endDate: { $gte: now },
    _id: { $ne: subscription._id },
  }).sort({ endDate: -1 });

  const effectiveStartDate =
    existingActive?.endDate && existingActive.endDate > now
      ? existingActive.endDate
      : now;

  subscription.startDate = effectiveStartDate;
  subscription.endDate = new Date(
    effectiveStartDate.getTime() + durationDays * 24 * 60 * 60 * 1000,
  );
  subscription.isActive = true;
  subscription.payos_transaction_id =
    data.transactionId || data.reference || data.paymentLinkId || null;
  await subscription.save();

  console.log("[Webhook] After update:", subscription);

  return {
    processed: true,
    orderCode,
    userId: subscription.userId,
    planType: subscription.plan_type || PLAN_TYPES.MONTHLY,
    durationDays,
    benefits: resolvePlanBenefits(subscription.plan_type),
    startDate: subscription.startDate,
    endDate: subscription.endDate,
  };
}

async function getProStatus(userId) {
  const now = new Date();

  const activeSubscription = await UserPro.findOne({
    userId,
    isActive: true,
    endDate: { $gte: now },
  }).sort({ endDate: -1 });

  if (!activeSubscription) {
    return { isPro: false };
  }

  return {
    isPro: true,
    planType: activeSubscription.plan_type || PLAN_TYPES.MONTHLY,
    durationDays: getDurationDaysBySubscription(activeSubscription),
    amount: Number(activeSubscription.plan_amount) || null,
    benefits: resolvePlanBenefits(activeSubscription.plan_type),
    startDate: activeSubscription.startDate,
    endDate: activeSubscription.endDate,
    orderCode: activeSubscription.payos_order_code,
  };
}

function getProPlans() {
  return {
    plans: Object.values(resolveProPlans()),
  };
}

function getPayOSUrls() {
  const returnUrl = process.env.PAYOS_RETURN_URL;
  const cancelUrl = process.env.PAYOS_CANCEL_URL;

  if (!returnUrl || !cancelUrl) {
    const error = new Error("Missing PAYOS_RETURN_URL or PAYOS_CANCEL_URL");
    error.statusCode = 500;
    throw error;
  }

  return {
    returnUrl,
    cancelUrl,
  };
}

module.exports = {
  createProCheckout,
  handlePayOSWebhook,
  getProStatus,
  getProPlans,
  getPayOSUrls,
};

const axios = require("axios");

const { Ingredient } = require("../../models/ingredients");
const {
  calculateNutritionFromMongo,
  normalizeUnit,
} = require("../../utils/mealImageNutrition.util");

const GEMINI_BASE_URL =
  "https://generativelanguage.googleapis.com/v1beta/models";
const DEFAULT_MODEL = process.env.GEMINI_VISION_MODEL || "gemini-2.5-flash";
const DEFAULT_TIMEOUT_MS = Number(process.env.GEMINI_TIMEOUT_MS || 20000);

function sanitizeModelName(model) {
  if (!model) return "";

  return (
    String(model)
      .trim()
      .toLowerCase()
      // Fix common typos such as gemini-I.5-flash or gemini-l.5-flash
      .replace(/^gemini-[il]\./, "gemini-1.")
      .replace(/\s+/g, "-")
  );
}

function getModelCandidates() {
  const envModel = sanitizeModelName(
    process.env.GEMINI_VISION_MODEL || DEFAULT_MODEL,
  );
  // Remove gemini-2.0-flash (deprecated for new users)
  const candidates = [envModel, "gemini-2.5-flash"].filter(Boolean);
  return [...new Set(candidates)];
}

function getGeminiErrorMessage(error) {
  return String(error?.response?.data?.error?.message || error?.message || "");
}

function isModelNotFoundError(error) {
  const message = getGeminiErrorMessage(error).toLowerCase();
  return (
    error?.response?.status === 404 ||
    message.includes("not found") ||
    message.includes("listmodels")
  );
}

function isQuotaExceededError(error) {
  const status = error?.response?.status;
  const message = getGeminiErrorMessage(error).toLowerCase();
  return (
    status === 429 ||
    message.includes("quota exceeded") ||
    message.includes("rate limit") ||
    message.includes("resource exhausted")
  );
}

function extractRetryAfterSeconds(error) {
  const headerValue = Number(error?.response?.headers?.["retry-after"]);
  if (Number.isFinite(headerValue) && headerValue > 0) return headerValue;

  const message = getGeminiErrorMessage(error);
  const regex = /retry\s+in\s+([0-9]+(?:\.[0-9]+)?)s/i;
  const match = message.match(regex);
  if (!match) return null;

  const value = Number(match[1]);
  return Number.isFinite(value) && value > 0 ? Math.ceil(value) : null;
}

function stripCodeFence(text) {
  if (!text) return "";
  const trimmed = String(text).trim();
  if (!trimmed.startsWith("```")) return trimmed;

  return trimmed
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/, "")
    .trim();
}

function extractJsonObject(text) {
  const clean = stripCodeFence(text);
  try {
    return JSON.parse(clean);
  } catch (_) {
    const firstBrace = clean.indexOf("{");
    const lastBrace = clean.lastIndexOf("}");
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      const sliced = clean.slice(firstBrace, lastBrace + 1);
      return JSON.parse(sliced);
    }
    throw new Error("Gemini response is not valid JSON");
  }
}

function buildPrompt() {
  return [
    "You are a nutrition image analysis assistant.",
    "Analyze the meal image and return STRICT JSON only.",
    "Do not include markdown fences, explanation, or extra fields.",
    "JSON schema:",
    "{",
    '  "meal_name": "string",',
    '  "ingredients": [',
    '    { "name": "string", "estimated_amount": number, "estimated_unit": "g|ml|piece|tbsp|tsp|cup|oz|kg|l" }',
    "  ],",
    '  "confidence": number',
    "}",
    "Rules:",
    "- Keep ingredient names simple and singular where possible.",
    "- estimated_amount must be numeric.",
    "- confidence must be between 0 and 1.",
  ].join("\n");
}

function sanitizeAIResult(parsed) {
  const ingredients = Array.isArray(parsed.ingredients)
    ? parsed.ingredients
    : [];
  return {
    meal_name: String(parsed.meal_name || "unknown meal").trim(),
    confidence: Number.isFinite(Number(parsed.confidence))
      ? Math.max(0, Math.min(1, Number(parsed.confidence)))
      : 0,
    ingredients: ingredients.map((item) => ({
      name: String(item?.name || "").trim(),
      estimated_amount: Number(item?.estimated_amount),
      estimated_unit: normalizeUnit(item?.estimated_unit || "piece"),
    })),
  };
}

async function callGeminiVision({ apiKey, imageBuffer, mimeType }) {
  const payload = {
    contents: [
      {
        role: "user",
        parts: [
          { text: buildPrompt() },
          {
            inline_data: {
              mime_type: mimeType,
              data: imageBuffer.toString("base64"),
            },
          },
        ],
      },
    ],
    generationConfig: {
      temperature: 0.2,
      response_mime_type: "application/json",
    },
  };

  const modelCandidates = getModelCandidates();
  let lastError = null;

  for (const model of modelCandidates) {
    const url = `${GEMINI_BASE_URL}/${model}:generateContent?key=${apiKey}`;
    try {
      const response = await axios.post(url, payload, {
        timeout: DEFAULT_TIMEOUT_MS,
        headers: { "Content-Type": "application/json" },
      });

      const text =
        response.data?.candidates?.[0]?.content?.parts?.[0]?.text ||
        response.data?.candidates?.[0]?.content?.parts
          ?.map((p) => p.text)
          .join("\n");

      if (!text) {
        throw new Error("Gemini returned empty response");
      }

      return sanitizeAIResult(extractJsonObject(text));
    } catch (error) {
      lastError = error;
      if (isQuotaExceededError(error)) {
        break;
      }
      if (!isModelNotFoundError(error)) {
        break;
      }
    }
  }

  try {
    throw lastError || new Error("Gemini request failed");
  } catch (error) {
    const retryAfterSeconds = extractRetryAfterSeconds(error);

    if (isQuotaExceededError(error)) {
      const quotaError = new Error(
        retryAfterSeconds
          ? `Gemini quota exceeded. Please retry after ${retryAfterSeconds}s or use a billed API key/project.`
          : "Gemini quota exceeded. Please check billing/quota or use a billed API key/project.",
      );
      quotaError.statusCode = 503;
      quotaError.type = "gemini_quota_exceeded";
      quotaError.retryAfterSeconds = retryAfterSeconds;
      throw quotaError;
    }

    const geminiError = new Error(
      error.code === "ECONNABORTED"
        ? "Gemini request timed out"
        : error.response?.data?.error?.message ||
            error.message ||
            "Gemini request failed",
    );
    geminiError.statusCode = 502;
    geminiError.type = "gemini_error";
    throw geminiError;
  }
}

async function scanMealImageFromBuffer(file, options = {}) {
  if (!file || !file.buffer) {
    const err = new Error("Image file is required");
    err.statusCode = 400;
    throw err;
  }

  if (!process.env.GOOGLE_API_KEY) {
    const err = new Error(
      "Missing GOOGLE_API_KEY in environment configuration",
    );
    err.statusCode = 500;
    throw err;
  }

  const aiResult = await callGeminiVision({
    apiKey: process.env.GOOGLE_API_KEY,
    imageBuffer: file.buffer,
    mimeType: file.mimetype || "image/jpeg",
  });

  const nutritionResult = await calculateNutritionFromMongo(
    aiResult.ingredients,
    Ingredient,
    {
      aliasMap: options.aliasMap,
      unitConversionMap: options.unitConversionMap,
    },
  );

  return {
    meal_name: aiResult.meal_name,
    confidence: aiResult.confidence,
    ingredients: nutritionResult.ingredients,
    totals: nutritionResult.totals,
    note: "Nutrition values are estimated from image analysis and local ingredient database.",
  };
}

module.exports = {
  scanMealImageFromBuffer,
};

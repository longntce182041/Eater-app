const DEFAULT_ALIAS_MAP = {
  chickenbreast: "chicken breast",
  chickenthigh: "chicken thigh",
  eggwhite: "egg",
  eggs: "egg",
  tomatoes: "tomato",
  onions: "onion",
  potatoes: "potato",
  ricecooked: "rice",
  cookedrice: "rice",
  oliveoil: "olive oil",
  springonion: "green onion",
};

const UNIT_ALIASES = {
  g: "g",
  gram: "g",
  grams: "g",
  gr: "g",
  kg: "kg",
  kilogram: "kg",
  kilograms: "kg",
  ml: "ml",
  milliliter: "ml",
  milliliters: "ml",
  l: "l",
  liter: "l",
  liters: "l",
  piece: "piece",
  pieces: "piece",
  pcs: "piece",
  pc: "piece",
  unit: "piece",
  tbsp: "tbsp",
  tablespoon: "tbsp",
  tablespoons: "tbsp",
  tsp: "tsp",
  teaspoon: "tsp",
  teaspoons: "tsp",
  cup: "cup",
  cups: "cup",
  oz: "oz",
  ounce: "oz",
  ounces: "oz",
};

const DEFAULT_UNIT_CONVERSION_MAP = {
  g: { dimension: "mass", toBase: 1 },
  kg: { dimension: "mass", toBase: 1000 },
  oz: { dimension: "mass", toBase: 28.3495 },
  ml: { dimension: "volume", toBase: 1 },
  l: { dimension: "volume", toBase: 1000 },
  tsp: { dimension: "volume", toBase: 4.92892 },
  tbsp: { dimension: "volume", toBase: 14.7868 },
  cup: { dimension: "volume", toBase: 240 },
  piece: { dimension: "count", toBase: 1 },
};

function normalizeName(name) {
  if (!name) return "";

  return String(name)
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function normalizeUnit(unit) {
  if (!unit) return "";
  const cleaned = normalizeName(unit).replace(/\s/g, "");
  return UNIT_ALIASES[cleaned] || cleaned;
}

function round2(value) {
  return Math.round((Number(value) + Number.EPSILON) * 100) / 100;
}

function convertAmount(
  amount,
  fromUnit,
  toUnit,
  unitConversionMap = DEFAULT_UNIT_CONVERSION_MAP,
) {
  const numericAmount = Number(amount);
  if (!Number.isFinite(numericAmount) || numericAmount <= 0) return null;

  const from = normalizeUnit(fromUnit);
  const to = normalizeUnit(toUnit);
  if (!from || !to) return null;
  if (from === to) return round2(numericAmount);

  const fromMeta = unitConversionMap[from];
  const toMeta = unitConversionMap[to];
  if (!fromMeta || !toMeta) return null;
  if (fromMeta.dimension !== toMeta.dimension) return null;

  const amountInBase = numericAmount * fromMeta.toBase;
  const converted = amountInBase / toMeta.toBase;
  return round2(converted);
}

function tokenize(text) {
  return normalizeName(text).split(" ").filter(Boolean);
}

function similarityScore(source, target) {
  const sourceNorm = normalizeName(source);
  const targetNorm = normalizeName(target);
  if (!sourceNorm || !targetNorm) return 0;

  if (sourceNorm === targetNorm) return 1;
  if (sourceNorm.includes(targetNorm) || targetNorm.includes(sourceNorm))
    return 0.92;

  const sourceTokens = new Set(tokenize(sourceNorm));
  const targetTokens = new Set(tokenize(targetNorm));
  if (!sourceTokens.size || !targetTokens.size) return 0;

  let overlap = 0;
  for (const token of sourceTokens) {
    if (targetTokens.has(token)) overlap += 1;
  }

  const tokenScore = overlap / Math.max(sourceTokens.size, targetTokens.size);
  const lenPenalty =
    1 -
    Math.abs(sourceNorm.length - targetNorm.length) /
      Math.max(sourceNorm.length, targetNorm.length);
  return tokenScore * 0.75 + Math.max(0, lenPenalty) * 0.25;
}

function applyAlias(name, aliasMap = DEFAULT_ALIAS_MAP) {
  const normalized = normalizeName(name).replace(/\s/g, "");
  const aliased = aliasMap[normalized] || aliasMap[normalizeName(name)] || name;
  return normalizeName(aliased);
}

function buildExactIndex(ingredients) {
  const map = new Map();
  for (const ingredient of ingredients) {
    const key = normalizeName(ingredient.name);
    if (key && !map.has(key)) {
      map.set(key, ingredient);
    }
  }
  return map;
}

function findBestMatchByFuzzy(inputName, ingredientDocs, threshold = 0.55) {
  let best = null;
  let bestScore = 0;

  for (const doc of ingredientDocs) {
    const score = similarityScore(inputName, doc.name);
    if (score > bestScore) {
      best = doc;
      bestScore = score;
    }
  }

  if (!best || bestScore < threshold) return null;
  return best;
}

async function calculateNutritionFromMongo(
  ingredientsFromAI,
  IngredientModel,
  options = {},
) {
  const aliasMap = options.aliasMap || DEFAULT_ALIAS_MAP;
  const unitConversionMap =
    options.unitConversionMap || DEFAULT_UNIT_CONVERSION_MAP;
  const fuzzyThreshold = Number.isFinite(options.fuzzyThreshold)
    ? options.fuzzyThreshold
    : 0.55;

  const ingredientDocs = await IngredientModel.find(
    {},
    {
      name: 1,
      unit: 1,
      calories_per_unit: 1,
      protein: 1,
      carbs: 1,
      fats: 1,
    },
  ).lean();

  const exactMap = buildExactIndex(ingredientDocs);

  const totals = {
    kcal: 0,
    protein: 0,
    carbs: 0,
    fats: 0,
  };

  const items = [];

  for (const aiIngredient of ingredientsFromAI || []) {
    const inputName = String(aiIngredient.name || "").trim();
    const estimatedAmount = Number(aiIngredient.estimated_amount);
    const estimatedUnit = normalizeUnit(aiIngredient.estimated_unit || "piece");
    const normalizedInputName = applyAlias(inputName, aliasMap);

    const baseResult = {
      input_name: inputName,
      matched_name: null,
      estimated_amount: Number.isFinite(estimatedAmount)
        ? estimatedAmount
        : null,
      estimated_unit: estimatedUnit || null,
      converted_amount: null,
      converted_unit: null,
      db_unit: null,
      nutrition: { kcal: 0, protein: 0, carbs: 0, fats: 0 },
      status: "invalid_ai_data",
    };

    if (
      !inputName ||
      !Number.isFinite(estimatedAmount) ||
      estimatedAmount <= 0
    ) {
      items.push(baseResult);
      continue;
    }

    let matched = exactMap.get(normalizedInputName);
    if (!matched) {
      matched = findBestMatchByFuzzy(
        normalizedInputName,
        ingredientDocs,
        fuzzyThreshold,
      );
    }

    if (!matched) {
      items.push({
        ...baseResult,
        status: "unmatched_ingredient",
      });
      continue;
    }

    const dbUnit = normalizeUnit(matched.unit);
    const convertedAmount = convertAmount(
      estimatedAmount,
      estimatedUnit,
      dbUnit,
      unitConversionMap,
    );

    if (convertedAmount == null) {
      items.push({
        ...baseResult,
        matched_name: matched.name,
        db_unit: dbUnit || matched.unit,
        status: "unit_not_convertible",
      });
      continue;
    }

    const kcal = round2((matched.calories_per_unit || 0) * convertedAmount);
    const protein = round2((matched.protein || 0) * convertedAmount);
    const carbs = round2((matched.carbs || 0) * convertedAmount);
    const fats = round2((matched.fats || 0) * convertedAmount);

    totals.kcal = round2(totals.kcal + kcal);
    totals.protein = round2(totals.protein + protein);
    totals.carbs = round2(totals.carbs + carbs);
    totals.fats = round2(totals.fats + fats);

    items.push({
      ...baseResult,
      matched_name: matched.name,
      converted_amount: convertedAmount,
      converted_unit: dbUnit || matched.unit,
      db_unit: dbUnit || matched.unit,
      nutrition: {
        kcal,
        protein,
        carbs,
        fats,
      },
      status: "ok",
    });
  }

  return {
    ingredients: items,
    totals,
  };
}

module.exports = {
  aliasMap: DEFAULT_ALIAS_MAP,
  unitConversionMap: DEFAULT_UNIT_CONVERSION_MAP,
  normalizeName,
  normalizeUnit,
  convertAmount,
  calculateNutritionFromMongo,
};

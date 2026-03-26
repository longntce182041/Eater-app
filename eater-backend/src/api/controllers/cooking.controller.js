const { CookingSession } = require("../../models/cookingSession");
const { Recipe } = require("../../models/Recipe");
const { RecipesStep } = require("../../models/recipes_step");
const { RecipesIngredient } = require("../../models/recipes_ingredient");

/**
 * Start a new cooking session
 * GET /api/recipes/:recipeId/cook/start
 */
exports.startCookingSession = async (req, res) => {
  try {
    const { recipeId } = req.params;
    const { servings = 1 } = req.query; // Allow customizing servings on start
    const userId = req.user.id;

    // Check if recipe exists
    const recipe = await Recipe.findById(recipeId);
    if (!recipe) {
      return res.status(404).json({ message: "Recipe not found" });
    }

    // Create new cooking session
    const session = new CookingSession({
      userId,
      recipeId,
      servings: parseInt(servings) || 1,
      status: "active",
      currentStepIndex: 0,
      completedSteps: [],
      deviceInfo: {
        platform: req.headers["user-agent"],
        locale: req.headers["accept-language"],
      },
    });

    await session.save();

    // Fetch recipe steps with ingredient mappings
    const steps = await RecipesStep.find({ recipeId }).sort("stepNumber");

    // Enrich steps with ingredient information
    const enrichedSteps = await Promise.all(
      steps.map(async (step) => {
        // Get ingredients related to this step (if captured in data)
        // For now, return all ingredients for the recipe
        const ingredients = await RecipesIngredient.find({
          recipeId,
        }).populate("ingredientId");

        return {
          stepNumber: step.stepNumber,
          instruction: step.instruction,
          estimatedTime: calculateStepTime(recipe.cookingTime, step.stepNumber),
          ingredients: ingredients.map((ing) => ({
            id: ing.ingredientId._id,
            name: ing.ingredientId.name,
            quantity: ing.quantity * (servings / recipe.baseServings),
            unit: ing.unit,
          })),
          tips: generateTipsForStep(step.instruction),
          completed: false,
        };
      })
    );

    res.status(201).json({
      success: true,
      session: {
        id: session._id,
        recipeId: session.recipeId,
        currentStepIndex: session.currentStepIndex,
        completedSteps: session.completedSteps,
        status: session.status,
        startTime: session.startTime,
        elapsedTime: 0,
      },
      recipe: {
        id: recipe._id,
        name: recipe.name,
        description: recipe.description,
        cookingTime: recipe.cookingTime,
        baseServings: recipe.baseServings,
        displayImageUrl: recipe.imageUrl,
        steps: enrichedSteps,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error starting cooking session", error: error.message });
  }
};

/**
 * Get current cooking session
 * GET /api/recipes/:recipeId/cook/session/:sessionId
 */
exports.getCookingSession = async (req, res) => {
  try {
    const { recipeId, sessionId } = req.params;
    const userId = req.user.id;

    const session = await CookingSession.findOne({
      _id: sessionId,
      userId,
      recipeId,
    });

    if (!session) {
      return res.status(404).json({ message: "Cooking session not found" });
    }

    const recipe = await Recipe.findById(recipeId);
    const steps = await RecipesStep.find({ recipeId }).sort("stepNumber");

    // Calculate elapsed time
    let elapsedTime = Math.floor(
      (new Date() - session.startTime) / 1000
    );
    if (session.pausedTime) {
      elapsedTime = Math.floor(
        (session.pausedTime - session.startTime) / 1000
      );
    }

    // Enrich steps with completion status
    const enrichedSteps = await Promise.all(
      steps.map(async (step) => {
        const completedStep = session.completedSteps.find(
          (cs) => cs.stepNumber === step.stepNumber
        );
        const ingredients = await RecipesIngredient.find({
          recipeId,
        }).populate("ingredientId");

        return {
          stepNumber: step.stepNumber,
          instruction: step.instruction,
          estimatedTime: calculateStepTime(recipe.cookingTime, step.stepNumber),
          ingredients: ingredients.map((ing) => ({
            id: ing.ingredientId._id,
            name: ing.ingredientId.name,
            quantity: ing.quantity * (session.servings / recipe.baseServings),
            unit: ing.unit,
          })),
          tips: generateTipsForStep(step.instruction),
          completed: !!completedStep,
          completedAt: completedStep?.completedAt,
          duration: completedStep?.duration,
        };
      })
    );

    res.json({
      success: true,
      session: {
        id: session._id,
        recipeId: session.recipeId,
        currentStepIndex: session.currentStepIndex,
        completedSteps: session.completedSteps,
        status: session.status,
        startTime: session.startTime,
        elapsedTime,
      },
      recipe: {
        id: recipe._id,
        name: recipe.name,
        cookingTime: recipe.cookingTime,
        baseServings: recipe.baseServings,
        displayImageUrl: recipe.imageUrl,
        steps: enrichedSteps,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error fetching cooking session", error: error.message });
  }
};

/**
 * Mark a step as completed
 * PATCH /api/recipes/:recipeId/cook/session/:sessionId/step/:stepNumber
 */
exports.completeStep = async (req, res) => {
  try {
    const { recipeId, sessionId, stepNumber } = req.params;
    const { notes } = req.body;
    const userId = req.user.id;

    const session = await CookingSession.findOne({
      _id: sessionId,
      userId,
      recipeId,
    });

    if (!session) {
      return res.status(404).json({ message: "Cooking session not found" });
    }

    // Check if step already completed
    const alreadyCompleted = session.completedSteps.some(
      (s) => s.stepNumber === parseInt(stepNumber)
    );

    if (alreadyCompleted) {
      return res
        .status(400)
        .json({ message: "Step already completed" });
    }

    // Calculate duration for this step
    let duration = 0;
    if (session.completedSteps.length > 0) {
      const lastStep = session.completedSteps[session.completedSteps.length - 1];
      duration = Math.floor((new Date() - lastStep.completedAt) / 1000);
    } else {
      duration = Math.floor((new Date() - session.startTime) / 1000);
    }

    // Add completed step
    session.completedSteps.push({
      stepNumber: parseInt(stepNumber),
      completedAt: new Date(),
      duration,
      notes,
    });

    // Update current step index
    session.currentStepIndex = parseInt(stepNumber);

    await session.save();

    res.json({
      success: true,
      session: {
        id: session._id,
        currentStepIndex: session.currentStepIndex,
        completedSteps: session.completedSteps,
        status: session.status,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error completing step", error: error.message });
  }
};

/**
 * Pause cooking session
 * POST /api/recipes/:recipeId/cook/session/:sessionId/pause
 */
exports.pauseCookingSession = async (req, res) => {
  try {
    const { recipeId, sessionId } = req.params;
    const userId = req.user.id;

    const session = await CookingSession.findOneAndUpdate(
      {
        _id: sessionId,
        userId,
        recipeId,
        status: "active",
      },
      {
        status: "paused",
        pausedTime: new Date(),
      },
      { new: true }
    );

    if (!session) {
      return res.status(404).json({ message: "Active cooking session not found" });
    }

    res.json({
      success: true,
      session: {
        id: session._id,
        status: session.status,
        pausedTime: session.pausedTime,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error pausing session", error: error.message });
  }
};

/**
 * Resume cooking session
 * POST /api/recipes/:recipeId/cook/session/:sessionId/resume
 */
exports.resumeCookingSession = async (req, res) => {
  try {
    const { recipeId, sessionId } = req.params;
    const userId = req.user.id;

    const session = await CookingSession.findOne({
      _id: sessionId,
      userId,
      recipeId,
      status: "paused",
    });

    if (!session) {
      return res.status(404).json({ message: "Paused cooking session not found" });
    }

    // Calculate pause duration and adjust start time
    const pauseDuration = Math.floor(
      (new Date() - session.pausedTime) / 1000
    );
    session.startTime = new Date(
      session.startTime.getTime() + pauseDuration * 1000
    );
    session.status = "active";
    session.pausedTime = null;

    await session.save();

    res.json({
      success: true,
      session: {
        id: session._id,
        status: session.status,
        startTime: session.startTime,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error resuming session", error: error.message });
  }
};

/**
 * Complete cooking session
 * POST /api/recipes/:recipeId/cook/session/:sessionId/complete
 */
exports.completeCookingSession = async (req, res) => {
  try {
    const { recipeId, sessionId } = req.params;
    const { notes } = req.body;
    const userId = req.user.id;

    const session = await CookingSession.findOne({
      _id: sessionId,
      userId,
      recipeId,
    });

    if (!session) {
      return res.status(404).json({ message: "Cooking session not found" });
    }

    // Calculate total duration
    const endTime = new Date();
    const totalDuration = Math.floor((endTime - session.startTime) / 1000);

    // Update session
    session.status = "completed";
    session.endTime = endTime;
    session.totalDuration = totalDuration;

    await session.save();

    res.json({
      success: true,
      session: {
        id: session._id,
        status: session.status,
        endTime: session.endTime,
        totalDuration: session.totalDuration,
        stepsCompleted: session.completedSteps.length,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error completing session", error: error.message });
  }
};

/**
 * Get recipe steps with all details
 * GET /api/recipes/:recipeId/steps
 */
exports.getRecipeSteps = async (req, res) => {
  try {
    const { recipeId } = req.params;
    const { servings = 1 } = req.query;

    const recipe = await Recipe.findById(recipeId);
    if (!recipe) {
      return res.status(404).json({ message: "Recipe not found" });
    }

    const steps = await RecipesStep.find({ recipeId }).sort("stepNumber");

    const enrichedSteps = await Promise.all(
      steps.map(async (step) => {
        const ingredients = await RecipesIngredient.find({
          recipeId,
        }).populate("ingredientId");

        return {
          stepNumber: step.stepNumber,
          instruction: step.instruction,
          estimatedTime: calculateStepTime(recipe.cookingTime, step.stepNumber),
          ingredients: ingredients.map((ing) => ({
            id: ing.ingredientId._id,
            name: ing.ingredientId.name,
            quantity: ing.quantity * (parseInt(servings) / recipe.baseServings),
            unit: ing.unit,
          })),
          tips: generateTipsForStep(step.instruction),
        };
      })
    );

    res.json({
      success: true,
      steps: enrichedSteps,
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error fetching recipe steps", error: error.message });
  }
};

// ============ UTILITY FUNCTIONS ============

/**
 * Estimate time for each step (distribute total cooking time)
 */
function calculateStepTime(totalTime, stepNumber) {
  // Simple distribution: estimate ~equal time per step
  // This can be improved with ML later
  const estimatedSteps = Math.ceil(totalTime / 5); // assume 5 min per step avg
  return Math.max(Math.floor(totalTime / estimatedSteps), 2); // min 2 min per step
}

/**
 * Generate AI/rule-based tips for steps
 */
function generateTipsForStep(instruction) {
  const instruction_lower = instruction.toLowerCase();

  // Simple heuristics for tips
  if (instruction_lower.includes("boil") && instruction_lower.includes("water")) {
    return "Use filtered water for better taste. Salt water should taste like seawater.";
  }
  if (instruction_lower.includes("cook") && instruction_lower.includes("pasta")) {
    return "Cook pasta until al dente (slightly firm). Stir occasionally to prevent sticking.";
  }
  if (instruction_lower.includes("fry") || instruction_lower.includes("sauté")) {
    return "Use medium-high heat and keep ingredients moving to prevent burning.";
  }
  if (instruction_lower.includes("season") || instruction_lower.includes("salt")) {
    return "Taste as you go. You can always add more seasoning, but can't remove it.";
  }
  if (instruction_lower.includes("render") || instruction_lower.includes("crisp")) {
    return "Cook slowly on medium heat for crispiness without burning.";
  }

  return "Follow instructions carefully and don't rush this step.";
}

module.exports = exports;

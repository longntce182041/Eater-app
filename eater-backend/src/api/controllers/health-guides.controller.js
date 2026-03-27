const { HealthGuide } = require('../../models/HealthGuide');

// Valid enum values
const VALID_CATEGORIES = ['fasting', 'workouts', 'nutrition', 'meal_prep', 'emotional_eating', 'hydration', 'stress_management'];
const VALID_DIFFICULTIES = ['beginner', 'intermediate', 'advanced'];

// Sanitize error messages - don't leak internal details
const sanitizeError = (error) => {
  if (error.name === 'ValidationError') {
    return 'Invalid input provided';
  }
  if (error.name === 'CastError') {
    return 'Invalid guide ID format';
  }
  return 'An error occurred while fetching guides';
};

/**
 * Get all active guides (grouped by category, or filtered by category)
 * GET /api/health-guides
 * Query: ?category=fasting (optional)
 */
exports.getGuidesByCategory = async (req, res) => {
  try {
    const { category, limit = 100, skip = 0 } = req.query;

    // If category filter requested
    if (category) {
      // Validate category
      if (!VALID_CATEGORIES.includes(category)) {
        return res.status(400).json({
          status: 'error',
          message: `Invalid category. Valid options: ${VALID_CATEGORIES.join(', ')}`,
        });
      }

      const parsedLimit = Math.min(parseInt(limit) || 100, 1000); // Max 1000
      const parsedSkip = Math.max(parseInt(skip) || 0, 0);

      const guides = await HealthGuide.find({
        category,
        isActive: true,
      })
        .sort('order')
        .limit(parsedLimit)
        .skip(parsedSkip);

      const total = await HealthGuide.countDocuments({
        category,
        isActive: true,
      });

      return res.json({
        status: 'success',
        message: 'Health guides retrieved successfully',
        data: {
          category,
          guides: guides.map((guide) => ({
            id: guide._id,
            title: guide.title,
            description: guide.description,
            icon: guide.icon,
            estimatedReadTime: guide.estimatedReadTime,
            tags: guide.tags,
            difficulty: guide.difficulty,
          })),
          pagination: {
            total,
            limit: parsedLimit,
            skip: parsedSkip,
          },
        },
      });
    }

    // No category filter - return all grouped by category
    const parsedLimit = Math.min(parseInt(limit) || 1000, 5000); // Max 5000 when getting all
    const guides = await HealthGuide.find({ isActive: true })
      .sort('category order')
      .limit(parsedLimit);

    // Group by category
    const categoriesMap = {};
    guides.forEach((guide) => {
      if (!categoriesMap[guide.category]) {
        categoriesMap[guide.category] = [];
      }
      categoriesMap[guide.category].push(guide);
    });

    // Convert to array format with category info
    const categoryList = Object.entries(categoriesMap).map(([category, guides]) => ({
      category,
      guides: guides.map((guide) => ({
        id: guide._id,
        title: guide.title,
        description: guide.description,
        icon: guide.icon,
        estimatedReadTime: guide.estimatedReadTime,
        tags: guide.tags,
        difficulty: guide.difficulty,
      })),
    }));

    res.json({
      status: 'success',
      message: 'Health guides retrieved successfully',
      data: categoryList,
    });
  } catch (error) {
    console.error('Error fetching health guides:', error);
    res.status(500).json({
      status: 'error',
      message: sanitizeError(error),
    });
  }
};

/**
 * Get single guide with full content
 * GET /api/health-guides/:id
 */
exports.getGuideDetail = async (req, res) => {
  try {
    const { id } = req.params;

    const guide = await HealthGuide.findById(id);
    if (!guide) {
      return res.status(404).json({
        status: 'error',
        message: 'Health guide not found',
      });
    }

    res.json({
      status: 'success',
      message: 'Health guide retrieved successfully',
      data: {
        id: guide._id,
        category: guide.category,
        title: guide.title,
        description: guide.description,
        content: guide.content,
        icon: guide.icon,
        estimatedReadTime: guide.estimatedReadTime,
        tags: guide.tags,
        difficulty: guide.difficulty,
      },
    });
  } catch (error) {
    console.error('Error fetching health guide:', error);
    res.status(500).json({
      status: 'error',
      message: sanitizeError(error),
    });
  }
};

/**
 * Create new health guide (ADMIN ONLY)
 * POST /api/health-guides
 */
exports.createGuide = async (req, res) => {
  try {
    const { category, title, description, content, icon, order, difficulty, estimatedReadTime, tags } = req.body;

    // Validation
    if (!category || !title || !description || !content) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing required fields: category, title, description, content',
      });
    }

    // Validate enum values
    if (!VALID_CATEGORIES.includes(category)) {
      return res.status(400).json({
        status: 'error',
        message: `Invalid category. Valid options: ${VALID_CATEGORIES.join(', ')}`,
      });
    }

    if (difficulty && !VALID_DIFFICULTIES.includes(difficulty)) {
      return res.status(400).json({
        status: 'error',
        message: `Invalid difficulty. Valid options: ${VALID_DIFFICULTIES.join(', ')}`,
      });
    }

    // Validate length constraints
    if (title.length > 200) {
      return res.status(400).json({
        status: 'error',
        message: 'Title must be under 200 characters',
      });
    }

    if (description.length > 500) {
      return res.status(400).json({
        status: 'error',
        message: 'Description must be under 500 characters',
      });
    }

    if (content.length > 50000) {
      return res.status(400).json({
        status: 'error',
        message: 'Content must be under 50,000 characters',
      });
    }

    const newGuide = new HealthGuide({
      category,
      title,
      description,
      content,
      icon: icon || 'auto',
      order: order || 0,
      difficulty: difficulty || 'beginner',
      estimatedReadTime: estimatedReadTime || 5,
      tags: tags || [],
      isActive: true,
    });

    await newGuide.save();

    res.status(201).json({
      status: 'success',
      message: 'Health guide created successfully',
      data: {
        id: newGuide._id,
        category: newGuide.category,
        title: newGuide.title,
      },
    });
  } catch (error) {
    console.error('Error creating health guide:', error);
    res.status(500).json({
      status: 'error',
      message: sanitizeError(error),
    });
  }
};

/**
 * Update health guide (ADMIN ONLY)
 * PUT /api/health-guides/:id
 */
exports.updateGuide = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    // Validate enum values if provided
    if (updates.category && !VALID_CATEGORIES.includes(updates.category)) {
      return res.status(400).json({
        status: 'error',
        message: `Invalid category. Valid options: ${VALID_CATEGORIES.join(', ')}`,
      });
    }

    if (updates.difficulty && !VALID_DIFFICULTIES.includes(updates.difficulty)) {
      return res.status(400).json({
        status: 'error',
        message: `Invalid difficulty. Valid options: ${VALID_DIFFICULTIES.join(', ')}`,
      });
    }

    // Validate length constraints if provided
    if (updates.title && updates.title.length > 200) {
      return res.status(400).json({
        status: 'error',
        message: 'Title must be under 200 characters',
      });
    }

    if (updates.description && updates.description.length > 500) {
      return res.status(400).json({
        status: 'error',
        message: 'Description must be under 500 characters',
      });
    }

    if (updates.content && updates.content.length > 50000) {
      return res.status(400).json({
        status: 'error',
        message: 'Content must be under 50,000 characters',
      });
    }

    const guide = await HealthGuide.findByIdAndUpdate(id, updates, {
      new: true,
      runValidators: true,
    });

    if (!guide) {
      return res.status(404).json({
        status: 'error',
        message: 'Health guide not found',
      });
    }

    res.json({
      status: 'success',
      message: 'Health guide updated successfully',
      data: {
        id: guide._id,
        category: guide.category,
        title: guide.title,
      },
    });
  } catch (error) {
    console.error('Error updating health guide:', error);
    res.status(500).json({
      status: 'error',
      message: sanitizeError(error),
    });
  }
};

/**
 * Delete health guide (ADMIN ONLY)
 * DELETE /api/health-guides/:id
 */
exports.deleteGuide = async (req, res) => {
  try {
    const { id } = req.params;

    const guide = await HealthGuide.findByIdAndDelete(id);

    if (!guide) {
      return res.status(404).json({
        status: 'error',
        message: 'Health guide not found',
      });
    }

    res.json({
      status: 'success',
      message: 'Health guide deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting health guide:', error);
    res.status(500).json({
      status: 'error',
      message: sanitizeError(error),
    });
  }
};

module.exports = exports;

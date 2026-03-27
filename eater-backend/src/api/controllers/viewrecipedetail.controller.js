const viewRecipeDetailService = require('../services/viewrecipedetail.service');

class ViewRecipeDetailController {
  // GET full recipe details (for meal plan view)
  async getFullRecipeDetails(req, res) {
    try {
      console.log(`[ViewRecipeDetailController] GET /view-recipe-details/${req.params.id}`);
      
      const recipeDetail = await viewRecipeDetailService.getFullRecipeDetails(req.params.id);
      
      console.log(`[ViewRecipeDetailController] Recipe detail fetched successfully for: ${recipeDetail.name}`);
      res.json({ success: true, data: recipeDetail });
    } catch (error) {
      console.error(`[ViewRecipeDetailController] Error: ${error.message}`);
      res.status(404).json({ success: false, message: error.message });
    }
  }

  // GET basic recipe info
  async getRecipeBasicInfo(req, res) {
    try {
      const recipeInfo = await viewRecipeDetailService.getRecipeBasicInfo(req.params.id);
      res.json({ success: true, data: recipeInfo });
    } catch (error) {
      res.status(404).json({ success: false, message: error.message });
    }
  }
}

module.exports = new ViewRecipeDetailController();

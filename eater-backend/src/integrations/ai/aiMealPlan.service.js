const { generateMealPlan } = require("./aiClient");

async function requestAIMealPlan(userContext) {
  // userContext may include preferences, health data, goals, etc.
  const { data } = await generateMealPlan(userContext);
  return data;
}

module.exports = {
  requestAIMealPlan,
};

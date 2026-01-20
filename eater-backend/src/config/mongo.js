const mongoConfig = {
  uri:
    process.env.MONGODB_URI ||
    "mongodb://localhost:27017/ai_healthy_meal_planner",
  options: {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  },
};

module.exports = { mongoConfig };

const mongoose = require("mongoose");
const { createCollections } = require("../utils/createCollections");

const mongoConfig = {
  uri:
    process.env.MONGODB_URI ||
    "mongodb://127.0.0.1:27017/ai_healthy_meal_planner",
  // mongoose 9+ uses sane defaults; explicit options removed
};

const connectMongo = async () => {
  try {
    await mongoose.connect(mongoConfig.uri);
    const { host, name } = mongoose.connection;
    console.log(`MongoDB connected: ${host}/${name}`);
    await createCollections();
  } catch (err) {
    console.error("MongoDB connection error:", err.message);
    process.exit(1);
  }
};

connectMongo();

module.exports = { mongoConfig, connectMongo };

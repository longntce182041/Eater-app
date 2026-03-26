const mongoose = require("mongoose");

const mongoConfig = { uri: process.env.MONGODB_URI };
// mongoose 9+ uses sane defaults; explicit options removed

const connectMongo = async () => {
  try {
    await mongoose.connect(mongoConfig.uri);
    const { host, name } = mongoose.connection;
    console.log(`MongoDB connected: ${host}/${name}`);
  } catch (err) {
    console.error("MongoDB connection error:", err.message);
    process.exit(1);
  }
};

connectMongo();

module.exports = { mongoConfig, connectMongo };

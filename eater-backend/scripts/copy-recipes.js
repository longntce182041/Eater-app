const mongoose = require("mongoose");

const sourceDB = "ai_healthy_meal_planner-1";
const targetDB = "ai_healthy_meal_planner";

const collections = [
  "recipes",
  "recipenutritions",
  "diettypes",
  "ingredients",
  "recipediettypes",
  "recipesingredients",
];

async function copyData() {
  try {
    console.log(`Copying data from ${sourceDB} to ${targetDB}...\n`);

    // Connect to source
    const sourceConn = await mongoose
      .createConnection(`mongodb://127.0.0.1:27017/${sourceDB}`)
      .asPromise();
    console.log("✅ Connected to source database");

    // Connect to target
    const targetConn = await mongoose
      .createConnection(`mongodb://127.0.0.1:27017/${targetDB}`)
      .asPromise();
    console.log("✅ Connected to target database");

    for (const collName of collections) {
      try {
        const sourceCollection = sourceConn.collection(collName);
        const targetCollection = targetConn.collection(collName);

        // Delete existing data in target
        const deleteResult = await targetCollection.deleteMany({});
        console.log(
          `\n🗑️  Deleted ${deleteResult.deletedCount} documents from ${collName}`,
        );

        // Copy data
        const docs = await sourceCollection.find({}).toArray();
        if (docs.length > 0) {
          await targetCollection.insertMany(docs);
          console.log(`✅ Copied ${docs.length} documents to ${collName}`);
        } else {
          console.log(`⚠️  No documents found in ${collName}`);
        }
      } catch (err) {
        console.error(`Error copying ${collName}:`, err.message);
      }
    }

    await sourceConn.close();
    await targetConn.close();

    console.log("\n✅ Data copy completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  }
}

copyData();

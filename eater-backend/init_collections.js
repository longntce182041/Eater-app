// // File: init_collections.js
// const mongoose = require('mongoose');
// const fs = require('fs');
// const path = require('path');
//
// // Đường dẫn DB mới của bạn
// const MONGO_URI = 'mongodb://127.0.0.1:27017/ai_healthy_meal_planner-1';
//
// const initDB = async () => {
//     try {
//         await mongoose.connect(MONGO_URI);
//         console.log('✅ Connected to DB...');
//
//         // 1. Quét tất cả file trong thư mục models
//         const modelsPath = path.join(__dirname, 'src', 'models');
//         const files = fs.readdirSync(modelsPath);
//
//         // 2. Load từng file model để Mongoose nhận diện
//         files.forEach(file => {
//             if (file.endsWith('.js')) {
//                 require(path.join(modelsPath, file));
//                 console.log(`📥 Loaded model file: ${file}`);
//             }
//         });
//
//         // 3. Ép tạo collection cho từng Model đã load
//         const modelNames = mongoose.modelNames();
//         console.log(`\n🚀 Đang tạo ${modelNames.length} Collections...`);
//
//         for (const name of modelNames) {
//             try {
//                 await mongoose.model(name).createCollection();
//                 console.log(`   - Created: ${name}`);
//             } catch (err) {
//                 // Lỗi này thường do collection đã tồn tại, bỏ qua không sao
//                 if (err.codeName === 'NamespaceExists') {
//                     console.log(`   - Exists:  ${name}`);
//                 } else {
//                     console.error(`   - Error ${name}:`, err.message);
//                 }
//             }
//         }
//
//         console.log('\n✅ HOÀN TẤT! Hãy Refresh lại MongoDB Compass.');
//         process.exit();
//
//     } catch (error) {
//         console.error('❌ Lỗi:', error);
//         process.exit(1);
//     }
// };
//
// initDB();
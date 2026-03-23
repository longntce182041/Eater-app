const { RecipesReview } = require('../../models/recipes_review'); // Check đúng tên file model của bạn
const User = require('../../models/User'); // Import nếu cần check tồn tại
const { Recipe } = require('../../models/Recipe'); // Import nếu cần check tồn tại

class ReviewService {
    // 1. Get All + Search (Comment, Recipe Name, User Email) + Filter (Rating)
    async getAllReviews(query) {
        const { keyword, rating, page = 1, limit = 10 } = query;
        
        // Tạo Pipeline cho Aggregation
        const pipeline = [];

        // --- BƯỚC 1: JOIN BẢNG (LOOKUP) ---
        // Nối với bảng Users để lấy email
        pipeline.push({
            $lookup: {
                from: 'users', // Tên collection trong DB (thường là số nhiều, viết thường)
                localField: 'userId',
                foreignField: '_id',
                as: 'userInfo'
            }
        });
        // Nối với bảng Recipes để lấy tên món
        pipeline.push({
            $lookup: {
                from: 'recipes', 
                localField: 'recipeId',
                foreignField: '_id',
                as: 'recipeInfo'
            }
        });

        // Unwind (Trải phẳng mảng để dễ lọc)
        pipeline.push(
            { $unwind: { path: '$userInfo', preserveNullAndEmptyArrays: true } },
            { $unwind: { path: '$recipeInfo', preserveNullAndEmptyArrays: true } }
        );

        // --- BƯỚC 2: TẠO BỘ LỌC (MATCH) ---
        const matchStage = {};

        // Lọc theo Rating
        if (rating) {
            matchStage.rating = parseInt(rating);
        }

        // Tìm kiếm đa năng (Keyword)
        if (keyword) {
            const regex = new RegExp(keyword, 'i');
            matchStage.$or = [
                { comment: regex },               // Tìm trong comment
                { 'userInfo.email': regex },      // Tìm trong email user
                { 'recipeInfo.name': regex }      // Tìm trong tên món ăn
            ];
        }

        // Đẩy matchStage vào pipeline
        pipeline.push({ $match: matchStage });

        // --- BƯỚC 3: PHÂN TRANG & ĐẾM TỔNG (FACET) ---
        pipeline.push({
            $facet: {
                data: [
                    { $sort: { createdAt: -1 } }, // Sắp xếp mới nhất
                    { $skip: (parseInt(page) - 1) * parseInt(limit) },
                    { $limit: parseInt(limit) },
                    // Project lại để output giống cấu trúc cũ (để Frontend không bị lỗi)
                    {
                        $project: {
                            _id: 1,
                            rating: 1,
                            comment: 1,
                            createdAt: 1,
                            userId: '$userInfo',   // Map lại vào userId để frontend đọc được .email
                            recipeId: '$recipeInfo' // Map lại vào recipeId để frontend đọc được .name
                        }
                    }
                ],
                totalCount: [{ $count: 'count' }]
            }
        });

        // --- BƯỚC 4: THỰC THI ---
        const result = await RecipesReview.aggregate(pipeline);
        
        const reviews = result[0].data;
        const total = result[0].totalCount[0] ? result[0].totalCount[0].count : 0;

        return { 
            reviews, 
            total, 
            page: parseInt(page), 
            totalPages: Math.ceil(total / limit) || 1
        };
    }

    // 2. Get Detail
    async getReviewById(id) {
        const review = await RecipesReview.findById(id)
            .populate('userId', 'email fullName')
            .populate('recipeId', 'name description');
            
        if (!review) throw new Error("Review not found");
        return review;
    }

    // 3. Delete Review (Chức năng chính của Admin: Xóa review spam/xấu)
    async deleteReview(id) {
        const review = await RecipesReview.findByIdAndDelete(id);
        if (!review) throw new Error("Review not found");
        return review;
    }
}

module.exports = new ReviewService();
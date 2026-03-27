/**
 * Seed data for Health Guides
 * Run: node eater-backend/src/seeds/health-guides.seed.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const { HealthGuide } = require('../models/HealthGuide');

const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/eater';

const healthGuidesSeed = [
  // Fasting Guides
  {
    category: 'fasting',
    title: 'Intermittent Fasting 101',
    description: 'Learn the basics of intermittent fasting and how it can benefit your health.',
    content: `Intermittent Fasting (IF) is an eating pattern that cycles between periods of eating and fasting. It's not about what you eat, but when you eat.\n\n**Benefits:**\n- Improved mental clarity and focus\n- Weight management and metabolic health\n- Reduced inflammation\n- Better blood sugar control\n\n**Common Protocols:**\n- **16/8 Method:** Fast for 16 hours, eat within 8-hour window\n- **5:2 Diet:** Eat normally 5 days, restrict calories 2 days\n- **Eat-Stop-Eat:** 24-hour complete fast once or twice weekly\n\n**Tips for Beginners:**\n1. Start slowly with a 12-14 hour fast\n2. Stay hydrated during fasting periods\n3. Break your fast with nutrient-dense foods\n4. Listen to your body and adjust as needed`,
    icon: 'schedule',
    order: 1,
    difficulty: 'beginner',
    estimatedReadTime: 8,
    tags: ['diet', 'health', 'beginner'],
    isActive: true,
  },
  {
    category: 'fasting',
    title: 'Advanced Fasting Strategies',
    description: 'Explore advanced intermittent fasting protocols and optimization techniques.',
    content: `For those with experience in basic fasting, advanced strategies can unlock new benefits.\n\n**Extended Fasting (24+ hours):**\n- Allow your body to enter deep autophagy\n- Improved cellular repair mechanisms\n- Only do this 1-2 times per month initially\n\n**Alternate Day Fasting (ADF):**\n- Fast for 24 hours, eat normally the next day\n- More aggressive weight loss\n- Better for athletic performance\n\n**Mondays Fasts:**\n- Use Monday as a reset day\n- Helps maintain momentum throughout the week\n- Plan your meals in advance\n\n**Stack with Exercise:**\n- Fasted cardio: 20-30 minutes\n- Break fast with protein afterward\n- Weight training: eat first, then train`,
    icon: 'schedule',
    order: 2,
    difficulty: 'advanced',
    estimatedReadTime: 12,
    tags: ['fasting', 'advanced', 'fitness'],
    isActive: true,
  },

  // Workout Guides
  {
    category: 'workouts',
    title: 'Home Workouts for Beginners',
    description: 'Get fit at home with no equipment. Perfect for beginners.',
    content: `No gym? No problem! You can achieve great fitness results right at home.\n\n**Bodyweight Exercises:**\n- Push-ups: 3 sets of 8-10 reps\n- Squats: 3 sets of 12-15 reps\n- Lunges: 3 sets of 10 reps per leg\n- Plank: Hold for 30-60 seconds, 3 sets\n- Burpees: 3 sets of 10 reps\n\n**Sample Beginner Workout (3x per week):**\n\nWarm-up (5 minutes):\n- Jumping jacks\n- Arm circles\n- Leg swings\n\nMain (20 minutes):\n- 2 rounds of 10 push-ups, 15 squats, 10 lunges per leg\n- Rest 60 seconds between rounds\n\nCool-down (5 minutes):\n- Stretching and deep breathing\n\n**Tips:**\n- Start with what you can do comfortably\n- Gradually increase reps and sets\n- Rest days are important for recovery`,
    icon: 'fitness_center',
    order: 1,
    difficulty: 'beginner',
    estimatedReadTime: 10,
    tags: ['exercise', 'home', 'beginner'],
    isActive: true,
  },
  {
    category: 'workouts',
    title: 'High Intensity Interval Training (HIIT)',
    description: 'Maximize your workout efficiency with HIIT training.',
    content: `HIIT is a training technique that involves intense bursts of exercise followed by short recovery periods.\n\n**Benefits:**\n- Time-efficient (20-30 minutes)\n- Burns more calories in less time\n- Improves cardiovascular fitness\n- Boosts metabolism for hours after\n\n**Basic HIIT Structure:**\n- 30 seconds: Maximum intensity exercise\n- 15-30 seconds: Recovery/light activity\n- Repeat 8-10 rounds\n\n**Sample HIIT Workout:**\n1. Burpees (30 sec hard / 30 sec rest)\n2. Mountain climbers (30 sec hard / 30 sec rest)\n3. High knees (30 sec hard / 30 sec rest)\n4. Jump squats (30 sec hard / 30 sec rest)\n\nRepeat 2-3 times\n\n**Important Notes:**\n- Not suitable for complete beginners\n- Proper form is crucial to avoid injury\n- Cool down properly after each session`,
    icon: 'fitness_center',
    order: 2,
    difficulty: 'advanced',
    estimatedReadTime: 9,
    tags: ['cardio', 'advanced', 'hiit'],
    isActive: true,
  },

  // Nutrition Guides
  {
    category: 'nutrition',
    title: 'Macronutrients Explained',
    description: 'Understanding proteins, carbs, and fats for optimal nutrition.',
    content: `Macronutrients are the foundation of good nutrition. Here's what you need to know.\n\n**Proteins (4 calories per gram):**\n- Essential for muscle build and repair\n- Supports immune function\n- Increase satiety (feel fuller longer)\n- Sources: Chicken, fish, eggs, legumes, tofu\n\n**Carbohydrates (4 calories per gram):**\n- Primary energy source for the body\n- Important for brain function\n- Choose complex carbs over simple sugars\n- Sources: Whole grains, fruits, vegetables, beans\n\n**Fats (9 calories per gram):**\n- Essential for hormone production\n- Support vitamin absorption\n- Not all fats are equal - choose healthy fats\n- Sources: Nuts, seeds, avocados, olive oil, fish\n\n**Macronutrient Ratios:**\n- 40% carbs, 30% protein, 30% fat (balanced)\n- Adjust based on your goals and lifestyle\n- Everyone is different - experiment to find your sweet spot`,
    icon: 'nutrition',
    order: 1,
    difficulty: 'beginner',
    estimatedReadTime: 8,
    tags: ['nutrition', 'basics', 'diet'],
    isActive: true,
  },

  // Meal Prep Guides
  {
    category: 'meal_prep',
    title: 'Weekly Meal Prep For Busy People',
    description: 'Plan and prepare meals for the entire week in just 2 hours.',
    content: `Meal prep can save you time, money, and help you eat healthier. Here's how to do it efficiently.\n\n**Best Time to Meal Prep:**\n- Sunday evening or Wednesday afternoon\n- Choose a time when you're least busy\n- Set aside 1.5-2 hours\n\n**Step-by-Step Process:**\n\n1. **Plan Your Meals** (15 minutes)\n   - Choose 3-4 proteins\n   - Select 3-4 vegetables\n   - Pick 2-3 grains\n\n2. **Make a Shopping List** (10 minutes)\n   - Check what you already have\n   - Buy in bulk when possible\n\n3. **Cook Everything** (60 minutes)\n   - Start with what takes longest\n   - Cook proteins first\n   - Roast vegetables\n   - Cook grains\n\n4. **Portion and Store** (30 minutes)\n   - Use glass containers\n   - Portion into meal-sized amounts\n   - Label with dates\n   - Refrigerate (up to 4 days) or freeze\n\n**Pro Tips:**\n- Keep portion sizes consistent\n- Make sauces and dressings separately\n- Don't prep salads in advance (will wilt)`,
    icon: 'restaurant',
    order: 1,
    difficulty: 'beginner',
    estimatedReadTime: 7,
    tags: ['meal-prep', 'planning', 'cooking'],
    isActive: true,
  },

  // Emotional Eating Guides
  {
    category: 'emotional_eating',
    title: 'Understanding Emotional Eating',
    description: 'Recognize triggers and develop healthier coping strategies.',
    content: `Emotional eating is using food to cope with emotions rather than eating due to physical hunger.\n\n**Common Triggers:**\n- Stress and anxiety\n- Boredom\n- Loneliness\n- Fatigue\n- Sadness or depression\n- Habit or routine\n\n**How to Identify Emotional Eating:**\n- Eating when you're not physically hungry\n- Craving specific comfort foods\n- Eating quickly without enjoying food\n- Eating to numb emotions\n- Feeling guilty after eating\n\n**Alternative Coping Strategies:**\n\n1. **Physical Activity**\n   - Take a 10-minute walk\n   - Do some stretching\n   - Dance to your favorite song\n\n2. **Mindfulness Practices**\n   - Meditation\n   - Deep breathing exercises\n   - Journaling about your feelings\n\n3. **Social Connection**\n   - Call a friend\n   - Join a support group\n   - Spend time with family\n\n4. **Self-Care**\n   - Take a bath\n   - Read a book\n   - Listen to relaxing music\n\n**Action Steps:**\n1. Keep a food journal noting emotions\n2. Identify your top 3 triggers\n3. Create a list of alternatives for each trigger\n4. Practice these alternatives when cravings hit`,
    icon: 'sentiment_satisfied',
    order: 1,
    difficulty: 'intermediate',
    estimatedReadTime: 10,
    tags: ['mental-health', 'eating-habits', 'psychology'],
    isActive: true,
  },

  // Hydration Guides
  {
    category: 'hydration',
    title: 'The Importance of Staying Hydrated',
    description: 'Learn why water is essential and how much you need daily.',
    content: `Water is vital for nearly every function in your body. Most people don't drink enough.\n\n**Functions of Water:**\n- Regulates body temperature\n- Transports nutrients and oxygen\n- Aids digestion\n- Removes waste and toxins\n- Lubricates joints\n- Cushions organs\n\n**How Much Water Do You Need?**\n\n**General Rule:** 8x8 rule (8 glasses of 8oz = 64oz/day)\n\n**Better Approach:** Use your weight\n- Drink half your body weight in ounces daily\n- Example: 160 lbs person = 80 oz per day\n- Adjust for activity level (add 12oz per 30 min exercise)\n\n**Signs of Dehydration:**\n- Dark urine\n- Dry mouth and lips\n- Fatigue and headaches\n- Dizziness\n- Reduced urination\n\n**Hydration Tips:**\n1. Drink water with meals\n2. Keep a water bottle with you\n3. Drink water before, during, and after exercise\n4. Set phone reminders if needed\n5. Infuse water with fruits for variety\n6. Monitor your urine color (should be light yellow)\n\n**Don't Overdo It:**\n- Drinking excessive water can lead to hyponatremia\n- Listen to your body's thirst signals`,
    icon: 'local_drink',
    order: 1,
    difficulty: 'beginner',
    estimatedReadTime: 6,
    tags: ['hydration', 'health', 'wellness'],
    isActive: true,
  },

  // Stress Management Guides
  {
    category: 'stress_management',
    title: 'Stress Management Techniques',
    description: 'Practical methods to reduce stress and improve mental wellness.',
    content: `Chronic stress affects your physical and mental health. Learn evidence-based techniques to manage it.\n\n**Understanding Stress:**\n- Acute stress: Short-term, helpful for alertness\n- Chronic stress: Long-term, harmful to health\n- Each person has different stress triggers\n\n**Simple Stress-Relief Techniques:**\n\n**1. Deep Breathing (2-5 minutes)**\n- Breathe in slowly for 4 counts\n- Hold for 4 counts\n- Exhale slowly for 4 counts\n- Repeat 5-10 times\n\n**2. Progressive Muscle Relaxation**\n- Tense each muscle group for 5 seconds\n- Release and notice the difference\n- Start with feet, work up to head\n\n**3. Mindfulness Meditation**\n- Sit comfortably and focus on breathing\n- When mind wanders, gently return focus\n- Start with 5 minutes daily\n\n**4. Physical Exercise**\n- Any movement helps (walking, dancing, yoga)\n- 30 minutes most days\n- Releases endorphins (feel-good chemicals)\n\n**5. Connection and Support**\n- Talk to friends or family\n- Join a community group\n- Consider therapy or counseling\n\n**Lifestyle Changes:**\n- Get 7-9 hours of sleep\n- Limit caffeine intake\n- Practice gratitude daily\n- Set healthy boundaries\n- Do activities you enjoy\n\n**When to Seek Help:**\nIf stress is overwhelming, consult a mental health professional.`,
    icon: 'spa',
    order: 1,
    difficulty: 'beginner',
    estimatedReadTime: 9,
    tags: ['mental-health', 'stress', 'wellness'],
    isActive: true,
  },
];

async function seedHealthGuides() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGO_URI);
    console.log('✓ Connected to MongoDB');

    // Clear existing guides
    await HealthGuide.deleteMany({});
    console.log('✓ Cleared existing health guides');

    // Insert seed data
    const result = await HealthGuide.insertMany(healthGuidesSeed);
    console.log(`✓ Inserted ${result.length} health guides`);

    // Log summary by category
    const guides = await HealthGuide.find({});
    const byCategory = {};
    guides.forEach((guide) => {
      if (!byCategory[guide.category]) {
        byCategory[guide.category] = 0;
      }
      byCategory[guide.category]++;
    });

    console.log('\nGuides by category:');
    Object.entries(byCategory).forEach(([category, count]) => {
      console.log(`  - ${category}: ${count} guide(s)`);
    });

    console.log('\n✓ Seed completed successfully!');
  } catch (error) {
    console.error('✗ Error seeding database:', error.message);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('✓ Disconnected from MongoDB');
  }
}

// Run the seed
seedHealthGuides();

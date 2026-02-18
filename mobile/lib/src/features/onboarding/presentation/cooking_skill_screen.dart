// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// class CookingSkillLevel {
//   final String id;
//   final String title;
//   final String subtitle;
//   final String? description;
//   final IconData icon;

//   const CookingSkillLevel({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     this.description,
//     required this.icon,
//   });
// }

// class CookingSkillScreen extends StatefulWidget {
//   const CookingSkillScreen({super.key});

//   @override
//   State<CookingSkillScreen> createState() => _CookingSkillScreenState();
// }

// class _CookingSkillScreenState extends State<CookingSkillScreen> {
//   final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

//   List<CookingSkillLevel> _levels = const [];
//   String? _selectedLevelId;
//   bool _isLoading = true;
//   bool _isSubmitting = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchLevels();
//   }

//   Future<void> _fetchLevels() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final response = await _dio.get('/onboarding/cooking-skills');
//       final data = response.data;
//       if (data is List) {
//         _levels = data.map((e) {
//           final map = Map<String, dynamic>.from(e);
//           return CookingSkillLevel(
//             id: map['id']?.toString() ?? '',
//             title: map['title']?.toString() ?? '',
//             subtitle: map['subtitle']?.toString() ?? '',
//             description: map['description']?.toString(),
//             icon: Icons.restaurant, // fallback icon; replace if API provides
//           );
//         }).toList();
//       }
//       if (_levels.isEmpty) {
//         _levels = _fallbackLevels();
//       }
//     } catch (e) {
//       _levels = _fallbackLevels();
//       _errorMessage = 'Failed to load levels. Showing defaults.';
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   List<CookingSkillLevel> _fallbackLevels() {
//     return const [
//       CookingSkillLevel(
//         id: 'novice',
//         title: 'Novice',
//         subtitle: '"I can cook sandwich"',
//         icon: Icons.lunch_dining,
//       ),
//       CookingSkillLevel(
//         id: 'basic',
//         title: 'Basic',
//         subtitle: '"I cook only simple recipes"',
//         description:
//             "You're on your way! We'll help you develop your skills with easy recipes",
//         icon: Icons.ramen_dining,
//       ),
//       CookingSkillLevel(
//         id: 'intermediate',
//         title: 'Intermediate',
//         subtitle: '"I regularly try new recipes"',
//         icon: Icons.set_meal,
//       ),
//       CookingSkillLevel(
//         id: 'advanced',
//         title: 'Advanced',
//         subtitle: '"I can cook any recipe"',
//         icon: Icons.sushi,
//       ),
//     ];
//   }

//   Future<void> _handleSubmit() async {
//     if (_selectedLevelId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select your cooking skill level.'),
//         ),
//       );
//       return;
//     }
//     if (_isSubmitting) return;

//     setState(() => _isSubmitting = true);

//     try {
//       final response = await _dio.post(
//         '/onboarding/cooking-skills/selection',
//         data: {'skillLevelId': _selectedLevelId},
//       );
//       debugPrint('Cooking skill saved: ${response.data}');
//       if (!mounted) return;
//       Navigator.pushNamed(context, '/onboarding/preferences');
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Failed to save your cooking skills. Please try again.',
//           ),
//         ),
//       );
//       setState(() => _isSubmitting = false);
//     }
//   }

//   void _handleSelect(String id) {
//     if (_isSubmitting) return;
//     setState(() {
//       _selectedLevelId = id;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE6D9F5),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
//                 ),
//               )
//             : Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 16,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const OnboardingProgressBar(),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'How would you rate your cooking skills?',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                             height: 1.2,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _InfoCard(),
//                         if (_errorMessage != null) ...[
//                           const SizedBox(height: 12),
//                           Text(
//                             _errorMessage!,
//                             style: const TextStyle(
//                               color: Colors.red,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       itemCount: _levels.length,
//                       itemBuilder: (context, index) {
//                         final level = _levels[index];
//                         final isSelected = level.id == _selectedLevelId;
//                         return Padding(
//                           padding: EdgeInsets.only(
//                             bottom: index == _levels.length - 1 ? 120 : 16,
//                           ),
//                           child: CookingSkillCard(
//                             level: level,
//                             isSelected: isSelected,
//                             onTap: () => _handleSelect(level.id),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.95),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.black87),
//                   onPressed: _isSubmitting
//                       ? null
//                       : () => Navigator.pop(context),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: (_selectedLevelId == null || _isSubmitting)
//                       ? null
//                       : _handleSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1A237E),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     disabledBackgroundColor: Colors.grey,
//                     elevation: 0,
//                   ),
//                   child: _isSubmitting
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         )
//                       : const Text(
//                           'Next',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class OnboardingProgressBar extends StatelessWidget {
//   const OnboardingProgressBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: const [
//         _ProgressSegment(color: Colors.green, isActive: true),
//         SizedBox(width: 6),
//         _ProgressSegment(color: Colors.yellow, isActive: true),
//         SizedBox(width: 6),
//         _ProgressSegment(color: Colors.orange, isActive: true),
//         SizedBox(width: 6),
//         _ProgressSegment(color: Colors.purple, isActive: true),
//         SizedBox(width: 6),
//         _ProgressSegment(color: Colors.purple, isActive: false),
//       ],
//     );
//   }
// }

// class _ProgressSegment extends StatelessWidget {
//   final Color color;
//   final bool isActive;

//   const _ProgressSegment({required this.color, required this.isActive});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         height: 8,
//         decoration: BoxDecoration(
//           color: isActive ? color : color.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFD4C4ED),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.emoji_food_beverage,
//               size: 32,
//               color: Colors.purple,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   'Behind the question',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   'Your skill level lets us match ...',
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.black87,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'More',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CookingSkillCard extends StatelessWidget {
//   final CookingSkillLevel level;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const CookingSkillCard({
//     super.key,
//     required this.level,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFD4C4ED) : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           level.title,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           level.subtitle,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.black54,
//                           ),
//                         ),
//                         if (level.description != null) ...[
//                           const SizedBox(height: 10),
//                           Text(
//                             level.description!,
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: Colors.black54,
//                               height: 1.3,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Container(
//                     width: 56,
//                     height: 56,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Icon(level.icon, size: 28, color: Colors.deepOrange),
//                   ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               Positioned(
//                 top: 12,
//                 right: 12,
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.purple, width: 2),
//                   ),
//                   child: const Icon(
//                     Icons.check,
//                     color: Colors.purple,
//                     size: 18,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

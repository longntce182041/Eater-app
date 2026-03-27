import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meal_log_provider.dart';
import '../providers/navigation_provider.dart';
import '../../domain/entities/meal_log.dart';
import '../../data/providers/meal_log_service_provider.dart';
import 'log_meal_page.dart';
import 'edit_meal_log_page.dart';

class MealLoggingPage extends ConsumerStatefulWidget {
  const MealLoggingPage({super.key});

  @override
  ConsumerState<MealLoggingPage> createState() => _MealLoggingPageState();
}

class _MealLoggingPageState extends ConsumerState<MealLoggingPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Check if there's a target date from navigation provider (when meal logged from meal plan)
    final targetDate = ref.read(targetMealDateProvider);
    if (targetDate != null) {
      _selectedDate = targetDate;
      print('[meal_logging_page initState] Using target date from navigation: ${_selectedDate.toString().split(' ')[0]}');
      // Clear the target date after using it (delayed to avoid provider modification during build)
      Future.microtask(() {
        ref.read(targetMealDateProvider.notifier).clearTargetDate();
      });
    } else {
      _selectedDate = DateTime.now();
      print('[meal_logging_page initState] Using today\'s date: ${_selectedDate.toString().split(' ')[0]}');
    }
    
    // Initialize meal logs from backend on first load (only if local state is empty)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final notifier = ref.read(mealLogsProvider.notifier);
      final currentLogs = ref.read(mealLogsProvider);
      
      // Only fetch from backend if local state is empty
      if (currentLogs.isEmpty) {
        try {
          final service = ref.read(mealLogServiceProvider);
          final logs = await service.getAllMealLogs();
          
          if (mounted) {
            notifier.setMealLogs(logs);
          }
        } catch (e) {
          print('Error initializing meal logs: $e');
        }
      }
      
      // Set selected date to latest meal date if meals exist (most recent first) - but only if we didn't set a target date
      if (ref.read(targetMealDateProvider) == null) {
        final logs = ref.read(mealLogsProvider);
        if (logs.isNotEmpty) {
          logs.sort((a, b) => b.loggedAt.compareTo(a.loggedAt)); // Sort descending - most recent first
          final latestMealDate = logs.first.loggedAt;
          setState(() {
            _selectedDate = DateTime(
              latestMealDate.year,
              latestMealDate.month,
              latestMealDate.day,
            );
          });
          print('[meal_logging_page initState] Set selected date to latest meal: ${_selectedDate.toString().split(' ')[0]}');
        }
      }
    });

    // Listen to mealLogsProvider changes and auto-adjust date if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.listen(mealLogsProvider, (previous, next) {
        if (!mounted) return;
        
        print('[meal_logging_page] Logs changed - previous: ${previous?.length ?? 0}, next: ${next.length}');
        
        // If we have logs but selected date has no meals, auto-adjust to latest
        if (next.isNotEmpty) {
          final selectedDateLogs =
              next.where((log) {
                return log.loggedAt.year == _selectedDate.year &&
                    log.loggedAt.month == _selectedDate.month &&
                    log.loggedAt.day == _selectedDate.day;
              }).toList();

          if (selectedDateLogs.isEmpty) {
            // No meals for current selected date, auto-jump to latest meal date
            final sortedLogs = List<MealLog>.from(next);
            sortedLogs.sort((a, b) => b.loggedAt.compareTo(a.loggedAt)); // Most recent first
            
            final latestMealDate = sortedLogs.first.loggedAt;
            setState(() {
              _selectedDate = DateTime(
                latestMealDate.year,
                latestMealDate.month,
                latestMealDate.day,
              );
            });
            print('[meal_logging_page listener] Auto-adjusted date to latest: ${_selectedDate.toString().split(' ')[0]}');
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch mealLogsProvider to rebuild when meals change
    final allLogs = ref.watch(mealLogsProvider);

    print('[meal_logging_page] All logs count: ${allLogs.length}');
    for (final log in allLogs) {
      print('[meal_logging_page] Log - ID: ${log.id}, name: ${log.mealName}, loggedAt: ${log.loggedAt}, mealType: ${log.mealType}');
    }

    // Compute selected date logs based on watched all logs
    final selectedDateLogs =
        allLogs.where((log) {
          final matches = log.loggedAt.year == _selectedDate.year &&
              log.loggedAt.month == _selectedDate.month &&
              log.loggedAt.day == _selectedDate.day;
          
          if (!matches) {
            print('[meal_logging_page] Date mismatch - log date: ${log.loggedAt}, selected: $_selectedDate, log year/month/day: ${log.loggedAt.year}/${log.loggedAt.month}/${log.loggedAt.day} vs ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}');
          }
          
          return matches;
        }).toList();

    print('[meal_logging_page] Selected date "${_selectedDate.toString().split(' ')[0]}" has ${selectedDateLogs.length} meals');

    // Compute daily totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final log in selectedDateLogs) {
      totalCalories += log.calories;
      totalProtein += log.protein;
      totalCarbs += log.carbs;
      totalFats += log.fats;
    }

    final dailyTotals = {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        title: const Text(
          'Meal Log',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogMealPage()),
          );
        },
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Navigation
            _buildDateNavigation(context),

            // Daily Summary Card
            _buildDailySummaryCard(context, dailyTotals),

            // Meal Type Sections
            _buildMealSection(
              context,
              ref,
              'Breakfast',
              Icons.breakfast_dining,
              selectedDateLogs,
            ),
            _buildMealSection(
              context,
              ref,
              'Lunch',
              Icons.lunch_dining,
              selectedDateLogs,
            ),
            _buildMealSection(
              context,
              ref,
              'Dinner',
              Icons.dinner_dining,
              selectedDateLogs,
            ),
            _buildMealSection(
              context,
              ref,
              'Snack',
              Icons.fastfood,
              selectedDateLogs,
            ),

            // Empty state if no meals logged
            if (selectedDateLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No meals logged yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to log your first meal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard(
      BuildContext context, Map<String, double> totals) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Intake',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutrientBadge(
                'Calories',
                '${totals['calories']!.toStringAsFixed(0)} kcal',
                Colors.white,
              ),
              _buildNutrientBadge(
                'Protein',
                '${totals['protein']!.toStringAsFixed(1)}g',
                Colors.white,
              ),
              _buildNutrientBadge(
                'Carbs',
                '${totals['carbs']!.toStringAsFixed(1)}g',
                Colors.white,
              ),
              _buildNutrientBadge(
                'Fats',
                '${totals['fats']!.toStringAsFixed(1)}g',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBadge(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    WidgetRef ref,
    String mealType,
    IconData icon,
    List<MealLog> allLogs,
  ) {
    final mealLogs =
        allLogs.where((log) => log.mealType.toLowerCase() == mealType.toLowerCase()).toList();

    if (mealLogs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFF9800), size: 20),
                const SizedBox(width: 8),
                Text(
                  mealType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const Spacer(),
                Text(
                  '0 kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'No ${mealType.toLowerCase()} logged',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF9800), size: 20),
              const SizedBox(width: 8),
              Text(
                mealType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              Text(
                '${mealLogs.fold<double>(0, (sum, log) => sum + log.calories).toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (int i = 0; i < mealLogs.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i < mealLogs.length - 1 ? 12 : 0,
                  ),
                  child: _buildMealItem(context, ref, mealLogs[i]),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMealItem(
    BuildContext context,
    WidgetRef ref,
    MealLog mealLog,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealLog.mealName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mealLog.quantity} ${mealLog.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${mealLog.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildMicroBadge('P', mealLog.protein),
                  const SizedBox(width: 8),
                  _buildMicroBadge('C', mealLog.carbs),
                  const SizedBox(width: 8),
                  _buildMicroBadge('F', mealLog.fats),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    color: const Color(0xFFFF9800),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditMealLogPage(mealLog: mealLog),
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.red,
                    onPressed: () {
                      _showDeleteConfirmation(context, ref, mealLog.id);
                    },
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicroBadge(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}g',
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String mealLogId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Log'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog
              Navigator.pop(context);

              // Delete from local state immediately
              ref.read(mealLogsProvider.notifier).deleteMealLog(mealLogId);

              // Show deleting message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deleting meal...'),
                  duration: Duration(seconds: 1),
                ),
              );

              // Delete from backend asynchronously
              Future.microtask(() async {
                try {
                  final service = ref.read(mealLogServiceProvider);
                  await service.deleteMealLog(mealLogId);

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meal deleted successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Rollback: Re-add to local state on error
                  // (Note: We don't have the full meal data, but we deleted it from UI)
                  print('Error deleting from backend: $e');
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting meal: ${e.toString()}'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Date navigation widget
  Widget _buildDateNavigation(BuildContext context) {
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Previous day button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 1));
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Icon(
                    Icons.chevron_left,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Date display
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatDateHeader(_selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateSubheader(_selectedDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next day button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for header (e.g., "Today" or "Mar 14")
  String _formatDateHeader(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}';
    }
  }

  /// Format date for subheader (e.g., "Saturday, 2026")
  String _formatDateSubheader(DateTime date) {
    final dayName = _getDayName(date.weekday);
    return '$dayName, ${date.year}';
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  /// Get month name from month number
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  /// Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9800),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D2D2D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/grocery_list_provider.dart';
import '../../domain/grocery_models.dart';
import '../../../../core/utils/notification_service.dart';

class GroceriesPage extends ConsumerWidget {
  const GroceriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groceryState = ref.watch(groceryListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        title: const Text(
          'Grocery List',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (groceryState.items.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D)),
              onSelected: (value) async {
                if (value == 'clear_purchased') {
                  await ref.read(groceryListProvider.notifier).clearPurchased();
                  if (context.mounted) {
                    NotificationService.showSuccess(
                      context,
                      message: 'Cleared purchased items',
                    );
                  }
                } else if (value == 'clear_all') {
                  final confirm = await NotificationService.showConfirmation(
                    context,
                    title: 'Clear All Items?',
                    message:
                        'This will remove all items from your grocery list.',
                    confirmText: 'Clear All',
                    cancelText: 'Cancel',
                    isDangerous: true,
                  );

                  if (confirm && context.mounted) {
                    await ref.read(groceryListProvider.notifier).clearAll();
                    if (context.mounted) {
                      NotificationService.showSuccess(
                        context,
                        message: 'Cleared all items',
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_purchased',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Clear Purchased'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: groceryState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)),
            )
          : groceryState.items.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFFFF9800),
                  onRefresh: () async {
                    await ref.read(groceryListProvider.notifier).refresh();
                  },
                  child: Column(
                    children: [
                      // Stats card
                      _buildStatsCard(groceryState.stats),
                      // List
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Pending items
                            if (groceryState.pendingItems.isNotEmpty) ...[
                              _buildSectionHeader(
                                'To Buy',
                                groceryState.pendingItems.length,
                              ),
                              const SizedBox(height: 12),
                              ...groceryState.pendingItems.map(
                                (item) => _buildGroceryItem(context, ref, item),
                              ),
                            ],

                            // Purchased items
                            if (groceryState.purchasedItems.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildSectionHeader(
                                'Purchased',
                                groceryState.purchasedItems.length,
                              ),
                              const SizedBox(height: 12),
                              ...groceryState.purchasedItems.map(
                                (item) => _buildGroceryItem(context, ref, item),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No items in your grocery list',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add ingredients from recipes to start shopping',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(GroceryStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total',
                stats.totalItems.toString(),
                Icons.shopping_cart,
                const Color(0xFF2D2D2D),
              ),
              _buildStatItem(
                'To Buy',
                stats.pendingItems.toString(),
                Icons.list_alt,
                const Color(0xFFFF9800),
              ),
              _buildStatItem(
                'Purchased',
                stats.purchasedItems.toString(),
                Icons.check_circle,
                const Color(0xFF51CF66),
              ),
            ],
          ),
          if (stats.totalItems > 0) ...[
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stats.completionPercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF51CF66),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${stats.completionPercentage.toStringAsFixed(0)}% Complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroceryItem(
    BuildContext context,
    WidgetRef ref,
    GroceryItem item,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(groceryListProvider.notifier).removeItem(item.id);
        NotificationService.showToast(
          context,
          message: '${item.name} removed',
          type: ToastType.info,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isPurchased
                ? const Color(0xFF51CF66).withValues(alpha: 0.3)
                : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref.read(groceryListProvider.notifier).togglePurchased(item.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: item.isPurchased,
                    onChanged: (value) {
                      ref
                          .read(groceryListProvider.notifier)
                          .togglePurchased(item.id);
                    },
                    activeColor: const Color(0xFF51CF66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                            decoration: item.isPurchased
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              item.displayQuantity,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.recipeName != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'from ${item.recipeName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () {
                      ref
                          .read(groceryListProvider.notifier)
                          .removeItem(item.id);
                      NotificationService.showToast(
                        context,
                        message: '${item.name} removed',
                        type: ToastType.info,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

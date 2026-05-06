import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../screens/transaction_detail_screen.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  static const Map<String, Map<String, dynamic>> _categoryMeta = {
    'Food':          {'icon': Icons.restaurant_rounded,       'color': Color(0xFFFF9500)},
    'Travel':        {'icon': Icons.directions_bus_rounded,    'color': Color(0xFF007AFF)},
    'Shopping':      {'icon': Icons.shopping_bag_rounded,      'color': Color(0xFFAF52DE)},
    'Bills':         {'icon': Icons.receipt_long_rounded,      'color': Color(0xFFFF3B30)},
    'Entertainment': {'icon': Icons.movie_filter_rounded,      'color': Color(0xFFFF2D55)},
    'Salary':        {'icon': Icons.work_rounded,              'color': Color(0xFF34C759)},
    'Freelance':     {'icon': Icons.laptop_mac_rounded,        'color': Color(0xFF5AC8FA)},
    'Gift':          {'icon': Icons.card_giftcard_rounded,     'color': Color(0xFFFF2D55)},
    'Investment':    {'icon': Icons.trending_up_rounded,       'color': Color(0xFF00D2A0)},
    'Other':         {'icon': Icons.category_rounded,          'color': Color(0xFF8E8E93)},
  };

  Map<String, dynamic> _getCategoryStyle(String category) {
    return _categoryMeta[category] ?? _categoryMeta['Other']!;
  }

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(transaction.category);
    final Color catColor = style['color'] as Color;
    final IconData catIcon = style['icon'] as IconData;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountColor = transaction.isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 420),
                reverseTransitionDuration: const Duration(milliseconds: 320),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TransactionDetailScreen(transaction: transaction),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.88, end: 1.0)
                          .animate(curved),
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          splashColor: catColor.withOpacity(0.06),
          highlightColor: catColor.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(catIcon, color: catColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Title + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('MMM dd, yyyy').format(transaction.date),
                        style: GoogleFonts.inter(
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount + category badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.isIncome ? '+' : '−'}${StorageService.getCurrencySymbol()}${transaction.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        transaction.category,
                        style: GoogleFonts.inter(
                          color: catColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

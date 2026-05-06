import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/animated_card.dart';
import '../widgets/empty_state.dart';
import '../services/filter_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'add_income_screen.dart';
import 'add_expense_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  DateTimeRange? _customRange;

  final List<String> _categories = ['All', 'Food', 'Travel', 'Shopping', 'Bills', 'Entertainment', 'Other'];

  TimeFilter _stringToFilter(String val) =>
      TimeFilter.values.firstWhere((e) => e.name == val, orElse: () => TimeFilter.month);

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      StorageService.setTimeFilter(TimeFilter.custom.name);
      setState(() => _customRange = DateTimeRange(start: picked.start, end: picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = Hive.box<Transaction>('transactions');

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF4F6FF),
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF4F6FF),
        leading: IconButton(
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: isDark ? Colors.white : const Color(0xFF374151)),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Transactions', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3)),
      ),
      body: ValueListenableBuilder(
        valueListenable: StorageService.getSettingsListenable(),
        builder: (context, settingsBox, _) {
          final timeFilter = _stringToFilter(StorageService.getTimeFilter());
          return Column(
            children: [
              // ── FILTERS ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _timeChip('Today', TimeFilter.today, timeFilter),
                          _timeChip('This Week', TimeFilter.week, timeFilter),
                          _timeChip('This Month', TimeFilter.month, timeFilter),
                          const SizedBox(width: 4),
                          _customRangeChip(timeFilter),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            onSelected: (s) { if (s) setState(() => _selectedCategory = cat); },
                            selectedColor: AppTheme.primaryColor,
                            labelStyle: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: _selectedCategory == cat ? Colors.white : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── LIST ──────────────────────────────────────────────────────
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, Box<Transaction> box, _) {
                    var txns = FilterService.filterTransactions(
                      transactions: box.values.toList(),
                      filter: timeFilter,
                      customRange: _customRange,
                    ).reversed.toList();

                    if (_searchQuery.isNotEmpty) {
                      txns = txns.where((t) => t.title.toLowerCase().contains(_searchQuery)).toList();
                    }
                    if (_selectedCategory != 'All') {
                      txns = txns.where((t) => t.category == _selectedCategory).toList();
                    }

                    if (txns.isEmpty) {
                      return const EmptyState(message: 'No transactions found.', icon: Icons.search_off_rounded);
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: txns.length,
                      itemBuilder: (context, index) {
                        final tx = txns[index];
                        return AnimatedCard(
                          index: index,
                          child: Dismissible(
                            key: Key(tx.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFF3B5C), Color(0xFFFF5C7C)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                            ),
                            onDismissed: (_) => tx.delete(),
                            child: TransactionTile(transaction: tx, onDelete: () => tx.delete()),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add_rounded,
        activeIcon: Icons.close_rounded,
        spacing: 14,
        spaceBetweenChildren: 10,
        renderOverlay: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.55,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.remove_rounded),
            backgroundColor: AppTheme.expenseColor,
            foregroundColor: Colors.white,
            label: 'Add Expense',
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_rounded),
            backgroundColor: AppTheme.incomeColor,
            foregroundColor: Colors.white,
            label: 'Add Income',
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddIncomeScreen())),
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String label, TimeFilter filter, TimeFilter current) {
    final isSelected = current == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (s) {
          if (s) {
            StorageService.setTimeFilter(filter.name);
            if (filter != TimeFilter.custom) setState(() => _customRange = null);
          }
        },
        selectedColor: AppTheme.primaryColor,
        labelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _customRangeChip(TimeFilter current) {
    final isSelected = current == TimeFilter.custom;
    return ActionChip(
      label: Text(isSelected && _customRange != null ? 'Custom Range' : 'Select Range',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface)),
      avatar: Icon(Icons.calendar_month_rounded, size: 16,
          color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface),
      onPressed: _selectCustomRange,
      backgroundColor: isSelected
          ? AppTheme.primaryColor.withOpacity(0.12)
          : Theme.of(context).chipTheme.backgroundColor,
      side: isSelected
          ? BorderSide(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.5)
          : const BorderSide(color: Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

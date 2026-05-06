import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_dialog.dart';
import '../widgets/animated_card.dart';
import '../widgets/empty_state.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'add_income_screen.dart';
import 'add_expense_screen.dart';
import 'insights_screen.dart';
import 'transactions_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool _isDarkMode;
  final VoidCallback _onThemeChanged;

  const DashboardScreen({
    super.key,
    required bool isDarkMode,
    required VoidCallback onThemeChanged,
  })  : _isDarkMode = isDarkMode,
        _onThemeChanged = onThemeChanged;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Box<Transaction> _transactionBox;

  @override
  void initState() {
    super.initState();
    _transactionBox = Hive.box<Transaction>('transactions');
  }

  double get _totalIncome => _transactionBox.values
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpenses => _transactionBox.values
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalBalance => _totalIncome - _totalExpenses;

  double get _monthlyExpenses {
    final now = DateTime.now();
    return _transactionBox.values
        .where((t) =>
            !t.isIncome &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 21 || hour < 5) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _greetingWithEmoji {
    final hour = DateTime.now().hour;
    if (hour >= 21 || hour < 5) return 'Good night 🌙';
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤';
    return 'Good evening 🌆';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget._isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBg : const Color(0xFFF4F6FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  // Settings button
                  _buildIconButton(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          isDarkMode: widget._isDarkMode,
                          onThemeChanged: widget._onThemeChanged,
                        ),
                      ));
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greetingWithEmoji,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          'My Wallet',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Theme toggle
                  _buildIconButton(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    onTap: widget._onThemeChanged,
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE CONTENT ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: ValueListenableBuilder(
                        valueListenable: _transactionBox.listenable(),
                        builder: (context, box, _) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const InsightsScreen(),
                              ));
                            },
                            child: Hero(
                              tag: 'balance_card',
                              child: BalanceCard(
                                balance: _totalBalance,
                                income: _totalIncome,
                                expense: _totalExpenses,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Budget Card (always visible — shows prompt if not set)
                    ValueListenableBuilder(
                      valueListenable: StorageService.getSettingsListenable(),
                      builder: (context, box, _) {
                        final budget = StorageService.getBudget();
                        return ValueListenableBuilder(
                          valueListenable: _transactionBox.listenable(),
                          builder: (context, txBox, _) {
                            return AnimatedCard(
                              index: 1,
                              child: BudgetCard(
                                budget: budget,
                                spent: _monthlyExpenses,
                                onTap: () async {
                                  await BudgetDialog.show(
                                    context,
                                    currentBudget: budget,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── RECENT TRANSACTIONS SECTION ────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionsScreen(),
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'See All →',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Transaction list
                    ValueListenableBuilder(
                      valueListenable: _transactionBox.listenable(),
                      builder: (context, Box<Transaction> box, _) {
                        final int length = box.length;
                        final List<Transaction> transactions = [];
                        for (int i = length - 1;
                            i >= 0 && transactions.length < 10;
                            i--) {
                          final tx = box.getAt(i);
                          if (tx != null) transactions.add(tx);
                        }

                        if (transactions.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: EmptyState(
                              message:
                                  'No transactions yet.\nStart adding your expenses!',
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return AnimatedCard(
                              index: index,
                              child: TransactionTile(
                                transaction: transaction,
                                onDelete: () => transaction.delete(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context),
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    final isDark = widget._isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isDark
              ? const Color(0xFF9CA3AF)
              : const Color(0xFF374151),
        ),
      ),
    );
  }

  SpeedDial _buildSpeedDial(BuildContext context) {
    return SpeedDial(
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
      iconTheme: const IconThemeData(size: 26),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.remove_rounded),
          backgroundColor: AppTheme.expenseColor,
          foregroundColor: Colors.white,
          label: 'Add Expense',
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ));
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.add_rounded),
          backgroundColor: AppTheme.incomeColor,
          foregroundColor: Colors.white,
          label: 'Add Income',
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddIncomeScreen(),
            ));
          },
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/filter_service.dart';
import '../services/storage_service.dart';
import '../widgets/animated_card.dart';
import '../widgets/empty_state.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  bool _isPieChart = true;
  DateTimeRange? _customRange;
  int? _touchedIndex;

  late AnimationController _pieAnimController;
  late Animation<double> _pieAnimation;

  static const Map<String, Map<String, dynamic>> _catMeta = {
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

  Color _catColor(String cat) =>
      (_catMeta[cat]?['color'] as Color?) ?? const Color(0xFF8E8E93);
  IconData _catIcon(String cat) =>
      (_catMeta[cat]?['icon'] as IconData?) ?? Icons.category_rounded;

  TimeFilter _stringToFilter(String val) =>
      TimeFilter.values.firstWhere((e) => e.name == val, orElse: () => TimeFilter.month);

  @override
  void initState() {
    super.initState();
    _pieAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pieAnimation = CurvedAnimation(
      parent: _pieAnimController,
      curve: Curves.easeOutCubic,
    );
    _pieAnimController.forward();
  }

  @override
  void dispose() {
    _pieAnimController.dispose();
    super.dispose();
  }



  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
        context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) {
      StorageService.setTimeFilter(TimeFilter.custom.name);
      setState(() {
        _customRange = DateTimeRange(start: picked.start, end: picked.end);
        _touchedIndex = null;
      });
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
        title: Text('Insights', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPieChart = !_isPieChart;
                  _touchedIndex = null;
                });
                if (_isPieChart) {
                  _pieAnimController.reset();
                  _pieAnimController.forward();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_isPieChart ? Icons.bar_chart_rounded : Icons.pie_chart_rounded, color: AppTheme.primaryColor, size: 16),
                  const SizedBox(width: 5),
                  Text(_isPieChart ? 'Bar' : 'Pie',
                      style: GoogleFonts.inter(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: StorageService.getSettingsListenable(),
        builder: (context, settingsBox, _) {
          final timeFilter = _stringToFilter(StorageService.getTimeFilter());
          return Column(
            children: [
              // Time filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(children: [
                    _timeChip('Today', TimeFilter.today, timeFilter),
                    _timeChip('Week', TimeFilter.week, timeFilter),
                    _timeChip('Month', TimeFilter.month, timeFilter),
                    const SizedBox(width: 4),
                    _customRangeChip(timeFilter),
                  ]),
                ),
              ),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, Box<Transaction> box, _) {
                    var txns = FilterService.filterTransactions(
                      transactions: box.values.toList(),
                      filter: timeFilter,
                      customRange: _customRange,
                    );
                    final expenses = txns.where((t) => !t.isIncome).toList();

                    if (expenses.isEmpty) {
                      return const EmptyState(message: 'No expense data\nfor this period.', icon: Icons.pie_chart_outline_rounded);
                    }

                    final Map<String, double> catData = {};
                    for (var tx in expenses) {
                      catData[tx.category] = (catData[tx.category] ?? 0) + tx.amount;
                    }
                    final totalExpense = expenses.fold(0.0, (s, t) => s + t.amount);
                    final maxExpense = expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

                    // Get sorted category keys for consistent indexing
                    final sortedCats = catData.keys.toList()
                      ..sort((a, b) => catData[b]!.compareTo(catData[a]!));
                    final topCategory = sortedCats.first;

                    // Get transactions for selected category
                    final String? selectedCat = (_touchedIndex != null && _touchedIndex! < sortedCats.length)
                        ? sortedCats[_touchedIndex!]
                        : null;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.6,
                            children: [
                              AnimatedCard(index: 0, child: _statCard('Total Spend', '${StorageService.getCurrencySymbol()}${totalExpense.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, AppTheme.primaryColor, isDark)),
                              AnimatedCard(index: 0, child: _statCard('Top Category', topCategory, Icons.category_rounded, _catColor(topCategory), isDark)),
                              AnimatedCard(index: 0, child: _statCard('Highest', '${StorageService.getCurrencySymbol()}${maxExpense.toStringAsFixed(0)}', Icons.trending_up_rounded, const Color(0xFFFF9500), isDark)),
                              AnimatedCard(index: 0, child: _statCard('Transactions', '${expenses.length}', Icons.list_alt_rounded, const Color(0xFFAF52DE), isDark)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Chart card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isPieChart ? 'Spending by Category' : 'Category Comparison',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3),
                                ),
                                if (_isPieChart && selectedCat != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap again to deselect',
                                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF)),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: _isPieChart
                                      ? _buildAnimatedPieChart(catData, totalExpense, sortedCats)
                                      : _buildBarChart(catData),
                                ),
                                const SizedBox(height: 20),
                                _buildLegend(catData, sortedCats),
                              ],
                            ),
                          ),

                          // Category breakdown list (always visible)
                          const SizedBox(height: 20),
                          _buildCategoryBreakdown(
                            sortedCats, catData, expenses, totalExpense, selectedCat, isDark,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF))),
          Text(value, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildAnimatedPieChart(Map<String, double> data, double total, List<String> sortedCats) {
    return RotationTransition(
      turns: Tween(begin: -0.5, end: 0.0).animate(_pieAnimation),
      child: FadeTransition(
        opacity: _pieAnimation,
        child: SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (event is! FlTapUpEvent) return;
                  if (pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }
                  final idx = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  if (idx < 0) return;
                  setState(() {
                    _touchedIndex = (_touchedIndex == idx) ? null : idx;
                  });
                },
              ),
              sections: _buildPieSections(data, total, sortedCats),
              centerSpaceRadius: 44,
              sectionsSpace: 3,
              startDegreeOffset: -90,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<String, double> data, double total, List<String> sortedCats) {
    return List.generate(sortedCats.length, (i) {
      final cat = sortedCats[i];
      final value = data[cat]!;
      final isTouched = i == _touchedIndex;
      final pct = (value / total * 100);

      return PieChartSectionData(
        color: _catColor(cat).withOpacity(isTouched ? 1.0 : 0.85),
        value: value,
        title: _pieAnimation.value > 0.6 ? '${pct.toStringAsFixed(0)}%' : '',
        radius: isTouched ? 75 : 60,
        titleStyle: GoogleFonts.inter(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        borderSide: isTouched
            ? BorderSide(color: _catColor(cat), width: 2)
            : BorderSide.none,
        titlePositionPercentageOffset: 0.55,
      );
    });
  }

  Widget _buildBarChart(Map<String, double> data) {
    return SizedBox(
      height: 210,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.values.isEmpty ? 10 : data.values.reduce((a, b) => a > b ? a : b) * 1.3,
        barGroups: data.entries.toList().asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: e.value,
              gradient: LinearGradient(
                colors: [_catColor(e.key).withOpacity(0.7), _catColor(e.key)],
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
              ),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ]);
        }).toList(),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }

  Widget _buildLegend(Map<String, double> data, List<String> sortedCats) {
    return Wrap(
      spacing: 12, runSpacing: 8,
      children: sortedCats.map((cat) {
        final isTouched = _touchedIndex != null && sortedCats[_touchedIndex!] == cat;
        return GestureDetector(
          onTap: () {
            final idx = sortedCats.indexOf(cat);
            setState(() {
              _touchedIndex = (_touchedIndex == idx) ? null : idx;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isTouched ? 10 : 0,
              vertical: isTouched ? 4 : 0,
            ),
            decoration: BoxDecoration(
              color: isTouched ? _catColor(cat).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: _catColor(cat), shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(cat, style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isTouched ? FontWeight.w700 : FontWeight.w500,
                  color: isTouched ? _catColor(cat) : const Color(0xFF6B7280),
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Shows all categories grouped, or filtered to one when a pie slice is tapped
  Widget _buildCategoryBreakdown(
    List<String> sortedCats,
    Map<String, double> catData,
    List<Transaction> expenses,
    double total,
    String? selectedCat,
    bool isDark,
  ) {
    final catsToShow = selectedCat != null ? [selectedCat] : sortedCats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              selectedCat != null ? '$selectedCat Transactions' : 'All Expenses by Category',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3),
            ),
            const Spacer(),
            if (selectedCat != null)
              GestureDetector(
                onTap: () => setState(() => _touchedIndex = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Show All',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        ...catsToShow.map((cat) {
          final color = _catColor(cat);
          final icon = _catIcon(cat);
          final catTotal = catData[cat]!;
          final pct = (catTotal / total * 100).toStringAsFixed(1);
          final txns = expenses.where((t) => t.category == cat).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: selectedCat == cat
                      ? color.withOpacity(0.4)
                      : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  width: selectedCat == cat ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat, style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 15, color: color,
                            )),
                            Text('$pct% • ${txns.length} transaction${txns.length != 1 ? 's' : ''}',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${StorageService.getCurrencySymbol()}${catTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800, fontSize: 16, color: color, letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  const SizedBox(height: 8),
                  ...txns.map((tx) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.title, style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(
                                DateFormat('MMM dd, yyyy').format(tx.date),
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '−${StorageService.getCurrencySymbol()}${tx.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 14,
                            color: AppTheme.expenseColor,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        }),
      ],
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
            setState(() {
              if (filter != TimeFilter.custom) _customRange = null;
              _touchedIndex = null;
              _pieAnimController.reset();
              _pieAnimController.forward();
            });
          }
        },
        selectedColor: AppTheme.primaryColor,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _customRangeChip(TimeFilter current) {
    final isSelected = current == TimeFilter.custom;
    return ActionChip(
      label: Text(isSelected && _customRange != null ? 'Range Selected' : 'Select Range',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface)),
      avatar: Icon(Icons.calendar_month_rounded, size: 16,
          color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface),
      onPressed: _selectCustomRange,
      backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.12) : Theme.of(context).chipTheme.backgroundColor,
      side: isSelected
          ? BorderSide(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.5)
          : const BorderSide(color: Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}



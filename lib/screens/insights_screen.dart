import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isPieChart = true;
  DateTimeRange? _customRange;

  static const Map<String, Color> _catColors = {
    'Food':          Color(0xFFFF9500),
    'Travel':        Color(0xFF007AFF),
    'Shopping':      Color(0xFFAF52DE),
    'Bills':         Color(0xFFFF3B30),
    'Entertainment': Color(0xFFFF2D55),
    'Salary':        Color(0xFF34C759),
    'Freelance':     Color(0xFF5AC8FA),
    'Gift':          Color(0xFFFF2D55),
    'Investment':    Color(0xFF00D2A0),
    'Other':         Color(0xFF8E8E93),
  };

  Color _catColor(String cat) => _catColors[cat] ?? const Color(0xFF8E8E93);

  TimeFilter _stringToFilter(String val) =>
      TimeFilter.values.firstWhere((e) => e.name == val, orElse: () => TimeFilter.month);

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
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
        title: Text('Insights', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => _isPieChart = !_isPieChart),
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
                    final avgDaily = totalExpense / 30;
                    final maxExpense = expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

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
                              AnimatedCard(index: 0, child: _statCard('Total Spend', '\$${totalExpense.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, AppTheme.primaryColor, isDark)),
                              AnimatedCard(index: 0, child: _statCard('Daily Avg', '\$${avgDaily.toStringAsFixed(0)}', Icons.calendar_today_rounded, AppTheme.incomeColor, isDark)),
                              AnimatedCard(index: 0, child: _statCard('Highest', '\$${maxExpense.toStringAsFixed(0)}', Icons.trending_up_rounded, const Color(0xFFFF9500), isDark)),
                              AnimatedCard(index: 0, child: _statCard('Count', '${expenses.length} txns', Icons.list_alt_rounded, const Color(0xFFAF52DE), isDark)),
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
                                const SizedBox(height: 20),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: _isPieChart
                                      ? _buildPieChart(catData, totalExpense)
                                      : _buildBarChart(catData),
                                ),
                                const SizedBox(height: 20),
                                _buildLegend(catData),
                              ],
                            ),
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

  Widget _buildPieChart(Map<String, double> data, double total) {
    return SizedBox(
      height: 210,
      child: PieChart(PieChartData(
        sections: data.entries.map((e) => PieChartSectionData(
          color: _catColor(e.key),
          value: e.value,
          title: '${(e.value / total * 100).toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        )).toList(),
        centerSpaceRadius: 48,
        sectionsSpace: 3,
      )),
    );
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

  Widget _buildLegend(Map<String, double> data) {
    return Wrap(
      spacing: 12, runSpacing: 8,
      children: data.keys.map((cat) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: _catColor(cat), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(cat, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))),
        ],
      )).toList(),
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

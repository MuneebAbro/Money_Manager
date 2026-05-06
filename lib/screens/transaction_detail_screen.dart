import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _isIncome;

  static const List<Map<String, dynamic>> _expenseCategories = [
    {'label': 'Food', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFFF9500)},
    {'label': 'Travel', 'icon': Icons.directions_bus_rounded, 'color': Color(0xFF007AFF)},
    {'label': 'Shopping', 'icon': Icons.shopping_bag_rounded, 'color': Color(0xFFAF52DE)},
    {'label': 'Bills', 'icon': Icons.receipt_long_rounded, 'color': Color(0xFFFF3B30)},
    {'label': 'Entertainment', 'icon': Icons.movie_filter_rounded, 'color': Color(0xFFFF2D55)},
    {'label': 'Other', 'icon': Icons.category_rounded, 'color': Color(0xFF8E8E93)},
  ];

  static const List<Map<String, dynamic>> _incomeCategories = [
    {'label': 'Salary', 'icon': Icons.work_rounded, 'color': Color(0xFF34C759)},
    {'label': 'Freelance', 'icon': Icons.laptop_mac_rounded, 'color': Color(0xFF5AC8FA)},
    {'label': 'Gift', 'icon': Icons.card_giftcard_rounded, 'color': Color(0xFFFF2D55)},
    {'label': 'Investment', 'icon': Icons.trending_up_rounded, 'color': Color(0xFF00D2A0)},
    {'label': 'Other', 'icon': Icons.category_rounded, 'color': Color(0xFF8E8E93)},
  ];

  List<Map<String, dynamic>> get _categories =>
      _isIncome ? _incomeCategories : _expenseCategories;

  Map<String, dynamic> _getCategoryStyle(String category) {
    final all = [..._expenseCategories, ..._incomeCategories];
    return all.firstWhere(
      (c) => c['label'] == category,
      orElse: () => _expenseCategories.last,
    );
  }

  @override
  void initState() {
    super.initState();
    _isIncome = widget.transaction.isIncome;
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
        text: widget.transaction.amount.toStringAsFixed(2));
    _selectedDate = widget.transaction.date;
    _selectedCategory = widget.transaction.category;

    // Ensure valid category
    final validLabels = _categories.map((c) => c['label'] as String).toList();
    if (!validLabels.contains(_selectedCategory)) {
      _selectedCategory = validLabels.first;
    }

    // Staggered animations for 6 items: header, title, amount, category, date, buttons
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(6, (i) {
      final start = (i * 0.1).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnims = List.generate(6, (i) {
      final start = (i * 0.1).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    // Start animation after page transition begins
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((d) {
      if (d != null) setState(() => _selectedDate = d);
    });
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;
    final box = Hive.box<Transaction>('transactions');
    final key = widget.transaction.key;
    final updated = Transaction(
      id: widget.transaction.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory,
      isIncome: _isIncome,
    );
    box.put(key, updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction updated',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteTransaction() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Transaction',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(
          'Are you sure you want to delete "${widget.transaction.title}"? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              widget.transaction.delete();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction deleted',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Delete',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catStyle = _getCategoryStyle(_selectedCategory);
    final Color accentColor = catStyle['color'] as Color;

    final List<Color> headerGradient = _isIncome
        ? const [Color(0xFF00B488), Color(0xFF00D2A0)]
        : [accentColor, accentColor.withOpacity(0.75)];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF4F6FF),
      body: Column(
        children: [
          // ── ANIMATED HEADER ──────────────────────────────────────────
          _buildAnimatedItem(
            index: 0,
            child: _buildHeader(isDark, headerGradient, accentColor),
          ),

          // ── FORM CONTENT ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    _buildAnimatedItem(
                      index: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(_isIncome ? 'Income Source' : 'Expense Title'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Transaction name',
                              prefixIcon: Icon(Icons.edit_note_rounded),
                            ),
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter a title'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Amount field
                    _buildAnimatedItem(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Amount'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              prefixIcon: Icon(Icons.attach_money_rounded),
                            ),
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Please enter an amount';
                              if (double.tryParse(v) == null)
                                return 'Please enter a valid number';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category selector
                    _buildAnimatedItem(
                      index: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Category'),
                          const SizedBox(height: 12),
                          _buildCategorySelector(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Date picker
                    _buildAnimatedItem(
                      index: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Date'),
                          const SizedBox(height: 8),
                          _buildDatePicker(isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Buttons
                    _buildAnimatedItem(
                      index: 5,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saveChanges,
                              icon: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 20),
                              label: Text('Save Changes',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isIncome
                                    ? AppTheme.incomeColor
                                    : AppTheme.primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _deleteTransaction,
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppTheme.expenseColor, size: 20),
                              label: Text('Delete Transaction',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.expenseColor)),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(
                                    color: AppTheme.expenseColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return SlideTransition(
      position: _slideAnims[index],
      child: FadeTransition(
        opacity: _fadeAnims[index],
        child: child,
      ),
    );
  }

  Widget _buildHeader(
      bool isDark, List<Color> gradient, Color accentColor) {
    final catStyle = _getCategoryStyle(widget.transaction.category);
    final IconData catIcon = catStyle['icon'] as IconData;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: back + delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: _deleteTransaction,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Icon + info
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(catIcon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Transaction',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isIncome ? 'Income' : 'Expense',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(widget.transaction.date),
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Big amount
              Text(
                '${_isIncome ? '+' : '−'}${StorageService.getCurrencySymbol()}${widget.transaction.amount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
          letterSpacing: 0.3,
        ),
      );

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['label'];
        final Color color = cat['color'] as Color;
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedCategory = cat['label'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.25),
                  width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat['icon'] as IconData,
                    size: 16, color: isSelected ? Colors.white : color),
                const SizedBox(width: 6),
                Text(cat['label'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
      onTap: _presentDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : const Color(0xFFF0F2FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: Color(0xFF6B7280), size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

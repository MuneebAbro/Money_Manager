import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Food',          'icon': Icons.restaurant_rounded,    'color': const Color(0xFFFF9500)},
    {'label': 'Travel',        'icon': Icons.directions_bus_rounded, 'color': const Color(0xFF007AFF)},
    {'label': 'Shopping',      'icon': Icons.shopping_bag_rounded,   'color': const Color(0xFFAF52DE)},
    {'label': 'Bills',         'icon': Icons.receipt_long_rounded,   'color': const Color(0xFFFF3B30)},
    {'label': 'Entertainment', 'icon': Icons.movie_filter_rounded,   'color': const Color(0xFFFF2D55)},
    {'label': 'Other',         'icon': Icons.category_rounded,       'color': const Color(0xFF8E8E93)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((d) { if (d != null) setState(() => _selectedDate = d); });
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    Hive.box<Transaction>('transactions').add(Transaction(
      id: const Uuid().v4(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory,
      isIncome: false,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF4F6FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Expense Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'e.g. Lunch at Chipotle', prefixIcon: Icon(Icons.edit_note_rounded)),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 20),
                    _label('Amount'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(hintText: '0.00', prefixIcon: Icon(Icons.attach_money_rounded)),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter an amount';
                        if (double.tryParse(v) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _label('Category'),
                    const SizedBox(height: 12),
                    _buildCategorySelector(),
                    const SizedBox(height: 24),
                    _label('Date'),
                    const SizedBox(height: 8),
                    _buildDatePicker(isDark),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.expenseColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text('Save Expense', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
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

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFF3B5C), Color(0xFFFF5C7C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.remove_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Add Expense', style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  Text('Track where your money goes', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                ]),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280), letterSpacing: 0.3));

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['label'];
        final Color color = cat['color'] as Color;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['label'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? color : color.withOpacity(0.25), width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(cat['label'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : color)),
            ]),
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
          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, width: 1),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded, color: Color(0xFF6B7280), size: 20),
          const SizedBox(width: 12),
          Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
        ]),
      ),
    );
  }
}

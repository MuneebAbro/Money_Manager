import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class BudgetDialog extends StatefulWidget {
  final double currentBudget;

  const BudgetDialog({super.key, required this.currentBudget});

  /// Shows the budget-setting bottom sheet and returns the new budget (or null).
  static Future<double?> show(BuildContext context, {required double currentBudget}) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetDialog(currentBudget: currentBudget),
    );
  }

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  late double _budget;
  late TextEditingController _controller;
  static const double _maxSlider = 10000;
  static const double _minSlider = 0;

  @override
  void initState() {
    super.initState();
    _budget = widget.currentBudget.clamp(_minSlider, _maxSlider);
    _controller = TextEditingController(
      text: _budget > 0 ? _budget.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _budget = value;
      _controller.text = value.toStringAsFixed(0);
    });
  }

  void _onTextChanged(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null) {
      setState(() {
        _budget = parsed.clamp(_minSlider, _maxSlider);
      });
    }
  }

  Future<void> _save() async {
    await StorageService.setBudget(_budget);
    if (mounted) Navigator.of(context).pop(_budget);
  }

  Future<void> _removeBudget() async {
    await StorageService.setBudget(0);
    if (mounted) Navigator.of(context).pop(0.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.15),
                          AppTheme.primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Budget',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Set your spending limit',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Big amount display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryColor.withOpacity(0.08)
                      : AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${StorageService.getCurrencySymbol()}${_budget.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'per month',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.12),
                      thumbColor: AppTheme.primaryColor,
                      overlayColor: AppTheme.primaryColor.withOpacity(0.12),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 3,
                      ),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _budget.clamp(_minSlider, _maxSlider),
                      min: _minSlider,
                      max: _maxSlider,
                      divisions: 200,
                      onChanged: _onSliderChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${StorageService.getCurrencySymbol()}0',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          '${StorageService.getCurrencySymbol()}10,000',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Custom text input
              Row(
                children: [
                  Text(
                    'Or enter amount:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      onChanged: _onTextChanged,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        prefixText: '${StorageService.getCurrencySymbol()} ',
                        prefixStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Action buttons
              Row(
                children: [
                  // Remove budget button (only show if budget > 0)
                  if (widget.currentBudget > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _removeBudget,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.expenseColor,
                          side: BorderSide(
                            color: AppTheme.expenseColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Remove',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  if (widget.currentBudget > 0) const SizedBox(width: 12),

                  // Save button
                  Expanded(
                    flex: widget.currentBudget > 0 ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: _budget > 0 ? _save : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Set Budget',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

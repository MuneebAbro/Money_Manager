import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _budgetController.text = StorageService.getBudget().toStringAsFixed(0);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final amount = double.tryParse(_budgetController.text) ?? 0.0;
    StorageService.setBudget(amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Budget updated to \$${amount.toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _exportCsv() async {
    try {
      final box = Hive.box<Transaction>('transactions');
      if (box.isEmpty) {
        _showSnack('No transactions to export.');
        return;
      }
      await ExportService.exportToCsv(box.values.toList());
    } catch (e) {
      _showSnack('Export failed: $e');
    }
  }

  Future<void> _exportMonthlyReport() async {
    try {
      final box = Hive.box<Transaction>('transactions');
      await ExportService.exportMonthlyReport(box.values.toList());
    } catch (e) {
      _showSnack('Report generation failed: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                color: isDark ? Colors.white : const Color(0xFF374151)),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── APPEARANCE ───────────────────────────────────────────────────
          _sectionLabel('Appearance'),
          _card(isDark, child: _themeTile(isDark)),

          const SizedBox(height: 20),

          // ── BUDGET ───────────────────────────────────────────────────────
          _sectionLabel('Monthly Budget'),
          _card(isDark, child: _budgetSection(isDark)),

          const SizedBox(height: 20),

          // ── DATA & REPORTS ────────────────────────────────────────────────
          _sectionLabel('Data & Reports'),
          _card(isDark, child: _dataSection()),
        ],
      ),
    );
  }

  // ── Appearance ────────────────────────────────────────────────────────────
  Widget _themeTile(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Dark Mode', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              Text(isDark ? 'Currently dark' : 'Currently light',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
            ]),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: (_) => widget.onThemeChanged(),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // ── Budget ────────────────────────────────────────────────────────────────
  Widget _budgetSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppTheme.incomeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.incomeColor, size: 20),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Monthly Limit', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              Text('Set to 0 to disable tracking', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
            ]),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'e.g. 1500',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Data & Reports ────────────────────────────────────────────────────────
  Widget _dataSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _exportButton(
            label: 'Export all as CSV',
            icon: Icons.file_download_outlined,
            color: AppTheme.primaryColor,
            onTap: _exportCsv,
          ),
          const SizedBox(height: 10),
          _exportButton(
            label: 'Generate Monthly Report',
            icon: Icons.summarize_outlined,
            color: AppTheme.incomeColor,
            onTap: _exportMonthlyReport,
          ),
        ],
      ),
    );
  }

  Widget _exportButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color.withOpacity(0.05),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280), letterSpacing: 0.5)),
    );
  }

  Widget _card(bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, width: 1),
      ),
      child: child,
    );
  }
}

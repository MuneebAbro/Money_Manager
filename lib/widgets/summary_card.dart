import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;

  const SummaryCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A43CC), Color(0xFF6C63FF), Color(0xFF8B74FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL BALANCE',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStat('Income', totalIncome, true)),
              Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15)),
              Expanded(child: _buildStat('Expenses', totalExpenses, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double amount, bool isIncome) {
    return Padding(
      padding: EdgeInsets.only(left: isIncome ? 0 : 16, right: isIncome ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isIncome ? const Color(0xFF00FFD1) : const Color(0xFFFF8FAB),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

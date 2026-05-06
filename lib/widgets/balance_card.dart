import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A43CC), Color(0xFF6C63FF), Color(0xFF8B74FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.40),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'TOTAL BALANCE',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Balance amount with animated counter
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: balance),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    final isNegative = value < 0;
                    return Text(
                      '${isNegative ? '-' : ''}${StorageService.getCurrencySymbol()}${value.abs().toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Divider
                Container(height: 1, color: Colors.white.withOpacity(0.15)),
                const SizedBox(height: 20),

                // Income / Expense row
                Row(
                  children: [
                    Expanded(child: _buildStat('Income', income, true)),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    Expanded(child: _buildStat('Expenses', expense, false)),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, double amount, bool isIncome) {
    return Padding(
      padding: EdgeInsets.only(
        left: isIncome ? 0 : 20,
        right: isIncome ? 20 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isIncome ? const Color(0xFF00FFD1) : const Color(0xFFFF8FAB),
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 6),
          Text(
            '${StorageService.getCurrencySymbol()}${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

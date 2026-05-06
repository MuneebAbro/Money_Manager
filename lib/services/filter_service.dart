import 'package:flutter/material.dart';
import '../models/transaction.dart';

enum TimeFilter { today, week, month, custom }

class FilterService {
  static List<Transaction> filterTransactions({
    required List<Transaction> transactions,
    required TimeFilter filter,
    DateTimeRange? customRange,
  }) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    return transactions.where((tx) {
      switch (filter) {
        case TimeFilter.today:
          return tx.date.isAfter(startOfToday.subtract(const Duration(seconds: 1)));
        
        case TimeFilter.week:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final startOfW = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          return tx.date.isAfter(startOfW.subtract(const Duration(seconds: 1)));
          
        case TimeFilter.month:
          return tx.date.month == now.month && tx.date.year == now.year;
          
        case TimeFilter.custom:
          if (customRange == null) return true;
          return tx.date.isAfter(customRange.start.subtract(const Duration(seconds: 1))) &&
                 tx.date.isBefore(customRange.end.add(const Duration(days: 1)));
      }
    }).toList();
  }
}

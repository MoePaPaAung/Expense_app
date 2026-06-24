// lib/record_model.dart
import 'package:flutter/material.dart';

class RecordItem {
  final String title;
  final String time;
  final String amount;
  final String type; // 'expense' သို့မဟုတ် 'income'
  final IconData icon;
  final Color color;

  RecordItem({
    required this.title,
    required this.time,
    required this.amount,
    required this.type,
    required this.icon,
    required this.color,
  });
}
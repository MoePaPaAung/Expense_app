import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  String name;
  IconData icon;
  Color color;
  String type; // 'expense' သို့မဟုတ် 'income' ကို သိမ်းဆည်းရန်

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}
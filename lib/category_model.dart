import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  String name;
  IconData icon;
  Color color;

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
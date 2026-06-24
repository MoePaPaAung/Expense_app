// lib/category_item.dart ဖိုင်တစ်ခုလုံးကို ဒီကုဒ်နဲ့ အစားထိုးလဲလှယ်လိုက်ပါရှင်

import 'package:flutter/material.dart';

// ၁။ Category တွေအတွက် သုံးမည့် Model
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

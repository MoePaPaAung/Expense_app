import 'package:flutter/material.dart';

class RecordItem {
  final String title;  // Category Name သိမ်းရန်
  final String note;   // အစ်မ စိတ်ကြိုက်ရိုက်ထည့်လိုက်တဲ့ Note စာသား သီးသန့်သိမ်းရန်
  final String time;   // စာရင်းသွင်းချိန် "dd/MM HH:mm:ss" ပုံစံ
  final String amount; // ငွေပမာဏ "-1,500.00" သို့မဟုတ် "+2,500.00" ပုံစံ
  final String type;   // 'expense' သို့မဟုတ် 'income'
  final IconData icon;
  final Color color;

  RecordItem({
    required this.title,
    required this.note,
    required this.time,
    required this.amount,
    required this.type,
    required this.icon,
    required this.color,
  });
}
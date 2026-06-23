import 'package:flutter/material.dart';
import 'splash_screen.dart'; // import လမ်းကြောင်းထည့်ပါ

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // ဒီနေရာမှာ SplashScreen ကို ပထမဆုံး ပွင့်မည့် Screen အဖြစ် သတ်မှတ်ပါ
    );
  }
}
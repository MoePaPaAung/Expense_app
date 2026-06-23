import 'package:flutter/material.dart';
// TODO: သင့်ရဲ့ ဖိုင်လမ်းကြောင်းအတိုင်း ဒီနေရာမှာ Import လုပ်ပေးရပါမယ်
// ဥပမာ - import 'screens/category_screen.dart';
import 'category_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense App',
      debugShowCheckedModeBanner: false, // ညာဘက်အပေါ်က Debug စာတန်းဖျောက်ရန်
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true, // ခေတ်မီတဲ့ UI ပုံစံမျိုး ရရှိစေရန်
      ),
      // ခေါ်ယူပြသမည့် စာမျက်နှာနေရာတွင် ကျွန်မတို့ရေးထားသော Screen ကို ထည့်ပေးရပါမည်
      home: const CategoryScreen(), 
    );
  }
}
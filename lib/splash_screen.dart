import 'dart:async';
import 'package:flutter/material.dart';
import 'category_screen.dart'; // Sign-in ဝင်ပြီးရင် ကူးပြောင်းမည့် Screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation ထိန်းချုပ်ရန် Controller များ
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  int _currentStage = 1; // 1: အဖြူရောင်နောက်ခံ+အတည့်၊ 2: တစ်စောင်းလည်ခြင်း၊ 3: အပြာရောင်နောက်ခံ+စာသားထွက်ခြင်း

  @override
  void initState() {
    super.initState();

    // Rotation Animation အတွက် ၁ စက္ကန့် သတ်မှတ်သည်
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // ဗီဒီယိုပါအတိုင်း ညာဘက်/ဘယ်ဘက် တစ်စောင်းလေး လည်ပတ်မည့် 45 degree (-0.785 radian) Animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: -0.785).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _executeSplashFlow();
  }

  // ဗီဒီယိုထဲက အချိန်အပိုင်းအခြား (Timing) အတိုင်း အလုပ်လုပ်မည့် Flow
  void _executeSplashFlow() async {
    // အဆင့် (၁): စစချင်း Background အဖြူရောင်နှင့် Logo အတည့်အတိုင်း ၅၀၀ မီလီစက္ကန့် စောင့်မည်
    await Future.delayed(const Duration(milliseconds: 500));

    // အဆင့် (၂): Logo လေးကို တစ်စောင်း အလှည့် Animation စတင်မည်
    if (mounted) {
      setState(() {
        _currentStage = 2;
      });
      _rotationController.forward();
    }

    // အဆင့် (၃): လည်ပြီး ၁ စက္ကန့်အကြာတွင် နောက်ခံအပြာပြောင်းပြီး၊ Logo ပြန်အတည့်ဖြစ်ကာ စာသားများပေါ်မည်
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _currentStage = 3;
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Responsive အရွယ်အစားများ တွက်ချက်ခြင်း (ဖုန်းအမျိုးအစားမရွေး ကွက်တိဖြစ်ရန်)
    double initialLogoSize = screenWidth * 0.28;
    if (initialLogoSize > 120) initialLogoSize = 120;

    double finalLogoSize = screenWidth * 0.24;
    if (finalLogoSize > 95) finalLogoSize = 95;

    double titleFontSize = screenWidth * 0.075;
    if (titleFontSize > 30) titleFontSize = 30;

    double bodyFontSize = screenWidth * 0.042;
    if (bodyFontSize > 16) bodyFontSize = 16;

    // အဆင့် (၃) သို့ရောက်ပါက အပြာရောင်နောက်ခံ၊ မရောက်ခင် (၁ နှင့် ၂) တွင် အဖြူရောင်နောက်ခံ ဖြစ်မည်
    Color backgroundColor = _currentStage == 3 ? const Color(0xFF38BDF8) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500), // နောက်ခံနှင့် UI အပြောင်းအလဲ ညင်သာစေရန်
          child: _currentStage < 3
              ? _buildSplashIntroStage(initialLogoSize) // အဆင့် ၁ နှင့် ၂ ပြသမည့် Widget
              : _buildMainSignInStage(screenWidth, screenHeight, finalLogoSize, titleFontSize, bodyFontSize), // အဆင့် ၃ ပြသမည့် Widget
        ),
      ),
    );
  }

  // --- အဆင့် (၁) နှင့် (၂): ဗဟိုတွင် Logo အတည့်မှ တစ်စောင်း လည်သွားမည့် မျက်နှာပြင် ---
  Widget _buildSplashIntroStage(double logoSize) {
    return Center(
      key: const ValueKey('IntroStage'),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value, // အဆင့် ၂ တွင် တစ်စောင်း လည်သွားမည်
            child: child,
          );
        },
        child: Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8), // ဗီဒီယိုပါအတိုင်း Logo ရဲ့ အဝိုင်းထောင့်ကွေး နောက်ခံအရောင်
            borderRadius: BorderRadius.circular(logoSize * 0.22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.savings_outlined, size: 50, color: Colors.orangeAccent);
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- အဆင့် (၃): နောက်ခံအပြာရောင်တွင် Logo ပြန်အတည့်ဖြစ်ပြီး Title နှင့် Sign-In တွဲပေါ်လာမည့် မျက်နှာပြင် ---
  Widget _buildMainSignInStage(double screenWidth, double screenHeight, double logoSize, double titleFontSize, double bodyFontSize) {
    return Padding(
      key: const ValueKey('MainStage'),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.15), // ဗီဒီယိုပါအတိုင်း အပေါ်ဘက်တွင် နေရာလွတ်ချန်ခြင်း

          // Logo နှင့် စာသား တွဲလျက် Row စနစ် (Logo က ပြန်လည် အတည့်ဖြစ်သွားသည်)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(logoSize * 0.22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.savings_outlined, size: 40, color: Colors.orangeAccent);
                    },
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04), // Logo နှင့် စာသားကြား အကွာအဝေး
              Expanded(
                child: Text(
                  "Expense Tracker",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // အလယ်မှ စိတ်ခွန်အားပေး Quote စာသား
          Text(
            "Save money! The more your money works for you, the less you have to work for money.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodyFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),

          const Spacer(flex: 2),

          // အောက်ခြေမှ Google Sign-In Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6091), // ဗီဒီယိုပါ အပြာရင့်ရောင်
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 1,
              ),
              onPressed: () {
                // ခလုတ်နှိပ်ပါက ပင်မ Category Screen သို့ ကူးပြောင်းမည်
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.g_mobiledata, color: Colors.blue, size: 22),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Sign in with google",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: bodyFontSize * 0.95,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.06), // အောက်ခြေ လွတ်စေရန် Spacer
        ],
      ),
    );
  }
}
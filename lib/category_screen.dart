import 'package:flutter/material.dart';
import 'category_model.dart';

// အဆင့် (၅) ဆင့်ကို သတ်မှတ်ပေးမယ့် အခြေအနေများ
enum CategoryState { view, calculator, deleteConfirm, add, edit }

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // လက်ရှိ ရောက်ရှိနေသော အခြေအနေကို မှတ်သားရန်
  CategoryState _currentState = CategoryState.view;

  // ပြသပေးမည့် Dynamic Category List
  final List<CategoryItem> _categories = [
    CategoryItem(id: '1', name: 'Food & Drink', icon: Icons.restaurant, color: Colors.amber),
    CategoryItem(id: '2', name: 'Shopping', icon: Icons.shopping_cart, color: Colors.indigoAccent),
    CategoryItem(id: '3', name: 'Health', icon: Icons.favorite, color: Colors.green),
    CategoryItem(id: '4', name: 'Transport', icon: Icons.directions_bus, color: Colors.redAccent),
    CategoryItem(id: '5', name: 'Interest', icon: Icons.account_balance_wallet, color: Colors.purpleAccent),
    CategoryItem(id: '6', name: 'Top Up', icon: Icons.phone_android, color: Colors.red),
  ];

  // ပုံပါအတိုင်း ရွေးချယ်နိုင်မည့် အရောင်များနှင့် အိုင်ကွန်များ စာရင်း
  final List<Color> _availableColors = [
    const Color(0xFF6366F1), Colors.greenAccent, Colors.orangeAccent,
    Colors.pinkAccent, Colors.redAccent, Colors.lightGreen, Colors.teal
  ];

  final List<IconData> _availableIcons = [
    Icons.restaurant, Icons.beach_access, Icons.moped, Icons.shopping_bag, Icons.directions_car,
    Icons.directions_bus, Icons.favorite, Icons.insert_emoticon, Icons.attach_money, Icons.account_balance,
    Icons.calendar_month, Icons.assignment, Icons.work, Icons.luggage, Icons.electric_scooter
  ];

  // ရွေးချယ်မှုနှင့် ပြင်ဆင်မှုဆိုင်ရာ Logic Variables
  CategoryItem? _selectedCategory; // Calculator ပြရန် ရွေးချယ်ထားသော ကဏ္ဍ
  CategoryItem? _itemToModify;    // Edit သို့မဟုတ် Delete လုပ်ရန် ရွေးချယ်ထားသော ကဏ္ဍ
  
  // Input Forms များအတွက် ယာယီ State များ
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  Color _tempColor = const Color(0xFF6366F1);
  IconData _tempIcon = Icons.restaurant;
  String _amount = "10000";

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Stack(
                children: [
                  // အခြေခံ ကဏ္ဍစာရင်း (အဆင့် ၁, ၂, ၃ တွင် နောက်ခံအဖြစ် အမြဲရှိနေမည်)
                  if (_currentState == CategoryState.view || 
                      _currentState == CategoryState.calculator || 
                      _currentState == CategoryState.deleteConfirm)
                    _buildCategoryList(),

                  // အဆင့် (၂) Calculator Grid တက်လာခြင်း
                  if (_currentState == CategoryState.calculator)
                    _buildCalculatorSection(),

                  // အဆင့် (၃) Alert Box အဖျက်မေးခွန်း ပေါ်လာခြင်း
                  if (_currentState == CategoryState.deleteConfirm)
                    _buildDeleteAlertBox(),

                  // အဆင့် (၄) Category အသစ်ထည့်ခြင်း မျက်နှာပြင်
                  if (_currentState == CategoryState.add)
                    _buildAddCategoryView(),

                  // အဆင့် (၅) လက်ရှိ Category ကို ပြန်ပြင်ခြင်း မျက်နှာပြင်
                  if (_currentState == CategoryState.edit)
                    _buildEditCategoryView(),
                ],
              ),
            ),
            // Navigation Bar ကို View စာမျက်နှာများတွင်သာ ပြသရန်
            if (_currentState == CategoryState.view || _currentState == CategoryState.deleteConfirm)
              _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // --- ၁။ ခေါင်းစီးပိုင်း (App Bar Widget) ---
  Widget _buildAppBar() {
    String title = "Select Category";
    if (_currentState == CategoryState.add) title = "Add Category";
    if (_currentState == CategoryState.edit) title = "Edit Category";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => setState(() => _currentState = CategoryState.view),
          ),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            onPressed: () => setState(() {
              _selectedCategory = null;
              _currentState = CategoryState.view;
            }),
          ),
        ],
      ),
    );
  }

  // --- ၂။ ကဏ္ဍစာရင်းပြသခြင်း (Category List View) ---
  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: _categories.length + 1, // +1 က Add New Category Button အတွက်
      itemBuilder: (context, index) {
        if (index == _categories.length) {
          // Add New Category ခလုတ်
          return ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 36.0),
              child: Icon(Icons.add, color: Colors.grey),
            ),
            title: const Text("Add New Category", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            onTap: () => setState(() {
              _nameController.clear();
              _tempColor = _availableColors.first;
              _tempIcon = _availableIcons.first;
              _currentState = CategoryState.add;
            }),
          );
        }

        final item = _categories[index];
        bool isSelected = _selectedCategory?.id == item.id;

        return ListTile(
          onTap: () => setState(() {
            _selectedCategory = item; // ရွေးချယ်လိုက်သော ကဏ္ဍကို မှတ်သားသည်
            _currentState = CategoryState.calculator; // Calculator ပြသည်
          }),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ဖျက်ရန် အနုတ်လက္ခဏာဝိုင်းလေး (🔴)
              GestureDetector(
                onTap: () => setState(() {
                  _itemToModify = item;
                  _currentState = CategoryState.deleteConfirm;
                }),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 1.5)),
                  child: const Icon(Icons.remove, size: 12, color: Colors.redAccent),
                ),
              ),
              const SizedBox(width: 16),
              // ကဏ္ဍ အိုင်ကွန် (ရွေးချယ်ထားလျှင် အမဲရောင်အဝိုင်းလိုင်း ဖြစ်သွားမည်)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent, 
                    width: 2.5
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: item.color,
                  child: Icon(item.icon, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
            onPressed: () => setState(() {
              _itemToModify = item;
              _nameController.text = item.name;
              _tempColor = item.color;
              _tempIcon = item.icon;
              _currentState = CategoryState.edit; // Edit မျက်နှာပြင်သို့ သွားမည်
            }),
          ),
        );
      },
    );
  }

  // --- ၃။ အဆင့် (၂) Calculator Widget ---
  Widget _buildCalculatorSection() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: const Color(0xFFE5E7EB), // Grey background
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.assignment_outlined, color: Colors.black54),
                Text(_amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Note: Enter a note ......",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 12),
            _buildCalculatorKeys(),
          ],
        ),
      ),
    );
  }

  // --- ၄။ အဆင့် (၃) အဖျက်မေးခွန်း Alert Box ---
  Widget _buildDeleteAlertBox() {
    return Container(
      color: Colors.black26, // Background ဝါးပစ်ရန်
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Are you sure you want to delete?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => setState(() => _currentState = CategoryState.view),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _categories.removeWhere((element) => element.id == _itemToModify?.id);
                    _selectedCategory = null;
                    _currentState = CategoryState.view; // ဖျက်ပြီးလျှင် မူလစာမျက်နှာသို့ပြန်သွားရန်
                  }),
                  child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- ၅။ အဆင့် (၄) Category အသစ်ထည့်ခြင်း Form ---
  Widget _buildAddCategoryView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormInputs(),
          const SizedBox(height: 20),
          const Text("Choose colour & icon", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildColorPicker(),
          const SizedBox(height: 16),
          Expanded(child: _buildIconGrid()),
          _buildSaveButton(
            label: "+ Add Category",
            onPressed: () => setState(() {
              if (_nameController.text.isNotEmpty) {
                _categories.add(CategoryItem(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  icon: _tempIcon,
                  color: _tempColor,
                ));
                _currentState = CategoryState.view;
              }
            }),
          ),
        ],
      ),
    );
  }

  // --- ၆။ အဆင့် (၅) လက်ရှိ Category ကို ပြန်ပြင်ခြင်း Form ---
  Widget _buildEditCategoryView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormInputs(),
          const SizedBox(height: 20),
          const Text("Choose colour", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildColorPicker(),
          const Spacer(), // ပြန်ပြင်သည့်နေရာတွင် Icon grid မပါသဖြင့် အောက်ခြေသို့တွန်းပို့ရန်
          _buildSaveButton(
            label: "Save",
            onPressed: () => setState(() {
              if (_nameController.text.isNotEmpty) {
                _itemToModify?.name = _nameController.text;
                _itemToModify?.color = _tempColor;
                _currentState = CategoryState.view;
              }
            }),
          ),
        ],
      ),
    );
  }

  // --- ကူညီပေးမည့် Layout အသေးစားများ (Helper Widgets) ---

  Widget _buildFormInputs() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Icon", style: TextStyle(color: Colors.grey)),
          trailing: CircleAvatar(backgroundColor: _tempColor, child: Icon(_tempIcon, color: Colors.white)),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Name", style: TextStyle(color: Colors.grey)),
          trailing: SizedBox(
            width: 180,
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                hintText: "Enter Category Name",
                border: InputBorder.none,
                suffixIcon: Icon(Icons.edit, size: 16, color: Colors.grey),
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final color = _availableColors[index];
          bool isSelected = _tempColor == color;
          return GestureDetector(
            onTap: () => setState(() => _tempColor = color),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: const Color(0xFFF472B6), width: 3) : null, // Pink border
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16),
      itemCount: _availableIcons.length,
      itemBuilder: (context, index) {
        final icon = _availableIcons[index];
        bool isSelected = _tempIcon == icon;
        return GestureDetector(
          onTap: () => setState(() => _tempIcon = icon),
          child: CircleAvatar(
            backgroundColor: isSelected ? const Color(0xFFFCE7F3) : const Color(0xFFF3F4F6),
            child: Icon(icon, color: isSelected ? const Color(0xFFDB2777) : Colors.grey[600]),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1), // Purple Indigo button color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCalculatorKeys() {
    final List<String> keys = [
      "7", "8", "9", "Today",
      "4", "5", "6", "+",
      "1", "2", "3", "×",
      ".", "0", "⌫", "✓"
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: 2.0, mainAxisSpacing: 4, crossAxisSpacing: 4
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (keys[index] == "✓") {
              setState(() => _currentState = CategoryState.view); // လုပ်ဆောင်ချက်ပြီးဆုံး၍ ပိတ်ရန်
            }
          },
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Center(
              child: Text(
                keys[index], 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: keys[index] == "✓" ? Colors.green : Colors.black
                )
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 65,
      color: const Color(0xFFE5E7EB),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.home_outlined, size: 26),
          const Icon(Icons.pie_chart_outline, size: 26),
          Transform.translate(
            offset: const Offset(0, -12),
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.blue,
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          const Icon(Icons.assignment_outlined, size: 26),
          const Icon(Icons.person_outline, size: 26),
        ],
      ),
    );
  }
}
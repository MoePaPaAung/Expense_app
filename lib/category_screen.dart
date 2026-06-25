
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'category_model.dart';
import 'record_model.dart';         
import 'record_history_screen.dart'; 

List<RecordItem> globalRecords = [];

enum CategoryState { view, calculator, deleteConfirm, add, edit, calendar }

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  CategoryState _currentState = CategoryState.view;
  int _currentTabIndex = 2; 

  final List<CategoryItem> _categories = [];
  final List<Color> _availableColors = [
    const Color(0xFF6366F1), Colors.greenAccent, Colors.orangeAccent,
    Colors.pinkAccent, Colors.redAccent, Colors.lightGreen, Colors.teal
  ];
  final List<IconData> _availableIcons = [
    Icons.restaurant, Icons.beach_access, Icons.moped, Icons.shopping_bag, Icons.directions_car,
    Icons.directions_bus, Icons.favorite, Icons.insert_emoticon, Icons.attach_money, Icons.account_balance,
    Icons.calendar_month, Icons.assignment, Icons.work, Icons.luggage, Icons.electric_scooter,
  ];
  CategoryItem? _selectedCategory;
  CategoryItem? _itemToModify;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  Color _tempColor = const Color(0xFF6366F1);
  IconData _tempIcon = Icons.restaurant;
  String _tempType = "Expense"; // Default အနေဖြင့် Expense ဟု ထားရှိခြင်း
  
  String _amount = "0.00";
  XFile? _pickedImage;
  String _calendarHeaderText = "";

  @override
  void initState() {
    super.initState();
    _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Image Source", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Take a Photo (Camera)"),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) setState(() => _pickedImage = image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) setState(() => _pickedImage = image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onKeypadPressed(String value) {
    setState(() {
      if (value == "⌫") {
        if (_amount != "0.00") {
          String digits = _amount.replaceAll('.', '');
          digits = digits.substring(0, digits.length - 1);
          if (digits.isEmpty) digits = "0";
          double amountDouble = double.parse(digits) / 100;
          _amount = amountDouble.toStringAsFixed(2);
        }
      } else if (value == "✓") {
        double parsedAmount = double.tryParse(_amount) ?? 0.0;
        if (parsedAmount > 0 && _selectedCategory != null) {
          DateTime now = DateTime.now();
          String formattedTime = DateFormat('dd/MM HH:mm:ss').format(now);
          
          String userNote = _noteController.text.trim().isNotEmpty 
              ? _noteController.text.trim() 
              : "No note";

          // Category ထဲတွင် သတ်မှတ်ခဲ့သော Type အတိုင်း လှမ်းယူစစ်ဆေးခြင်း
          String txType = _selectedCategory!.type;

          // Income ဆိုလျှင် '+' ၊ Expense ဆိုလျှင် '-' အဖြစ် လက္ခဏာတပ်ခြင်း
          String formattedAmountDisplay = txType == 'income' 
              ? "+${NumberFormat('#,##0.00').format(parsedAmount)}"
              : "-${NumberFormat('#,##0.00').format(parsedAmount)}";

          globalRecords.add(
            RecordItem(
              title: _selectedCategory!.name, 
              note: userNote,                 
              time: formattedTime,
              amount: formattedAmountDisplay,
              type: txType,
              icon: _selectedCategory!.icon,
              color: _selectedCategory!.color,
            ),
          );
        }

        _amount = "0.00";
        _noteController.clear();
        _pickedImage = null;
        _selectedCategory = null;
        _currentState = CategoryState.view;

      } else if (value == "Today") {
        DateTime now = DateTime.now();
        _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(now);
        _currentState = CategoryState.calendar; 
      } else if (int.tryParse(value) != null) {
        String digits = _amount.replaceAll('.', '');
        if (digits == "000") digits = "";
        digits += value;
        double amountDouble = double.parse(digits) / 100;
        _amount = amountDouble.toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildAppBar(), 
                Expanded(
                  child: Stack(
                    children: [
                      if (_currentState == CategoryState.view || 
                          _currentState == CategoryState.calculator || 
                          _currentState == CategoryState.deleteConfirm)
                        _buildCategoryList(),

                      if (_currentState == CategoryState.calculator)
                        _buildCalculatorSection(screenWidth),

                      if (_currentState == CategoryState.deleteConfirm)
                        _buildDeleteAlertBox(screenWidth),

                      if (_currentState == CategoryState.add)
                        _buildAddCategoryView(constraints),

                      if (_currentState == CategoryState.edit)
                        _buildEditCategoryView(constraints),

                      if (_currentState == CategoryState.calendar)
                        _buildCalendarView(screenWidth),
                    ],
                  ),
                ),
                if (_currentState == CategoryState.view ||
                    _currentState == CategoryState.deleteConfirm)
                  _buildBottomNavigationBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    if (_currentState == CategoryState.calendar) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
              onPressed: () => setState(() {
                _currentState = CategoryState.calculator; 
              }),
            ),
            const SizedBox(), 
            IconButton(
              icon: const Icon(Icons.close, size: 24, color: Colors.black),
              onPressed: () => setState(() {
                _selectedCategory = null;
                _currentState = CategoryState.view; 
              }),
            ),
          ],
        ),
      );
    }

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

  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: _categories.length + 1,
      itemBuilder: (context, index) {
        if (index == _categories.length) {
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
              _tempType = "Expense"; // Default တန်ဖိုး သတ်မှတ်ခြင်း
              _currentState = CategoryState.add;
            }),
          );
        }

        final item = _categories[index];
        bool isSelected = _selectedCategory?.id == item.id;

        return ListTile(
          onTap: () => setState(() {
            _selectedCategory = item;
            _currentState = CategoryState.calculator;
          }),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2.5),
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
          subtitle: Text(
            item.type.toUpperCase(), // Expense သို့မဟုတ် Income ပြသပေးရန်
            style: TextStyle(fontSize: 11, color: item.type == 'expense' ? Colors.grey : Colors.green, fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
            onPressed: () => setState(() {
              _itemToModify = item;
              _nameController.text = item.name;
              _tempColor = item.color;
              _tempIcon = item.icon;
              _tempType = item.type == 'expense' ? "Expense" : "Income"; // ပြင်ဆင်မည့် Type အား သိမ်းယူခြင်း
              _currentState = CategoryState.edit;
            }),
          ),
        );
      },
    );
  }

  Widget _buildCalculatorSection(double screenWidth) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: const Color(0xFFE5E7EB),
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
                suffixIcon: IconButton(
                  icon: Icon(_pickedImage != null ? Icons.check_circle : Icons.camera_alt_outlined, 
                             color: _pickedImage != null ? Colors.green : Colors.grey),
                  onPressed: _showImageSourceDialog,
                ),
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

  Widget _buildDeleteAlertBox(double screenWidth) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Container(
        width: screenWidth * 0.82,
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
                    _currentState = CategoryState.view;
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

  Widget _buildAddCategoryView(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormInputs(),
          const SizedBox(height: 16),
          const Text("Choose colour & icon", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildColorPicker(),
          const SizedBox(height: 14),
          Expanded(child: _buildIconGrid(constraints)),
          _buildSaveButton(
            label: "+ Add Category",
            onPressed: () => setState(() {
              if (_nameController.text.isNotEmpty) {
                _categories.add(CategoryItem(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  icon: _tempIcon,
                  color: _tempColor,
                  type: _tempType.toLowerCase(), // ရွေးချယ်လိုက်သော Type အား Model ထဲသို့ ထည့်သွင်းခြင်း
                ));
                _currentState = CategoryState.view;
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCategoryView(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormInputs(),
          const SizedBox(height: 16),
          const Text("Choose colour", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildColorPicker(),
          const Spacer(),
          _buildSaveButton(
            label: "Save",
            onPressed: () => setState(() {
              if (_nameController.text.isNotEmpty && _itemToModify != null) {
                int targetIndex = _categories.indexWhere((element) => element.id == _itemToModify!.id);
                
                if (targetIndex != -1) {
                  _categories[targetIndex].name = _nameController.text;
                  _categories[targetIndex].color = _tempColor;
                  _categories[targetIndex].icon = _tempIcon; 
                  _categories[targetIndex].type = _tempType.toLowerCase(); // ပြင်ဆင်လိုက်သော Type အား အစားထိုးခြင်း
                }
                
                _nameController.clear();
                _itemToModify = null;
                _currentState = CategoryState.view;
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(double screenWidth) {
    final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
    final List<String> days = [
      "31", "1", "2", "3", "4", "5", "6",
      "7", "8", "9", "10", "11", "12", "13",
      "14", "15", "16", "17", "18", "19", "20",
      "21", "22", "23", "24", "25", "26", "27",
      "28", "29", "30", "1", "2", "3", "4"
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            _calendarHeaderText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => SizedBox(
              width: screenWidth / 8,
              child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, mainAxisSpacing: 18, crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                String day = days[index];
                bool isCurrentMonth = !(index == 0 || index > 30);
                bool isSelectedDay = (day == "23" && isCurrentMonth);
                return GestureDetector(
                  onTap: () {
                    if (isCurrentMonth) {
                      setState(() {
                        _calendarHeaderText = "Tue, Jun $day, 2026";
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelectedDay ? const Color(0xFF38BDF8) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w500,
                        color: isSelectedDay ? Colors.white : (isCurrentMonth ? Colors.black : Colors.grey[400]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: _buildSaveButton(
              label: "Done", 
              onPressed: () => setState(() => _currentState = CategoryState.calculator),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormInputs() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Icon", style: TextStyle(color: Colors.grey, fontSize: 15)),
          trailing: CircleAvatar(backgroundColor: _tempColor, radius: 18, child: Icon(_tempIcon, color: Colors.white, size: 18)),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Name", style: TextStyle(color: Colors.grey, fontSize: 15)),
          trailing: SizedBox(
            width: 180,
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: "Enter Category Name",
                border: InputBorder.none,
                suffixIcon: Icon(Icons.edit, size: 14, color: Colors.grey),
              ),
            ),
          ),
        ),
        const Divider(),
        
        // --- "Screenshot 2026-06-24 122826.png" အတိုင်း Type Dropdown ဖြည့်စွက်ထည့်သွင်းခြင်း ---
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Type", style: TextStyle(color: Colors.grey, fontSize: 15)),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tempType,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _tempType = newValue;
                  });
                }
              },
              items: <String>['Expense', 'Income']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
                border: isSelected ? Border.all(color: const Color(0xFFF472B6), width: 3) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconGrid(BoxConstraints constraints) {
    int crossAxisCount = constraints.maxWidth > 600 ? 7 : 5;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, mainAxisSpacing: 14, crossAxisSpacing: 14
      ),
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
          backgroundColor: const Color(0xFF6366F1),
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
        crossAxisCount: 4, childAspectRatio: 2.1, mainAxisSpacing: 4, crossAxisSpacing: 4
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onKeypadPressed(keys[index]),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Center(
              child: Text(
                keys[index], 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: keys[index] == "✓" ? Colors.green : (keys[index] == "Today" ? Colors.blue : Colors.black)
                )
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / 5;

    final List<IconData> navIcons = [
      Icons.home_outlined, Icons.pie_chart_outline, Icons.add, Icons.assignment_outlined, Icons.person_outline,
    ];
    return Container(
      width: screenWidth,
      height: 65,
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0, right: 0, top: 0, bottom: 0,
            child: CustomPaint(
              painter: NavCurvePainter(selectedIndex: _currentTabIndex, tabWidth: tabWidth),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: (_currentTabIndex * tabWidth) + (tabWidth / 2) - 24,
            top: -15,
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF38BDF8),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Icon(navIcons[_currentTabIndex], color: Colors.black, size: 26),
            ),
          ),
          Positioned(
            left: 0, right: 0, top: 0, bottom: 0,
            child: Row(
              children: List.generate(navIcons.length, (index) {
                bool isSelected = _currentTabIndex == index;
                return SizedBox(
                  width: tabWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      if (index == 3) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RecordHistoryScreen()),
                        );
                        setState(() {
                          _currentTabIndex = 2;
                          _currentState = CategoryState.view;
                        });
                      } else {
                        setState(() {
                          _currentTabIndex = index;
                          if (index == 2) _currentState = CategoryState.view;
                        });
                      }
                    },
                    child: Center(
                      child: isSelected ? const SizedBox.shrink() : Icon(navIcons[index], size: 26, color: Colors.black54),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class NavCurvePainter extends CustomPainter {
  final int selectedIndex;
  final double tabWidth;
  NavCurvePainter({required this.selectedIndex, required this.tabWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.fill;
    final Path path = Path();
    double startingX = selectedIndex * tabWidth;

    path.moveTo(0, 0);
    path.lineTo(startingX, 0);
    path.cubicTo(
      startingX + (tabWidth * 0.15), 0,
      startingX + (tabWidth * 0.20), -22,
      startingX + (tabWidth * 0.50), -22,
    );
    path.cubicTo(
      startingX + (tabWidth * 0.80), -22,
      startingX + (tabWidth * 0.85), 0,
      startingX + tabWidth, 0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NavCurvePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.tabWidth != tabWidth;
  }
}
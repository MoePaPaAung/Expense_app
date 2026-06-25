import 'package:flutter/material.dart';
import 'record_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final RecordItem item;

  const TransactionDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isEditing = false;

  // Error ကင်းဝေးစေရန် Local variables များဖြင့် ခြေရာခံခြင်း
  late String _displayAmount;
  late String _displayNote;
  late String _currentCategoryName;
  bool _hasPhoto = true; 

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // မူလ ကနဦးတန်ဖိုးများကို Local Variable ထဲသို့ ထည့်သွင်းခြင်း
    _displayAmount = widget.item.amount;
    _displayNote = widget.item.note;
    _currentCategoryName = widget.item.title;

    // TextField များအတွက် ကိန်းဂဏန်းသန့်သန့် ထုတ်ယူခြင်း
    String rawAmount = widget.item.amount.replaceAll('+', '').replaceAll('-', '').replaceAll(',', '');
    _amountController = TextEditingController(text: rawAmount);
    _noteController = TextEditingController(text: _displayNote == "No note" ? "" : _displayNote);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpense = widget.item.type == 'expense';

    String formattedDateTime = "";
    try {
      List<String> parts = widget.item.time.split(' ');
      String datePart = parts.first; 
      String timePart = parts.length > 1 ? parts[1] : ""; 
      formattedDateTime = "$datePart/2026 \n($timePart)".trim();
    } catch (e) {
      formattedDateTime = widget.item.time;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Record Details' : 'Record Details',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ၁။ Category Row ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Category",
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.item.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.item.icon, color: widget.item.color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentCategoryName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                        ]
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.8, color: Color(0xFFF3F4F6)),

                // --- ၂။ Type Row ---
                _buildDetailRow(
                  label: "Type",
                  child: Text(
                    isExpense ? "Expense" : "Income",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isExpense ? Colors.redAccent : Colors.green),
                  ),
                ),
                const Divider(height: 24, thickness: 0.8, color: Color(0xFFF3F4F6)),

                // --- ၃။ Amount Row ---
                _buildDetailRow(
                  label: "Amount",
                  child: _isEditing
                      ? SizedBox(
                          width: 140,
                          height: 35,
                          child: TextField(
                            controller: _amountController,
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                              ),
                              suffixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 20),
                            ),
                          ),
                        )
                      : Text(
                          _displayAmount, // Local variable အားပြောင်းလဲသုံးစွဲခြင်း
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isExpense ? Colors.black87 : Colors.green),
                        ),
                ),
                const Divider(height: 24, thickness: 0.8, color: Color(0xFFF3F4F6)),

                // --- ၄။ Date Row ---
                _buildDetailRow(
                  label: "Date",
                  child: Text(
                    formattedDateTime,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const Divider(height: 24, thickness: 0.8, color: Color(0xFFF3F4F6)),

                // --- ၅။ Note Row ---
                _buildDetailRow(
                  label: "Note",
                  child: _isEditing
                      ? Expanded(
                          child: SizedBox(
                            height: 35,
                            child: TextField(
                              controller: _noteController,
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                                ),
                                suffixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 20),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Text(
                            _displayNote, // Local variable အားပြောင်းလဲသုံးစွဲခြင်း
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
                const Divider(height: 24, thickness: 0.8, color: Color(0xFFF3F4F6)),

                // --- ၆။ Photos Section ---
                const Text(
                  "Photos",
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                if (_hasPhoto)
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1608248597481-496100c8c836?q=80&w=200'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _hasPhoto = false; 
                                });
                              },
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.cancel, color: Colors.redAccent, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    ),
                    child: const Center(
                      child: Text("No photo attached", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ),

                const SizedBox(height: 30),
                _isEditing ? _buildEditModeButtons() : _buildViewModeButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // Delete Logic 
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  _isEditing = true; 
                });
              },
              child: const Text("Edit", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  // Done နှိပ်လိုက်ရင် Error မတက်စေဘဲ Local State ကို အမှန်ကန်ပြင်ဆင်ပေးမည့် Section
  Widget _buildEditModeButtons() {
    final bool isExpense = widget.item.type == 'expense';
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  // Cancel နှိပ်လျှင် မူလတန်ဖိုးများအတိုင်း ပြန်သတ်မှတ်ခြင်း
                  String rawAmount = _displayAmount.replaceAll('+', '').replaceAll('-', '').replaceAll(',', '');
                  _amountController.text = rawAmount;
                  _noteController.text = _displayNote == "No note" ? "" : _displayNote;
                  _isEditing = false;
                });
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  String prefix = isExpense ? '-' : '+';
                  String finalAmountStr = _amountController.text.trim().isEmpty ? "0.00" : _amountController.text.trim();
                  
                  // widget.item ကို တိုက်ရိုက်မပြင်တော့ဘဲ Local Variables များကို ပြင်ဆင်ခြင်းဖြင့် Error ကို ကျော်ဖြတ်ခြင်း
                  _displayAmount = "$prefix$finalAmountStr";
                  _displayNote = _noteController.text.trim().isEmpty ? "No note" : _noteController.text.trim();
                  _isEditing = false; 
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Changes saved successfully!')),
                );
              },
              child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({required String label, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        child,
      ],
    );
  }
}
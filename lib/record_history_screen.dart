// // lib/record_history_screen.dart
// import 'package:expense_app/category_model.dart';
// import 'package:expense_app/record_model.dart';

// import 'package:flutter/material.dart';
// //import 'record_model.dart';

// class RecordHistoryScreen extends StatefulWidget {
//   // ✨ CategoryScreen မှ တိုက်ရိုက်ပါလာမည့် တကယ့် Records List ကို လက်ခံပါသည်
//   final List<RecordItem> records;

//   const RecordHistoryScreen({Key? key, required this.records}) : super(key: key);

//   @override
//   State<RecordHistoryScreen> createState() => _RecordHistoryScreenState();
// }

// class _RecordHistoryScreenState extends State<RecordHistoryScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _totalIncome = 0;
//   int _totalExpense = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) setState(() {});
//     });
//     _calculateTotals();
//   }

//   // ဒေတာအစစ်အပေါ် မူတည်ပြီး ဝင်ငွေ/ထွက်ငွေ ပမာဏကို Dynamic တွက်ချက်ခြင်း
//   void _calculateTotals() {
//     int income = 0;
//     int expense = 0;

//     for (var tx in widget.records) {
//       String amountStr = tx.amount.replaceAll('-', '').replaceAll('+', '').replaceAll(',', '');
//       int amountVal = int.tryParse(amountStr) ?? 0;

//       if (tx.type == 'income') {
//         income += amountVal;
//       } else {
//         expense += amountVal;
//       }
//     }
//     _totalIncome = income;
//     _totalExpense = expense;
//   }

//   String _formatNumber(int number) {
//     if (number == 0) return '0';
//     return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Tab အလိုက် ဒေတာများကို Dynamic စစ်ထုတ်ခြင်း
//     List<RecordItem> expenseList = widget.records.where((t) => t.type == 'expense').toList();
//     List<RecordItem> incomeList = widget.records.where((t) => t.type == 'income').toList();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F4F6),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('History', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.black, size: 22),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(50),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TabBar(
//                     controller: _tabController,
//                     labelColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     indicatorColor: const Color(0xFF38BDF8),
//                     indicatorWeight: 3,
//                     tabs: const [Tab(text: 'All'), Tab(text: 'Expense'), Tab(text: 'Income')],
//                   ),
//                 ),
//                 IconButton(icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87), onPressed: () {}),
//                 IconButton(icon: const Icon(Icons.calendar_month_outlined, color: Colors.black87), onPressed: () {}),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//             // စုစုပေါင်း ကတ်ပြားအပိုင်း
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(left: 16.0, top: 16.0),
//                       child: Text('June - 2026', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
//                     ),
//                     const SizedBox(height: 12),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('Income', style: TextStyle(color: Colors.grey, fontSize: 13)),
//                               const SizedBox(height: 4),
//                               Text(_formatNumber(_totalIncome), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               const Text('Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
//                               const SizedBox(height: 4),
//                               Text(_formatNumber(_totalExpense), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
//                   ],
//                 ),
//               ),
//             ),
//             // စာရင်းများ စာမျက်နှာ
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildTransactionListView(widget.records),
//                       _buildTransactionListView(expenseList),
//                       _buildTransactionListView(incomeList),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionListView(List<RecordItem> transactions) {
//     if (transactions.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300),
//             const SizedBox(height: 12),
//             const Text("No records yet", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)),
//           ],
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       itemCount: transactions.length,
//       separatorBuilder: (context, index) => const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.0),
//         child: Divider(height: 1, thickness: 0.5, color: Color(0xFFF3F4F6)),
//       ),
//       itemBuilder: (context, index) {
//         final item = transactions[index];
//         final bool isExpense = item.type == 'expense';

//         return ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//           leading: Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
//             child: Icon(item.icon, color: Colors.white, size: 22),
//           ),
//           title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 4.0),
//             child: Text(item.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ),
//           trailing: Text(
//             item.amount,
//             style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isExpense ? Colors.black87 : Colors.green),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'category_screen.dart'; // globalRecords ကို ရယူသုံးစွဲရန် ချိတ်ဆက်ခြင်း
import 'record_model.dart';   // RecordItem ကို သုံးရန် Import လုပ်ပါ

class RecordHistoryScreen extends StatefulWidget {
  const RecordHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RecordHistoryScreen> createState() => _RecordHistoryScreenState();
}

class _RecordHistoryScreenState extends State<RecordHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); 
      }
    });
    _calculateTotals();
  }

  // --- RecordItem List မှ စုစုပေါင်းဝင်ငွေ/ထွက်ငွေများကို Dynamic တွက်ချက်ခြင်း ---
  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (var record in globalRecords) {
      // ရှေ့က + / - လက္ခဏာများနှင့် ကော်မာများကို ရှင်းလင်းပြီးမှ double ပြောင်းလဲတွက်ချက်ခြင်း
      String amountStr = record.amount.replaceAll('-', '').replaceAll('+', '').replaceAll(',', '');
      double amountVal = double.tryParse(amountStr) ?? 0.0;

      if (record.type == 'income') {
        income += amountVal;
      } else {
        expense += amountVal;
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Filter ခွဲထုတ်ခြင်း
    final expenseList = globalRecords.where((t) => t.type == 'expense').toList();
    final incomeList = globalRecords.where((t) => t.type == 'income').toList();

    // လက်ရှိ လ နှင့် ခုနှစ်ကို Dynamic ပြသခြင်း
    String currentMonthYear = DateFormat('MMMM - yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    indicatorColor: const Color(0xFF38BDF8), 
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Expense'),
                      Tab(text: 'Income'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                      child: Text(
                        currentMonthYear,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment        : CrossAxisAlignment.start,
                            children: [
                              const Text('Income', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat('#,##0.00').format(_totalIncome), 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat('#,##0.00').format(_totalExpense), 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionListView(globalRecords), 
                      _buildTransactionListView(expenseList),      
                      _buildTransactionListView(incomeList),       
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionListView(List<RecordItem> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              "No records yet",
              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              "Transactions you add will appear here.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: records.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(height: 1, thickness: 0.5, color: Color(0xFFF3F4F6)),
      ),
      itemBuilder: (context, index) {
        // အသစ်သွင်းလိုက်သော စာရင်းများ အပေါ်ဆုံးတွင် အမြဲဦးစားပေး ပေါ်နေစေရန် Reverse စနစ်ဖြင့် ပြသခြင်း
        final item = records[records.length - 1 - index];
        final bool isExpense = item.type == 'expense';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 22),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item.time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          trailing: Text(
            item.amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.black87 : Colors.green, 
            ),
          ),
        );
      },
    );
  }
}
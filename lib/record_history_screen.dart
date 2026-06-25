import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'category_screen.dart'; 
import 'record_model.dart';   
import 'transaction_detail_screen.dart'; // Detail Screen Page အား Import ပြုလုပ်ခြင်း

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

  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (var record in globalRecords) {
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
    final expenseList = globalRecords.where((t) => t.type == 'expense').toList();
    final incomeList = globalRecords.where((t) => t.type == 'income').toList();
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
        final item = records[records.length - 1 - index];
        final bool isExpense = item.type == 'expense';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          // --- တစ်ခုချင်းစီကို နှိပ်လိုက်လျှင် Page အသစ်သို့ Navigator ဖြင့် သွားခြင်း ---
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailScreen(item: item),
              ),
            );
          },
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
            item.title, // Category Name ပေါ်မည်
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
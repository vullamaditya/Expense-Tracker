
import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseTracker());
}

class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> transactions = [];

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String category = 'Food';
  String type = 'Expense';

  double get totalIncome => transactions
      .where((e) => e['type'] == 'Income')
      .fold(0.0, (sum, e) => sum + e['amount']);

  double get totalExpense => transactions
      .where((e) => e['type'] == 'Expense')
      .fold(0.0, (sum, e) => sum + e['amount']);

  double get balance => totalIncome - totalExpense;

  void addTransaction() {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() {
      transactions.add({
        'amount': amount,
        'category': category,
        'note': noteController.text.isEmpty
            ? 'No description'
            : noteController.text,
        'type': type,
        'date': DateTime.now(),
      });
    });

    amountController.clear();
    noteController.clear();
    Navigator.pop(context);
  }

  void showAddTransaction() {
    category = 'Food';
    type = 'Expense';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: 'Transaction Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Income', 'Expense'].map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => type = v);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Food',
                      'Travel',
                      'Shopping',
                      'Salary',
                      'Education',
                      'Other',
                    ].map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => category = v);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addTransaction,
                      child: const Text('Save Transaction'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openDetails(int index) {
    final item = transactions[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          item: item,
          onDelete: () {
            setState(() {
              transactions.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  Widget summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹ ${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                summaryCard('Income', totalIncome, Colors.green),
                summaryCard('Expenses', totalExpense, Colors.red),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Text('No transactions yet!'),
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final item = transactions[index];
                        final isIncome = item['type'] == 'Income';

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(item['category']),
                            subtitle: Text(item['note']),
                            trailing: Text(
                              '${isIncome ? '+' : '-'} ₹${item['amount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            onTap: () => openDetails(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;

  const DetailPage({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item['type'] == 'Income';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            Text(
              '${isIncome ? '+' : '-'} ₹${item['amount']}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 25),
            detailRow('Type', item['type']),
            detailRow('Category', item['category']),
            detailRow('Description', item['note']),
            detailRow('Date', item['date'].toString()),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
    );
  }
}

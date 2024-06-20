import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_tracker/components/transaction/render_income_expense.dart';
import 'package:finance_tracker/helpers/constants.dart';
import 'package:finance_tracker/helpers/db.dart';
import 'package:finance_tracker/helpers/transaction_helpers.dart';
import 'package:finance_tracker/screens/crud_transaction.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  void fetchTransactions() async {
    var dbHelper = DatabaseHelper();
    transactions = await dbHelper.getTransactions();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final months = getMonths();

    return DefaultTabController(
      length: months.length,
      initialIndex: months.length - 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Your Cash Tracker',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: months.map((month) {
              String monthYear = DateFormat('MMMM yyyy').format(month);
              return Tab(text: monthYear.toUpperCase());
            }).toList(),
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: months.map((month) {
            List<Transaction> monthTransactions =
                transactions.where((transaction) {
              DateTime transactionDate = DateTime.parse(transaction.date);
              return transactionDate.month == month.month &&
                  transactionDate.year == month.year;
            }).toList();

            if (monthTransactions.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions for this month',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            Map<String, List<Transaction>> groupedTransactions =
                groupTransactionsByDate(monthTransactions);

            return ListView.builder(
              itemCount: groupedTransactions.length + 1,
              padding: const EdgeInsets.only(
                top: 12,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return RenderIncomeExpense(transactions: monthTransactions);
                }

                String date = groupedTransactions.keys.elementAt(index - 1);
                List<Transaction> transactionsForDate =
                    groupedTransactions[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 12,
                          bottom: 4,
                        ),
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            DateFormat('d MMMM yyyy')
                                .format(DateTime.parse(date)),
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...transactionsForDate.map((transaction) {
                      Color color = transaction.type == incomeConstant
                          ? Colors.green
                          : Colors.red;

                      String currencySymbol = currencies.firstWhere(
                        (element) =>
                            element['currency'] == transaction.currency,
                        orElse: () => {'symbol': transaction.currency},
                      )['symbol'];

                      IconData icon = (transactionTypes.firstWhere(
                        (element) => element['name'] == transaction.type,
                      )['categories'] as List)
                          .firstWhere(
                        (element) => element['name'] == transaction.category,
                        orElse: () => {'icon': Icons.category},
                      )['icon'];

                      return ListTile(
                        leading: Icon(icon, color: color, size: 36.0),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transaction.category,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.0)),
                            if (transaction.note != '')
                              Container(
                                margin: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  transaction.note,
                                  style: const TextStyle(fontSize: 14.0),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          '$currencySymbol ${transaction.amount}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0),
                        ),
                        onTap: () {
                          debugPrint('Transaction ${transaction.id} tapped');
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => CrudTransaction(
                                transaction: transaction,
                              ),
                            ),
                          )
                              .then((_) {
                            fetchTransactions();
                          });
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            );
          }).toList(),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        GraphScreen(transactions: transactions),
                  ),
                );
              },
              child: const Icon(Icons.bar_chart),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const CrudTransaction(),
                  ),
                )
                    .then((_) {
                  fetchTransactions();
                });
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }
}

class GraphScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const GraphScreen({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphs'),
      ),
      body: Center(
        child: BarChartSample2(transactions: transactions),
      ),
    );
  }
}

class BarChartSample2 extends StatelessWidget {
  final List<Transaction> transactions;
  const BarChartSample2({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;

    // Calculate total income and total expense
    for (var transaction in transactions) {
      if (transaction.type == incomeConstant) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    double maxYValue = totalIncome > totalExpense ? totalIncome : totalExpense;
    return Container(
      width: 300,
      height: 600,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            maxY: maxYValue,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) {
                  return Colors.grey;
                },
                getTooltipItem: (a, b, c, d) => null,
              ),
              touchCallback: (FlTouchEvent event, response) {},
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return Padding(
                            padding: EdgeInsets.only(
                                top: 8), // Adjust the space as needed
                            child: Text('Income   /   Expense',
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          );
                        default:
                          return Text('');
                      }
                    }),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
                  reservedSize:
                      40, // Adjust the reserved size for Y-axis titles
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(
                    color: Colors.black, width: 1), // Show left border
                bottom: BorderSide(
                    color: Colors.black, width: 1), // Show bottom border
                top: BorderSide(
                    color: Colors.transparent, width: 0), // Hide top border
                right: BorderSide(
                    color: Colors.transparent, width: 0), // Hide right border
              ),
            ),
            barGroups: [
              makeGroupData(0, totalIncome, totalExpense),
            ],
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    ); // Added the missing closing parenthesis here
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 30,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: Colors.green,
          width: 35,
          borderRadius: BorderRadius.only(
            topLeft:
                Radius.circular(20), // Adjust the radius for rounding as needed
            topRight: Radius.circular(20),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: Colors.red,
          width: 35,
          borderRadius: BorderRadius.only(
            topLeft:
                Radius.circular(20), // Adjust the radius for rounding as needed
            topRight: Radius.circular(20),
          ),
        ),
      ],
    );
  }
}

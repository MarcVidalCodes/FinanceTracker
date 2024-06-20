import 'package:finance_tracker/helpers/constants.dart';
import 'package:finance_tracker/helpers/transaction_helpers.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/helpers/db.dart';

class RenderIncomeExpense extends StatefulWidget {
  final List<Transaction> transactions;

  const RenderIncomeExpense({super.key, required this.transactions});

  @override
  State<RenderIncomeExpense> createState() => _RenderIncomeExpenseState();
}

class _RenderIncomeExpenseState extends State<RenderIncomeExpense> {
  @override
  Widget build(BuildContext context) {
    List<CurrencyTransactions> currencyWise =
        groupTransactionsByCurrency(widget.transactions);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _buildBalanceCard(context, currencyWise),
    );
  }

  Widget _buildBalanceCard(
      BuildContext context, List<CurrencyTransactions> currencyWise) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var currency in currencyWise) {
      totalIncome +=
          currency.income.fold(0.0, (prev, element) => prev + element.amount);
      totalExpense +=
          currency.expense.fold(0.0, (prev, element) => prev + element.amount);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 1.9,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background color
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(blurRadius: 2, spreadRadius: 1)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '\$${(totalIncome - totalExpense).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceDetail(
                      context,
                      'Income',
                      '\$${totalIncome.toStringAsFixed(2)}',
                      Colors.greenAccent),
                  _buildBalanceDetail(context, 'Expenses',
                      '\$${totalExpense.toStringAsFixed(2)}', Colors.redAccent),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Marc Vidal',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1234 5678 9012 3456',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceDetail(
      BuildContext context, String label, String amount, Color color) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ExpenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense List')),
      body: ListView.builder(
        itemCount: 10, // Replace with actual data count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Expense $index'),
            subtitle: Text('Details of Expense $index'),
          );
        },
      ),
    );
  }
}

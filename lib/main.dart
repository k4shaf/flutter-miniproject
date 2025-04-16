import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    Path.join(await getDatabasesPath(), 'expenses.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, category TEXT, amount REAL, date TEXT, time TEXT, share INTEGER)',
      );
    },
    version: 1,
  );

  runApp(ExpenseLocatorApp(database: database));
}

class ExpenseLocatorApp extends StatelessWidget {
  final Future<Database> database;

  ExpenseLocatorApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            iconColor: Colors.white
          ),
        ),
      ),
      home: SplashScreen(database: database),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Future<Database> database;

  SplashScreen({required this.database});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            username: "Kashaf",
            database: widget.database,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Expense Locator',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String username;
  final Future<Database> database;

  HomeScreen({required this.username, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
              'Hello, $username, Welcome to Expense Locator!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExpenseScreen(database: database),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add Expense'),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExpenseHistoryScreen(database: database),
                  ),
                );
              },
              icon: Icon(Icons.history),
              label: Text('Expense History'),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplitExpenseScreen(),
                  ),
                );
              },
              icon: Icon(Icons.history),
              label: Text('Split Expense'),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {},
        shape: CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[200],
        child: IconTheme(
          data: IconThemeData(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildNavItem(Icons.notifications, "Reminders"),
              buildNavItem(Icons.insert_page_break_rounded, "Receipt"),
              SizedBox(width: 8),
              buildNavItem(Icons.newspaper_rounded, "Statistics"),
              buildNavItem(Icons.home, "Home"),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildNavItem(IconData icon, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min, // Prevent stretching
    children: [
      Icon(icon, color: Colors.black),
      Text(label,
          style: TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.w300)),
    ],
  );
}

class AddExpenseScreen extends StatefulWidget {
  final Future<Database> database;

  AddExpenseScreen({required this.database});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _shareExpense = false;

  List<String> categories = ['Food', 'Transport', 'Bills', 'Shopping'];

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final db = await widget.database;
      await db.insert(
        'expenses',
        {
          'title': _titleController.text,
          'category': _selectedCategory,
          'amount': double.parse(_amountController.text),
          'date': _selectedDate!.toIso8601String(),
          'time': _selectedTime!.format(context),
          'share': _shareExpense ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Expense saved successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Expense Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
                items: categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (value) => value == null ? 'Select category' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Amount Spent', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _pickDateTime,
                child: Text(_selectedDate == null || _selectedTime == null
                    ? 'Pick Date & Time'
                    : 'Picked: ${_selectedDate!.toLocal()} ${_selectedTime!.format(context)}'),
              ),
              SizedBox(height: 15),
              CheckboxListTile(
                value: _shareExpense,
                onChanged: (val) => setState(() => _shareExpense = val!),
                title: Text('Share this expense?'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseHistoryScreen extends StatefulWidget {
  final Future<Database> database;

  ExpenseHistoryScreen({required this.database});

  @override
  _ExpenseHistoryScreenState createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
    final db = await widget.database;
    return db.query('expenses');
  }

  Future<void> _deleteExpense(int id) async {
    final db = await widget.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final expenses = snapshot.data!;
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(expense['title']),
                  subtitle: Text(
                    '${expense['category']} | PKR ${expense['amount']}\n${expense['date']} at ${expense['time']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditExpenseScreen(
                                expense: expense,
                                // Pass the expense data to be edited
                                database: widget.database,
                                onUpdate: () {
                                  setState(
                                      () {}); // This will rebuild the widget and refresh the data
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteExpense(expense['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SplitExpenseScreen extends StatefulWidget {
  @override
  _SplitExpenseScreenState createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen> {
  final _amountController = TextEditingController();
  final _percentageControllerA = TextEditingController();
  final _percentageControllerB = TextEditingController();
  String result = "";

  void _equalSplit() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      final share = amount / 2;
      setState(() => result = "Each pays: PKR ${share.toStringAsFixed(2)}");
    }
  }

  void _customSplit() {
    final amount = double.tryParse(_amountController.text);
    final percentA = double.tryParse(_percentageControllerA.text);
    final percentB = double.tryParse(_percentageControllerB.text);
    if (amount != null &&
        percentA != null &&
        percentB != null &&
        percentA + percentB == 100) {
      final shareA = amount * (percentA / 100);
      final shareB = amount * (percentB / 100);
      setState(() => result =
          "User A: PKR ${shareA.toStringAsFixed(2)}, User B: PKR ${shareB.toStringAsFixed(2)}");
    } else {
      setState(() => result = "Invalid input or percentages not equal to 100");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Split Expense")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Amount'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _equalSplit,
              child: Text('Equal Split'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _percentageControllerA,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'User A %'),
            ),
            TextField(
              controller: _percentageControllerB,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'User B %'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _customSplit,
              child: Text('Custom Split'),
            ),
            SizedBox(height: 20),
            Text(result,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class EditExpenseScreen extends StatefulWidget {
  final Map<String, dynamic> expense; // The expense to be edited
  final Future<Database> database;
  final VoidCallback onUpdate;

  EditExpenseScreen(
      {required this.expense, required this.database, required this.onUpdate});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _shareExpense = false;

  List<String> categories = ['Food', 'Transport', 'Bills', 'Shopping'];

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with current expense data
    _titleController.text = widget.expense['title'];
    _amountController.text = widget.expense['amount'].toString();
    _selectedCategory = widget.expense['category'];
    _selectedDate = DateTime.parse(widget.expense['date']);
    _selectedTime =
        TimeOfDay.fromDateTime(DateTime.parse(widget.expense['date']));
    _shareExpense = widget.expense['share'] == 1;
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime!,
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _updateExpense() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final db = await widget.database;
      await db.update(
        'expenses',
        {
          'title': _titleController.text,
          'category': _selectedCategory,
          'amount': double.parse(_amountController.text),
          'date': _selectedDate!.toIso8601String(),
          'time': _selectedTime!.format(context),
          'share': _shareExpense ? 1 : 0,
        },
        where: 'id = ?', // Specify the expense ID to update
        whereArgs: [widget.expense['id']],
      );

      widget.onUpdate();
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Expense Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
                items: categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (value) => value == null ? 'Select category' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Amount Spent', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _pickDateTime,
                child: Text(_selectedDate == null || _selectedTime == null
                    ? 'Pick Date & Time'
                    : 'Picked: ${_selectedDate!.toLocal()} ${_selectedTime!.format(context)}'),
              ),
              SizedBox(height: 15),
              CheckboxListTile(
                value: _shareExpense,
                onChanged: (val) => setState(() => _shareExpense = val!),
                title: Text('Share this expense?'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateExpense,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Update Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

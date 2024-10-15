import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Calculator by Leo Magtibay';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CalculatorPage(title: appTitle),
    );
  }
}

class CalculatorPage extends StatelessWidget {
  final String title;
  const CalculatorPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                const Expanded(flex: 2, child: Calculator()),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HistoryView(),
                  ),
                ),
              ],
            );
          } else {
            return const Calculator();
          }
        },
      ),
      endDrawer: Drawer(
        child: HistoryView(),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String output = '0';
  String currentOperation = '';
  double firstOperand = 0;
  bool isNewOperation = true;
  static List<String> history = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            child: Text(
              output,
              style: const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Divider(height: 0),
        Column(
          children: [
            Row(children: [
              _calculatorButton('%'),
              _calculatorButton('sqrt()'),
              _calculatorButton('x^2'),
              _calculatorButton('1/x'),
            ]),
            Row(children: [
              _calculatorButton('CE'),
              _calculatorButton('C'),
              _calculatorButton('DEL'),
              _calculatorButton('/'),
            ]),
            Row(children: [
              _calculatorButton('7'),
              _calculatorButton('8'),
              _calculatorButton('9'),
              _calculatorButton('x'),
            ]),
            Row(children: [
              _calculatorButton('4'),
              _calculatorButton('5'),
              _calculatorButton('6'),
              _calculatorButton('-'),
            ]),
            Row(children: [
              _calculatorButton('1'),
              _calculatorButton('2'),
              _calculatorButton('3'),
              _calculatorButton('+'),
            ]),
            Row(children: [
              _calculatorButton('+/-'),
              _calculatorButton('0'),
              _calculatorButton('.'),
              _calculatorButton('='),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _calculatorButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'C':
        case 'CE':
          output = '0';
          currentOperation = '';
          firstOperand = 0;
          isNewOperation = true;
          if (buttonText == 'C') history.clear();
          break;
        case '+':
        case '-':
        case 'x':
        case '/':
          if (currentOperation.isNotEmpty) {
            _result();
          }
          firstOperand = double.parse(output);
          currentOperation = buttonText;
          isNewOperation = true;
          break;
        case '=':
          _result();
          currentOperation = '';
          break;
        case '%':
          _immediateOperation('$output%', (double.parse(output) / 100).toString());
          break;
        case 'sqrt()':
          _immediateOperation('sqrt($output)', sqrt(double.parse(output)).toString());
          break;
        case 'x^2':
          _immediateOperation('$output^2', (double.parse(output) * double.parse(output)).toString());
          break;
        case '1/x':
          _immediateOperation('1/$output', (1 / double.parse(output)).toString());
          break;
        case '+/-':
          _immediateOperation('-($output)', (double.parse(output) * -1).toString());
          break;
        case 'DEL':
          output = output.length > 1 ? output.substring(0, output.length - 1) : '0';
          break;
        default:
          if (isNewOperation) {
            output = buttonText;
            isNewOperation = false;
          } else {
            output += buttonText;
          }
      }
    });
  }

  void _immediateOperation(String operation, String result) {
    history.add('$operation = $result');
    if (history.length > 7) history.removeAt(0);
    output = result;
    isNewOperation = true;
    currentOperation = '';
  }

  void _result() {
    if (currentOperation.isEmpty) return;
    double secondOperand = double.parse(output);
    String calculation = '$firstOperand $currentOperation $secondOperand';
    switch (currentOperation) {
      case '+':
        output = (firstOperand + secondOperand).toString();
        break;
      case '-':
        output = (firstOperand - secondOperand).toString();
        break;
      case 'x':
        output = (firstOperand * secondOperand).toString();
        break;
      case '/':
        output = secondOperand != 0 ? (firstOperand / secondOperand).toString() : 'Error';
        break;
    }
    history.add('$calculation = $output');
    if (history.length > 7) history.removeAt(0);
    isNewOperation = true;
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _CalculatorState.history.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_CalculatorState.history[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
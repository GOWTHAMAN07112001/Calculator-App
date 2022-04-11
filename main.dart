import 'buttons.dart';
import 'drawer.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

String userQuestion = '';
String userAnswer = '';
String tempA = '';

double fontSize = 30;

List history = [];
List answerHistory = [];
List changeThings = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myTextStyle = TextStyle(fontSize: fontSize, color: Colors.teal[300]);

  final List<String> buttons = [
    'C',
    'DEL',
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    'ANS',
    '='
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: Text('Calculator'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      drawer: drawer(context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: EdgeInsets.all(9),
                      alignment: Alignment.centerLeft,
                      child: Text(userQuestion,
                          style: TextStyle(
                              fontSize: fontSize, color: Colors.teal[900])),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6),
                    alignment: Alignment.centerRight,
                    child: Text(
                      userAnswer,
                      style: TextStyle(
                          fontSize: fontSize, color: Colors.teal[900]),
                    ),
                  )
                ],
              ),
            ),
          ),
          GridView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: buttons.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (BuildContext context, int index) {
                // Clear Button
                if (index == 0) {
                  return MyButton(
                      buttonTapped: () {
                        tempA = userAnswer;
                        setState(() {
                          userQuestion = '';
                          userAnswer = '';
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.green,
                      textColor: Colors.white);
                }

                // Delete Button
                else if (index == 1) {
                  return MyButton(
                      buttonTapped: () {
                        setState(() {
                          userQuestion = userQuestion.substring(
                              0, userQuestion.length - 1);
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.red,
                      textColor: Colors.white);
                }

                // Equal Button
                else if (index == 19) {
                  return MyButton(
                      buttonTapped: () {
                        setState(() {
                          equalPressed();
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.teal[300],
                      textColor: Colors.white);
                }

                // ANS Button
                else if (index == 18) {
                  return MyButton(
                      buttonTapped: () {
                        if ((userQuestion.length + userAnswer.length) > 17) {
                          var temp =
                              (userQuestion.length + userAnswer.length) - 17;
                          userQuestion += tempA;
                          setState(() {
                            userQuestion = userQuestion.substring(
                                0, userQuestion.length - temp);
                          });
                        } else {
                          setState(() {
                            userQuestion += tempA;
                          });
                        }
                      },
                      buttonText: buttons[index],
                      color: Colors.teal[300],
                      textColor: Colors.white);
                }

                // Rest of the buttons
                else {
                  return MyButton(
                      buttonTapped: () {
                        if (userQuestion.length >= 17) {
                          setState(() {
                            // ignore: deprecated_member_use
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Maximum number of digits (17) exceeded.')));
                          });
                        } else {
                          setState(() {
                            userQuestion += buttons[index];
                          });
                        }
                      },
                      buttonText: buttons[index],
                      color: isOperator(buttons[index])
                          ? Colors.teal[300]
                          : Colors.teal,
                      textColor: Colors.white);
                }
              }),
        ],
      ),
    );
  }

  bool isOperator(String x) {
    if (x == '%' || x == '÷' || x == '×' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

  void equalPressed() {
    String finalQuestion = userQuestion;
    finalQuestion = finalQuestion.replaceAll('×', '*');
    finalQuestion = finalQuestion.replaceAll('%', '*0.01');
    finalQuestion = finalQuestion.replaceAll('÷', '/');

    Parser p = Parser();
    Expression exp = p.parse(finalQuestion);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);

    userAnswer = eval.toString();

    history.add(userQuestion);
    answerHistory.add(userAnswer);
  }
}

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal[100],
        appBar: AppBar(
          title: Text('History'),
          centerTitle: true,
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              tooltip: 'Delete History',
              icon: Icon(Icons.delete),
              onPressed: () {
                return showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => AlertDialog(
                          title: Text('Delete History'),
                          backgroundColor: Colors.teal[300],
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text(
                                    'Do you want to delete your history of calculations?')
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                                child: Text('Decline',
                                    style: TextStyle(color: Colors.black)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            TextButton(
                              child: Text('Approve',
                                  style: TextStyle(color: Colors.black)),
                              onPressed: () {
                                setState(() {
                                  history.clear();
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              },
            )
          ],
        ),
        drawer: drawer(context),
        body: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.teal[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title:
                          Text(history[index] + ' = ' + answerHistory[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                        setState(() {
                          userQuestion = history[index];
                          userAnswer = answerHistory[index];
                        });
                      },
                    )
                  ],
                ),
              );
            }));
  }
}

class Color extends StatefulWidget {
  @override
  _ColorState createState() => _ColorState();
}

class _ColorState extends State<Color> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Color Theme Picker'),
          centerTitle: true,
        ),
        drawer: drawer(context),
        body: ListView.builder(
            itemCount: changeThings.length,
            itemBuilder: (context, index) {
              return ListView(padding: EdgeInsets.zero, children: <Widget>[
                ListTile(
                  title: Text('Calculator Theme Picker'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Drawer Theme Picker'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('History Theme Picker'),
                  onTap: () {},
                )
              ]);
            }));
  }
}

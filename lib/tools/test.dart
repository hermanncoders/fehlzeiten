import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admonition List Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdmonitionList(),
    );
  }
}

enum AdmonitionType { red, yellow }

class Admonition {
  String date;
  String reason;
  AdmonitionType type;

  Admonition({required this.date, required this.reason, required this.type});
}

class Pupil {
  String name;
  List<Admonition> admonitions;

  Pupil({required this.name, required this.admonitions});

  bool hasAdmonitionForDate(String date) {
    return admonitions.any((a) => a.date == date);
  }

  bool hasYellowAdmonitionForDate(String date) {
    return admonitions
        .any((a) => a.date == date && a.type == AdmonitionType.yellow);
  }

  bool hasRedAdmonitionForDate(String date) {
    return admonitions
        .any((a) => a.date == date && a.type == AdmonitionType.red);
  }

  int getAdmonitionCount() {
    return admonitions.length;
  }
}

class AdmonitionList extends StatefulWidget {
  const AdmonitionList({Key? key}) : super(key: key);

  @override
  _AdmonitionListState createState() => _AdmonitionListState();
}

class _AdmonitionListState extends State<AdmonitionList> {
  String _selectedDate = "2022-03-25"; // default selected date
  final List<Pupil> pupils = [
    Pupil(
      name: "John",
      admonitions: [
        Admonition(
            date: "2022-01-01",
            reason: "Late to class",
            type: AdmonitionType.yellow),
        Admonition(
            date: "2022-01-15",
            reason: "Missing homework",
            type: AdmonitionType.yellow),
        Admonition(
            date: "2022-03-15",
            reason: "Late to class",
            type: AdmonitionType.red),
        Admonition(
            date: "2022-03-25",
            reason: "Skipping class",
            type: AdmonitionType.yellow),
      ],
    ),
    Pupil(name: "Sarah", admonitions: [
      Admonition(
          date: "2022-02-10",
          reason: "Talking in class",
          type: AdmonitionType.yellow),
    ]),
    Pupil(name: "David", admonitions: [
      Admonition(
          date: "2022-03-01",
          reason: "Cheating on exam",
          type: AdmonitionType.red),
      Admonition(
          date: "2022-03-25",
          reason: "Skipping class",
          type: AdmonitionType.yellow),
    ]),
    Pupil(name: "Emily", admonitions: [])
  ];

  @override
  Widget build(BuildContext context) {
    List<Pupil> filteredPupils =
        pupils.where((p) => p.hasAdmonitionForDate(_selectedDate)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Admonition List"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("Selected Date: $_selectedDate"),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: filteredPupils.length,
            itemBuilder: (BuildContext context, int index) {
              Pupil pupil = filteredPupils[index];
              bool hasYellowAdmonition =
                  pupil.hasYellowAdmonitionForDate(_selectedDate);
              bool hasRedAdmonition =
                  pupil.hasRedAdmonitionForDate(_selectedDate);
              int totalAdmonitions = pupil.getAdmonitionCount();
              return ListTile(
                title: Text(pupil.name),
                subtitle: pupil.getAdmonitionCount() > 0
                    ? Text('${pupil.getAdmonitionCount()} admonitions')
                    : null,
                trailing: hasRedAdmonition
                    ? Icon(Icons.rectangle_rounded, color: Colors.red)
                    : hasYellowAdmonition
                        ? Icon(Icons.rectangle_rounded, color: Colors.yellow)
                        : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdmonitionListDetail(pupil: pupil),
                    ),
                  );
                },
              );
            },
          )),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked.toIso8601String().substring(0, 10);
      });
    }
  }
}

class AdmonitionListDetail extends StatelessWidget {
  final Pupil pupil;

  const AdmonitionListDetail({Key? key, required this.pupil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pupil.name),
      ),
      body: ListView.builder(
        itemCount: pupil.admonitions.length,
        itemBuilder: (BuildContext context, int index) {
          Admonition admonition = pupil.admonitions[index];
          return ListTile(
            title: Text(admonition.reason),
            subtitle: Text(admonition.date),
            trailing: admonition.type == AdmonitionType.red
                ? Icon(Icons.rectangle_rounded, color: Colors.red)
                : Icon(Icons.rectangle_rounded, color: Colors.yellow),
          );
        },
      ),
    );
  }
}

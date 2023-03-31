// Adapted from : https://dev.to/carminezacc/user-authentication-jwt-authorization-with-flutter-and-node-176l
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'home.dart';
import '/tools/models.dart';
import '/tools/api.dart';
import '/tools/extensions.dart';
import 'hermannpupil_details.dart';
import 'login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Corona extends StatefulWidget {
  @override
  _CoronaState createState() => _CoronaState();
}

class _CoronaState extends State<Corona> {
  List<CodedNames> myCodedNames = [];
  List<CodedNames> newCodedNames = [];
  List<Hermannpupil> myhermannpupils = List.empty();
  List<Hermannpupil> filteredhermannpupils = List.empty();
  List<Hermannpupil> unexcusedhermannpupils = List.empty();
  bool isSwitched = false;
  String selectedGroup = Get.arguments;
  List<DateTime> validSchooldays = [];
  List<Coronastatus> mycoronastatus = List.empty();
  bool valuefirst = false;
  bool valuesecond = false;
  final storage = FlutterSecureStorage();
  late String username;
  TextEditingController textEditingController = TextEditingController();

  void logout() {
    storage.deleteAll();
    print('Daten gelöscht');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  getCodesToNames() async {}

  static DateTime initialDate = DateTime.now();

  static DateFormat dateFormat = new DateFormat("dd.MM.yyyy");
  String formattedDate = dateFormat.format(initialDate);

  @override
  void initState() {
    getCodestoNames();
    super.initState();
    updateSchooldays();
    updateData(selectedGroup);
  }

  Future<void> getCodestoNames() async {
    bool namesExist = await storage.containsKey(key: 'codestonames');
    if (namesExist == true) {
      String thisCodedNames = (await storage.read(key: 'codestonames'))!;
      myCodedNames = codedNamesFromJson(thisCodedNames);
      username = (await storage.read(key: 'username'))!;
    }
  }

  Future<void> updateSchooldays() async {
    await Api.getSchooldays().whenComplete(() {}).then((schooldays) {
      setState(() {
        schooldays.forEach((element) => validSchooldays.add(element.schoolday));
        final closestDateTimeToNow = validSchooldays.reduce((value, element) =>
            value.difference(initialDate).abs() <
                    element.difference(initialDate).abs()
                ? value
                : element);
        schooldays.sort((a, b) => a.schoolday.compareTo(b.schoolday));
        initialDate = closestDateTimeToNow;
      });
    });
  }

  Future<void> updateData(String group) async {
    String? defaultgroup = await storage.read(key: 'default_group');
    if (defaultgroup == null) {
      storage.write(key: "default_group", value: "A1");
    }
    await Api.getCoronastatus().whenComplete(() {}).then((coronastatus) {
      setState(() {
        mycoronastatus = coronastatus;
      });
    });
    await Api.getHermannpupils(group).whenComplete(() {}).then((hermannpupils) {
      setState(() {
        myhermannpupils = [];
        dynamic foundObject;
        myCodedNames.forEach((codedelement) {
          if (hermannpupils
              .where((element) => element.name == codedelement.code)
              .isNotEmpty)
            foundObject = hermannpupils
                .where((element) => element.name == codedelement.code)
                .first;
          foundObject.name = codedelement.name;
          myhermannpupils.add(foundObject);
        });

        myhermannpupils.sort((a, b) => a.name.compareTo(b.name));
        filteredhermannpupils = List.from(myhermannpupils);
        (isSwitched == true) && (textEditingController.text == "")
            ? _switchTrue(true)
            : isSwitched = false;
        (textEditingController.text != null) && isSwitched == false
            ? _searchFilter(textEditingController.text)
            : textEditingController.clear();
      });
    });
  }

  Future<String> _lateInMinutes(BuildContext context) async {
    final String valueText = await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _textFieldController = TextEditingController();
          String? thisvaluetext;
          return AlertDialog(
            title: Text('Verspätung eingeben'),
            content: TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  thisvaluetext = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Verspätung in Minuten"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('ABBRECHEN'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context, 'none');
                  });
                },
              ),
              TextButton(
                child: Text('WEITER'),
                onPressed: () {
                  Navigator.pop(context, thisvaluetext);
                },
              ),
            ],
          );
        });
    return valueText;
  }

  Future<void> _bulkCreateMissedDates(
      id, DateTime startdate, DateTime enddate, missedtype) async {
    final thishermannpupil =
        myhermannpupils.where((id) => myhermannpupils.contains(id)).first;
    for (DateTime validSchoolday in validSchooldays) {
      if (validSchoolday.isSameDate(startdate) ||
          dateFormat.format(validSchoolday) == dateFormat.format(enddate) ||
          (validSchoolday.isBeforeDate(enddate) &&
              validSchoolday.isAfterDate(startdate))) {
        if (thishermannpupil.pupilmissedclasses.any(
            (missedclass) => missedclass.missedSchoolday == validSchoolday)) {
          final lateAt = null;
          await Api.changeMissedType(
              thishermannpupil.id,
              DateFormat("yyyy-MM-dd").format(validSchoolday).toString(),
              missedtype,
              username,
              lateAt);
        } else {
          var lateAt;
          if (missedtype == 'late') {
            lateAt = await _lateInMinutes(context);
          } else {
            lateAt = null;
          }
          await Api.newMissedType(
              id,
              DateFormat("yyyy-MM-dd").format(validSchoolday).toString(),
              missedtype,
              username,
              lateAt,
              null,
              null);
        }
      }
    }
    await updateData(selectedGroup);
    Get.snackbar(
      "Fehlzeiten eingetragen",
      "Die Fehlzeiten wurden eingetragen",
      icon: Icon(Icons.calendar_today_rounded, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      borderRadius: 20,
      margin: EdgeInsets.all(15),
      colorText: Colors.white,
      duration: Duration(seconds: 1),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  _createDropdownValue(int index, String dropdownvalue) async {
    final DateTime today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));
    if (pickedDate == null) {
      return;
    }
    if (dropdownvalue == 'quarantine') {
      await _bulkCreateMissedDates(
          filteredhermannpupils[index].id, today, pickedDate, 'distance');
      await Api.createCoronastatus(
          filteredhermannpupils[index].id,
          DateFormat("yyyy-MM-dd").format(pickedDate).toString(),
          dropdownvalue);
      updateData(selectedGroup);
      return dropdownvalue;
    } else {
      await Api.createCoronastatus(
          filteredhermannpupils[index].id,
          DateFormat("yyyy-MM-dd").format(pickedDate).toString(),
          dropdownvalue);
      updateData(selectedGroup);
      return dropdownvalue;
    }
  }

  void _deleteCoronaStatus(int index) async {
    await Api.deleteCoronastatus(filteredhermannpupils[index].id);
    updateData(selectedGroup);
  }

  _changeDropdownValue(int index, String dropdownvalue) async {
    final nocoronastatus = 'none';

    dynamic coronastatus = mycoronastatus.indexWhere(
        (id) => id.coronapupilId == filteredhermannpupils[index].id);
    if (coronastatus < 0) {
      return nocoronastatus;
    } else {
      await Api.changeCoronastatusStatus(
          filteredhermannpupils[index].id,
          // DateFormat("yyyy-MM-dd")
          //     .format(mycoronastatus[coronastatus].untildate)
          //     .toString(),
          dropdownvalue);
      updateData(selectedGroup);

      return dropdownvalue;
    }
  }

  _changeUntilDate(int index) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));
    if (pickedDate == null) {
      return;
    }

    await Api.changeCoronastatusDate(filteredhermannpupils[index].id,
        DateFormat("yyyy-MM-dd").format(pickedDate).toString());
    updateData(selectedGroup);

    return pickedDate;
  }

  _setDropdownValue(int index, String dropdownvalue, id) {
    final nocoronastatus = 'none';

    // if (dropdownvalue == nomissedclass) {
    //   return nomissedclass;
    // }
    dynamic coronastatus = mycoronastatus.indexWhere(
        (id) => id.coronapupilId == filteredhermannpupils[index].id);

    if (coronastatus < 0) {
      return nocoronastatus;
    } else {
      final dropdownvalue = mycoronastatus[coronastatus].coronaStatus;

      return dropdownvalue;
    }
  }

  _switchTrue(value) {
    // textEditingController.clear();
    setState(() {
      filteredhermannpupils = filteredhermannpupils
          .where((u) => mycoronastatus.any((id) => (u.id == id.coronapupilId)))
          .toList();
      isSwitched = value;
    });
  }

  _searchFilter(string) {
    setState(() {
      // isSwitched = false;
      filteredhermannpupils = filteredhermannpupils
          .where((u) => u.name.toLowerCase().contains(string.toLowerCase()))
          .toList();
    });
  }

  _setUntilDateValue(int index, id) {
    final nocoronastatus = 'none';
    final thisDate = initialDate;

    // if (dropdownvalue == nomissedclass) {
    //   return nomissedclass;
    // }
    dynamic coronastatus = mycoronastatus.indexWhere(
        (id) => id.coronapupilId == filteredhermannpupils[index].id);

    if (coronastatus < 0) {
      return;
    } else {
      final DateTime untildate = mycoronastatus[coronastatus].untildate;

      return untildate;
    }
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        updateData(selectedGroup);
        break;
      case 1:
        Get.to(() => MissedClassPage(), arguments: selectedGroup);
        break;
      case 2:
        logout();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.coronavirus_rounded),
          title: InkWell(child: Text('Corona Status')),
          automaticallyImplyLeading: false,
          actions: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.white),
                textTheme: TextTheme().apply(bodyColor: Colors.white),
              ),
              child: PopupMenuButton<int>(
                color: Colors.indigo,
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.refresh_rounded),
                        const SizedBox(width: 8),
                        Text('Aktualisieren'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded),
                        const SizedBox(width: 8),
                        Text('Fehlzeiten'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        const SizedBox(width: 8),
                        Text('Ausloggen'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'Klasse:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              onTap: () {
                                FocusManager.instance.primaryFocus!.unfocus();
                              },
                              hint: Text("Gruppe"),
                              items: [
                                "A1",
                                "A2",
                                "A3",
                                "B1",
                                "B2",
                                "B3",
                                "B4",
                                "C1",
                                "C2",
                                "C3",
                                "Gesamt"
                              ].map((option) {
                                return DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: selectedGroup, //asign the selected value
                              onChanged: (value) {
                                setState(() {
                                  selectedGroup = value!;
                                  updateData(
                                      selectedGroup); //on selection, selectedDropDownValue i sUpdated
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                      Column(
                        children: [
                          Text(
                            '  Corona Status:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Switch(
                            value: isSwitched,
                            onChanged: (value) {
                              if (value == true) {
                                _switchTrue(value);
                              } else {
                                setState(() {
                                  filteredhermannpupils = myhermannpupils;
                                  isSwitched = value;
                                });
                              }
                            },
                            activeTrackColor: Colors.yellow,
                            activeColor: Colors.orangeAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textEditingController,
                          onChanged: (string) => _searchFilter(string),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.only(left: 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              labelText: 'Suche',
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ),
                      IconButton(
                          onPressed: () => {
                                textEditingController.clear(),
                                setState(() {
                                  filteredhermannpupils = myhermannpupils;
                                  isSwitched = false;
                                })
                              },
                          icon: Icon(Icons.delete))
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    // ignore: unnecessary_null_comparison
                    itemCount: null == filteredhermannpupils
                        ? 0
                        : filteredhermannpupils.length,
                    itemBuilder: (context, index) {
                      Hermannpupil hermannpupil = filteredhermannpupils[index];
                      String defaultvalue = 'none';
                      String _dropdownValue = _setDropdownValue(
                          index, defaultvalue, hermannpupil.id);

                      DateTime _untildate =
                          _setUntilDateValue(index, hermannpupil.id);
                      return Card(
                        elevation: 1.0,
                        margin: EdgeInsets.only(
                            left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15.0, left: 15.0),
                                        child: Text(hermannpupil.group +
                                            '      ID:  ' +
                                            hermannpupil.id.toString()),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, left: 15.0, bottom: 15.0),
                                        child: InkWell(
                                          onTap: () => Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                HermannpupilPage(
                                                    hermannpupil: hermannpupil),
                                          )),
                                          child: Text(
                                            hermannpupil.name,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus!
                                          .unfocus();
                                    },
                                    value: _dropdownValue,
                                    items: [
                                      DropdownMenuItem(
                                          child: Center(
                                            child: Text("keins",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                )),
                                          ),
                                          value: 'none'),
                                      DropdownMenuItem(
                                          child: Center(
                                            child: Text("Index",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.orange[900],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                )),
                                          ),
                                          value: 'index'),
                                      DropdownMenuItem(
                                          child: Center(
                                            child: Text("Kontakt",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                )),
                                          ),
                                          value: 'quarantine'),
                                    ],
                                    onChanged: (newvalue) {
                                      if (_dropdownValue == newvalue) {
                                        setState(() {
                                          _dropdownValue = newvalue!;
                                        });
                                      } else if (newvalue == 'none') {
                                        _deleteCoronaStatus(index);
                                      } else if (_dropdownValue == 'none') {
                                        _createDropdownValue(index, newvalue!);
                                      } else {
                                        _changeDropdownValue(index, newvalue!);
                                        setState(() {
                                          _dropdownValue = newvalue;
                                        });
                                      }
                                    }),
                              ),
                            ),
                            Column(
                              children: [
                                _dropdownValue == 'none'
                                    ? Container()
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            top: 5.0, right: 10.0),
                                        child: _dropdownValue == 'index'
                                            ? Text(
                                                'am:',
                                              )
                                            : Text(
                                                'bis:',
                                              )),
                                _dropdownValue == 'none'
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () => _changeUntilDate(index),
                                          child: Text(
                                              DateFormat("dd.MM.yyyy")
                                                  .format(_untildate)
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              )),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => updateData(selectedGroup),
          tooltip: 'Increment',
          child: Icon(Icons.refresh),
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigo,
        ),
      );
}

// Adapted from : https://dev.to/carminezacc/user-authentication-jwt-authorization-with-flutter-and-node-176l
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'corona.dart';
import '/tools/models.dart';
import '/tools/api.dart';
import '/tools/extensions.dart';
import 'hermannpupil_details.dart';
import 'missedclass_overview.dart';
import 'login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as enc;

class MissedClassPage extends StatefulWidget {
  @override
  _MissedClassPageState createState() => _MissedClassPageState();
}

class _MissedClassPageState extends State<MissedClassPage> {
  late String username;
  List<Hermannpupil> myhermannpupils = List<Hermannpupil>.empty(growable: true);
  List<CodedNames> myCodedNames = [];
  List<CodedNames> newCodedNames = [];
  List<String> groupDropdownList = ["Gesamt"];
  List<Hermannpupil> filteredhermannpupils = List.empty();
  List<Hermannpupil> unexcusedhermannpupils = List.empty();
  bool isSwitchedMissedUnexcused = false;
  bool isSwitchedOgs = false;
  bool isSwitchedPresence = false;
  bool isSwitchedAbsence = false;
  bool isSwitchedDistance = false;
  bool isSwitchedLateUnexcused = false;
  bool isSwitchedClass1 = true;
  bool isSwitchedClass2 = true;
  bool isSwitchedClassE3 = true;
  bool isSwitchedClass3 = true;
  bool isSwitchedClass4 = true;
  bool isSwitchedA1 = true;
  bool isSwitchedA2 = true;
  bool isSwitchedA3 = true;
  bool isSwitchedB1 = true;
  bool isSwitchedB2 = true;
  bool isSwitchedB3 = true;
  bool isSwitchedB4 = true;
  bool isSwitchedC1 = true;
  bool isSwitchedC2 = true;
  bool isSwitchedC3 = true;
  String selectedGroup = "Gesamt";

  late DateTime startDate;
  late DateTime endDate;
  late StateSetter _setState;
  late List<Schooldays> schooldays;
  List<DateTime> validSchooldays = [];
  bool valuefirst = false;
  bool valuesecond = false;
  final storage = FlutterSecureStorage();
  TextEditingController textEditingController = TextEditingController();
  FocusNode myFocusNode = FocusNode();

  void logout() {
    storage.delete(key: 'jwt');
    storage.delete(key: 'username');
    storage.delete(key: 'isAdmin');
    if (kDebugMode) {
      print('Daten gelöscht');
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void clearNames() async {
    storage.delete(key: 'codestonames');
    myCodedNames = [];
    selectedGroup = "Gesamt";
    groupDropdownList = ["Gesamt"];

    updateData(selectedGroup);
  }

  static DateTime today = DateTime.now();
  static DateTime thisDate = today;

  @override
  void initState() {
    getSecureStorageData();
    registerSchooldays();
    updateData(selectedGroup);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  Future<void> addCodedNames(List<CodedNames> newNames) async {
    newNames.forEach((element) {
      if (myCodedNames.any((codedname) => codedname.code == element.code)) {
      } else {
        myCodedNames.add(element);
      }
    });
    storage.write(key: 'codestonames', value: codedNamesToJson(myCodedNames));
    updateData(selectedGroup);
  }

  Future<void> getSecureStorageData() async {
    username = (await storage.read(key: 'username'))!;
    bool namesExist = await storage.containsKey(key: 'codestonames');
    if (namesExist == true) {
      String thisCodedNames = (await storage.read(key: 'codestonames'))!;
      myCodedNames = codedNamesFromJson(thisCodedNames);

      myCodedNames.forEach((element) {
        print('my coded names: ' + element.name);
      });
    }
  }

  Future<void> registerSchooldays() async {
    await Api.getSchooldays().then((thisscholdays) {
      setState(() {
        schooldays = List.from(thisscholdays);
      });
    });
    schooldays.forEach((element) => validSchooldays.add(element.schoolday));
    final closestDateTimeToNow = validSchooldays.reduce((value, element) =>
        value.difference(thisDate).abs() < element.difference(thisDate).abs()
            ? value
            : element);
    schooldays.sort((a, b) => a.schoolday.compareTo(b.schoolday));
    if (validSchooldays
        .any((element) => element.formatForJson() == today.formatForJson())) {
      setState(() {
        thisDate = today;
      });
    } else {
      thisDate = today;
      setState(() {
        thisDate = closestDateTimeToNow;
      });
    }
  }

  Future<void> updateData(String group) async {
    await Api.getHermannpupils(group).whenComplete(() {}).then((hermannpupils) {
      setState(() {
        myhermannpupils = [];
        dynamic foundObject;
        // look for ID correspondence of elements - if given, decode and add to hermannpupils list
        myCodedNames.forEach((codedelement) {
          if (hermannpupils
              .where((element) => element.name == codedelement.code)
              .isNotEmpty) {
            foundObject = hermannpupils
                .where((element) => element.name == codedelement.code)
                .single;
            foundObject.name = codedelement.name;
            myhermannpupils.add(foundObject);
          } else {
            // myCodedNames.remove(codedelement);
          }
        });
        storage.write(
            key: 'codestonames', value: codedNamesToJson(myCodedNames));

        myhermannpupils.forEach((element) {
          if (groupDropdownList.contains(element.group)) {
          } else {
            setState(() {
              groupDropdownList.add(element.group);
              groupDropdownList.sort((a, b) => a.compareTo(b));
            });
          }
        });

        myhermannpupils.sort((a, b) => a.name.compareTo(b.name));
        filteredhermannpupils = List.from(myhermannpupils);
      });
    });
  }

  //** SET START VALUES FOR DROPDOWN AND SWITCHES **//

  _setMissedTypeValue(int index, String dropdownvalue, DateTime date) {
    final nomissedclass = 'none';

    // if (dropdownvalue == nomissedclass) {
    //   return nomissedclass;
    // }
    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere((datematch) => datematch.missedSchoolday.isSameDate(date));

    if (missedclass < 0) {
      return nomissedclass;
    } else {
      final dropdownvalue = filteredhermannpupils[index]
          .pupilmissedclasses[missedclass]
          .missedtype;

      return dropdownvalue;
    }
  }

  _setExcusedValue(int index, DateTime date) {
    final nomissedclass = false;

    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere(
            (datematch) => (datematch.missedSchoolday.isSameDate(date)));

    if (missedclass < 0) {
      return nomissedclass;
    } else {
      final excusedindex =
          filteredhermannpupils[index].pupilmissedclasses[missedclass].excused;

      return excusedindex;
    }
  }

  bool _setContactedValue(int index, DateTime date) {
    final nomissedclass = false;
    final selecteddate = date;

    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere((datematch) =>
            (datematch.missedSchoolday.isSameDate(selecteddate)));

    if (missedclass < 0) {
      return nomissedclass;
    } else {
      final contactedindex = filteredhermannpupils[index]
          .pupilmissedclasses[missedclass]
          .contacted;

      return contactedindex;
    }
  }

  String? _setCreatedModifiedValue(int index, DateTime date) {
    final nomissedclass = null;
    final selecteddate = date;

    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere((datematch) =>
            (datematch.missedSchoolday.isSameDate(selecteddate)));

    if (missedclass < 0) {
      return nomissedclass;
    } else {
      final createdby = filteredhermannpupils[index]
          .pupilmissedclasses[missedclass]
          .createdBy;
      final modifiedby = filteredhermannpupils[index]
          .pupilmissedclasses[missedclass]
          .modifiedBy;

      if (createdby != null && modifiedby == null) {
        return createdby;
      }
      if (modifiedby != null) return modifiedby;
    }
  }

  bool? _setReturnedValue(int index, DateTime date) {
    final nomissedclass = false;
    final selecteddate = date;

    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere((datematch) =>
            (datematch.missedSchoolday.isSameDate(selecteddate)));

    if (missedclass < 0) {
      return nomissedclass;
    } else {
      final returnedindex =
          filteredhermannpupils[index].pupilmissedclasses[missedclass].returned;

      return returnedindex;
    }
  }

  //** CREATE MANY MISSED CLASSES **//

  Future<void> _bulkCreateMissedDates(
      id, startdate, enddate, missedtype) async {
    final thishermannpupil =
        myhermannpupils.where((id) => myhermannpupils.contains(id)).first;
    for (DateTime validSchoolday in validSchooldays) {
      if (validSchoolday.isSameDate(startdate) ||
          validSchoolday.isSameDate(enddate) ||
          (validSchoolday.isBeforeDate(enddate) &&
              validSchoolday.isAfterDate(startdate))) {
        if (thishermannpupil.pupilmissedclasses.any(
            (missedclass) => missedclass.missedSchoolday == validSchoolday)) {
          final lateAt = null;
          await Api.changeMissedType(thishermannpupil.id,
              validSchoolday.formatForJson(), missedtype, username, lateAt);
        } else {
          var lateAt;
          if (missedtype == 'late') {
            lateAt = await _lateInMinutes(context);
          } else {
            lateAt = null;
          }
          await Api.newMissedType(id, validSchoolday.formatForJson(),
              missedtype, username, lateAt, null, null);
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

  //** DATE PICKERS **//

  bool selectableDates(DateTime day) {
    dynamic validDate = schooldays.any((e) => validSchooldays.contains(day));
    return validDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: thisDate,
        selectableDayPredicate: selectableDates,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));
    if (pickedDate != null && pickedDate != thisDate) {
      resetSwitches();
      setState(() {
        thisDate = pickedDate;
      });
    }
  }

  Future<void> _selectDialogStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: thisDate,
        selectableDayPredicate: selectableDates,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));
    if (pickedDate != null &&
        (pickedDate.isBefore(endDate) || pickedDate == endDate))
      _setState(() {
        startDate = pickedDate;
      });
    else {
      Get.snackbar(
        "Falsche Datumeingabe",
        "Das Startdatum liegt nach dem Enddatum!",
        icon: Icon(Icons.calendar_today_rounded, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[900],
        borderRadius: 20,
        margin: EdgeInsets.all(15),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      );
    }
  }

  Future<void> _selectDialogEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: thisDate,
        selectableDayPredicate: selectableDates,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));
    if (pickedDate != null &&
        (pickedDate.isAfter(startDate) || pickedDate == endDate))
      _setState(() {
        endDate = pickedDate;
      });
    else {
      Get.snackbar(
        "Falsche Datumeingabe",
        "Das Enddatum liegt vor dem Startdatum!",
        icon: Icon(Icons.calendar_today_rounded, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[900],
        borderRadius: 20,
        margin: EdgeInsets.all(15),
        colorText: Colors.white,
        animationDuration: Duration(seconds: 1),
        duration: Duration(seconds: 1),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      );
    }
  }

  //** DIALOGUES **//

  Future<void> _longPressHermannpupil(context, thishermannpupil) async {
    return showDialog(
        context: context,
        builder: (context) {
          String _dialogdropdownValue = 'missed';
          startDate = thisDate;
          endDate = thisDate;
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return AlertDialog(
              title: Text(
                'Mehrere Einträge',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              content: Container(
                // height: 190.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        thishermannpupil.name + '  ' + thishermannpupil.group,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () => _selectDialogStartDate(context),
                          child: Text(
                            'von   ' + startDate.formatForUser(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () => _selectDialogEndDate(context),
                          child: Text(
                            'bis   ' + endDate.formatForUser(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            onTap: () {
                              FocusManager.instance.primaryFocus!.unfocus();
                            },
                            value: _dialogdropdownValue,
                            items: [
                              DropdownMenuItem(
                                  value: 'missed',
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text("F",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          )),
                                    ),
                                  )),
                              DropdownMenuItem(
                                  value: 'distance',
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: Colors.purple[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text("Q",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          )),
                                    ),
                                  )),
                            ],
                            onChanged: (newvalue) {
                              setState(() {
                                _dialogdropdownValue = newvalue!;
                              });
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('ABBRECHEN'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    _bulkCreateMissedDates(thishermannpupil.id, startDate,
                        endDate, _dialogdropdownValue);
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
        });
  }

  //**  MISSEDCLASS DROPDOWN AND SWITCHES FUNCTIONS **//
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

  _createDropdownValue(int index, String dropdownvalue, DateTime date) async {
    var lateAt;
    if (dropdownvalue == 'late') {
      lateAt = await _lateInMinutes(context);
    } else {
      lateAt = null;
    }
    await Api.newMissedType(filteredhermannpupils[index].id,
        thisDate.formatForJson(), dropdownvalue, username, lateAt, null, null);
    updateData(selectedGroup);
    return dropdownvalue;
  }

  void _deleteMissedClass(int index, DateTime date) async {
    await Api.deletePostMissedType(
        filteredhermannpupils[index].id, date.formatForJson());
    updateData(selectedGroup);
  }

  _changeDropdownValue(int index, String dropdownvalue, DateTime date) async {
    final nomissedclass = 'none';
    String? lateAt;
    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere(
            (datematch) => (datematch.missedSchoolday.isSameDate(date)));

    if (missedclass < 0) {
      return nomissedclass;
    } else {
      if (dropdownvalue == "late") {
        lateAt = await _lateInMinutes(context);
      } else {
        lateAt = null;
      }

      await Api.changeMissedType(filteredhermannpupils[index].id,
          thisDate.formatForJson(), dropdownvalue, username, lateAt);
      updateData(selectedGroup);
      return dropdownvalue;
    }
  }

  void _changeExcusedValue(int index, bool excuseswitch, DateTime date) async {
    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere(
            (datematch) => (datematch.missedSchoolday.isSameDate(date)));

    if (missedclass < 0) {
      return;
    } else {
      await Api.changeMissedStatus(
          filteredhermannpupils[index].id, date.formatForJson(), excuseswitch);
      updateData(selectedGroup);

      return;
    }
  }

  void _changeContactedValue(
      int index, bool contactedswitch, DateTime date) async {
    final selecteddate = date;

    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere((datematch) =>
            (datematch.missedSchoolday.isSameDate(selecteddate)));

    if (missedclass < 0) {
      return;
    } else {
      await Api.changeContactedStatus(filteredhermannpupils[index].id,
          thisDate.formatForJson(), contactedswitch);
      updateData(selectedGroup);

      return;
    }
  }

  _returnedDayTime(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? timeOfDay = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    return timeOfDay;
  }

  void _changeReturnedValue(
      int index, bool returnedswitch, DateTime date) async {
    final selecteddate = date;

    dynamic missedclass = filteredhermannpupils[index]
        .pupilmissedclasses
        .indexWhere((datematch) =>
            (datematch.missedSchoolday.isSameDate(selecteddate)));

    if (missedclass < 0) {
      var thisReturnTime;
      if (returnedswitch == true) {
        thisReturnTime = await _returnedDayTime(context);
        thisReturnTime = thisReturnTime.format(context);
      } else {
        thisReturnTime = null;
      }
      await Api.newMissedType(
          filteredhermannpupils[index].id,
          thisDate.formatForJson(),
          'none',
          username,
          null,
          true,
          thisReturnTime);
      updateData(selectedGroup);
    } else {
      var thisReturnTime;
      if (returnedswitch == true) {
        thisReturnTime = await _returnedDayTime(context);
        thisReturnTime = thisReturnTime.format(context);
      } else {
        thisReturnTime = null;
      }
      if (filteredhermannpupils[index]
              .pupilmissedclasses[missedclass]
              .missedtype ==
          'none') {
        await Api.deletePostMissedType(
            filteredhermannpupils[index].id, date.formatForJson());
      } else {
        await Api.changeReturnedStatus(filteredhermannpupils[index].id,
            thisDate.formatForJson(), returnedswitch, thisReturnTime);
      }

      updateData(selectedGroup);

      return;
    }
  }

  //** FILTERS **//

  void resetSwitches() {
    setState(() {
      isSwitchedMissedUnexcused = false;
      isSwitchedLateUnexcused = false;
      isSwitchedOgs = false;
      isSwitchedPresence = false;
      isSwitchedAbsence = false;
      isSwitchedDistance = false;
      isSwitchedClass1 = true;
      isSwitchedClass2 = true;
      isSwitchedClassE3 = true;
      isSwitchedClass3 = true;
      isSwitchedClass4 = true;
      isSwitchedA1 = true;
      isSwitchedA2 = true;
      isSwitchedA3 = true;
      isSwitchedB1 = true;
      isSwitchedB2 = true;
      isSwitchedB3 = true;
      isSwitchedB4 = true;
      isSwitchedC1 = true;
      isSwitchedC2 = true;
      isSwitchedC3 = true;
      filteredhermannpupils = List.from(myhermannpupils);
    });
  }

  _filterClass1(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils
          .removeWhere((element) => element.schoolyear == 'E1');

      isSwitchedClass1 = value;
    });
  }

  _filterClass2(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils
          .removeWhere((element) => element.schoolyear == 'E2');

      isSwitchedClass2 = value;
    });
  }

  _filterClassE3(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils
          .removeWhere((element) => element.schoolyear == 'E3');

      isSwitchedClassE3 = value;
    });
  }

  _filterClass3(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils
          .removeWhere((element) => element.schoolyear == 'S3');

      isSwitchedClass3 = value;
    });
  }

  _filterClass4(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils
          .removeWhere((element) => element.schoolyear == 'S4');

      isSwitchedClass4 = value;
    });
  }

  _filterA1(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'A1');

      isSwitchedA1 = value;
    });
  }

  _filterA2(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'A2');

      isSwitchedA2 = value;
    });
  }

  _filterA3(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'A3');

      isSwitchedA3 = value;
    });
  }

  _filterB1(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'B1');

      isSwitchedB1 = value;
    });
  }

  _filterB2(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'B2');

      isSwitchedB2 = value;
    });
  }

  _filterB3(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'B3');

      isSwitchedB3 = value;
    });
  }

  _filterB4(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'B4');

      isSwitchedB4 = value;
    });
  }

  _filterC1(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'C1');

      isSwitchedC1 = value;
    });
  }

  _filterC2(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'C2');

      isSwitchedC2 = value;
    });
  }

  _filterC3(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((element) => element.group == 'C3');

      isSwitchedC3 = value;
    });
  }

  _filterLateUnexcused(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils = filteredhermannpupils
          .where((u) => u.pupilmissedclasses.any((missedclass) =>
              (missedclass.missedSchoolday.isSameDate(thisDate) &&
                  missedclass.excused == true &&
                  missedclass.missedtype == 'late')))
          .toList();
      isSwitchedLateUnexcused = value;
    });
  }

  _filterGroup(value) {
    textEditingController.clear();

    if (value == "Gesamt") {
      filteredhermannpupils = List.from(myhermannpupils);
    } else {
      setState(() {
        filteredhermannpupils =
            myhermannpupils.where((u) => u.group == value).toList();
      });
    }
  }

  _filterMissedUnexcused(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils = filteredhermannpupils
          .where((u) => u.pupilmissedclasses.any((missedclass) =>
              (missedclass.missedSchoolday.isSameDate(thisDate) &&
                  missedclass.excused == true &&
                  missedclass.missedtype == 'missed')))
          .toList();
      isSwitchedMissedUnexcused = value;
    });
  }

  _filterDistance(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils = filteredhermannpupils
          .where((u) => u.pupilmissedclasses.any((missedclass) =>
              (missedclass.missedSchoolday.isSameDate(thisDate) &&
                  missedclass.missedtype == 'distance')))
          .toList();
      isSwitchedDistance = value;
    });
  }

  _filterOgs(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils =
          filteredhermannpupils.where((u) => u.ogs == true).toList();
      isSwitchedOgs = value;
    });
  }

  _filterPresent(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((u) => u.pupilmissedclasses.any(
          (missedclass) => (missedclass.missedSchoolday.isSameDate(thisDate) &&
              (missedclass.missedtype == "distance" ||
                  missedclass.missedtype == "missed" ||
                  missedclass.returned == true))));

      isSwitchedPresence = value;
    });
  }

  _filterAbsent(value) {
    textEditingController.clear();
    setState(() {
      filteredhermannpupils.removeWhere((u) => u.pupilmissedclasses.every(
          (missedclass) => (!missedclass.missedSchoolday.isSameDate(thisDate) ||
              (missedclass.missedSchoolday.isSameDate(thisDate) &&
                  missedclass.missedtype == "late"))));

      isSwitchedAbsence = value;
    });
  }

  _filterTextfield(string) {
    setState(() {
      filteredhermannpupils = filteredhermannpupils
          .where((u) => u.name.toLowerCase().contains(string.toLowerCase()))
          .toList();
    });
  }

  void addNewGroup() async {
    newCodedNames = await Get.to(() => QRScanPupilCodes());
    addCodedNames(newCodedNames);
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        addNewGroup();
        break;
      case 1:
        Get.to(() => MissedClassOverview(), arguments: selectedGroup);
        break;
      case 2:
        Get.to(() => Corona(), arguments: selectedGroup);
        break;
      case 3:
        logout();
        break;
      case 4:
        clearNames();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () => _selectDate(context),
          ),
          title: InkWell(
              onTap: () => _selectDate(context),
              child: Text(
                  DateFormat('EEEE', Localizations.localeOf(context).toString())
                          .format(thisDate) +
                      ', ' +
                      thisDate.formatForUser())),
          automaticallyImplyLeading: false,
          actions: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                textTheme: const TextTheme().apply(bodyColor: Colors.white),
              ),
              child: PopupMenuButton<int>(
                color: Color.fromARGB(255, 237, 115, 115),
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.qr_code_scanner_rounded),
                        SizedBox(width: 8),
                        Text('Gruppe hinzufügen'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(Icons.coronavirus_rounded),
                        SizedBox(width: 8),
                        Text('Zahlenübersicht'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: const [
                        Icon(Icons.coronavirus_rounded),
                        SizedBox(width: 8),
                        Text('Corona'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<int>(
                    value: 3,
                    child: Row(
                      children: const [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Ausloggen'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 4,
                    child: Row(
                      children: const [
                        Icon(Icons.delete_forever_rounded),
                        SizedBox(width: 8),
                        Text('Gruppen löschen'),
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
                ExpansionTile(
                  title: const Text(
                    'FILTER',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            children: const [
                              Text(
                                '  OGS',
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
                                value: isSwitchedOgs,
                                onChanged: (value) {
                                  if (value == true) {
                                    _filterOgs(value);
                                  } else {
                                    resetSwitches();
                                  }
                                },
                                activeTrackColor: Colors.yellow,
                                activeColor: Colors.orangeAccent,
                              ),
                            ],
                          ),
                          Column(
                            children: const [
                              Text(
                                '  FU',
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
                                value: isSwitchedMissedUnexcused,
                                onChanged: (value) {
                                  if (value == true) {
                                    _filterMissedUnexcused(value);
                                  } else {
                                    resetSwitches();
                                  }
                                },
                                activeTrackColor: Colors.yellow,
                                activeColor: Colors.orangeAccent,
                              ),
                            ],
                          ),
                          Column(
                            children: const [
                              Text(
                                '  VU:',
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
                                value: isSwitchedLateUnexcused,
                                onChanged: (value) {
                                  if (value == true) {
                                    _filterLateUnexcused(value);
                                  } else {
                                    resetSwitches();
                                  }
                                },
                                activeTrackColor: Colors.yellow,
                                activeColor: Colors.orangeAccent,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '  D:',
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
                                value: isSwitchedDistance,
                                onChanged: (value) {
                                  if (value == true) {
                                    _filterDistance(value);
                                  } else {
                                    resetSwitches();
                                  }
                                },
                                activeTrackColor: Colors.yellow,
                                activeColor: Colors.orangeAccent,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '  anwesend:',
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
                                value: isSwitchedPresence,
                                onChanged: (value) {
                                  if (value == true) {
                                    _filterPresent(value);
                                  } else {
                                    resetSwitches();
                                  }
                                },
                                activeTrackColor: Colors.yellow,
                                activeColor: Colors.orangeAccent,
                              ),
                            ],
                          ),
                          Column(
                            children: const [
                              Text(
                                '  nicht da:',
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
                                value: isSwitchedAbsence,
                                onChanged: (value) {
                                  if (value == true) {
                                    _filterAbsent(value);
                                  } else {
                                    resetSwitches();
                                  }
                                },
                                activeTrackColor: Colors.yellow,
                                activeColor: Colors.orangeAccent,
                              ),
                            ],
                          ),
                          Column(
                            children: const [
                              Text(
                                ' E1',
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
                              Checkbox(
                                  value: isSwitchedClass1,
                                  onChanged: (value) {
                                    if (value == false) {
                                      _filterClass1(value);
                                    } else {
                                      resetSwitches();
                                    }
                                  }),
                            ],
                          ),
                          Column(
                            children: const [
                              Text(
                                ' E2',
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
                              Checkbox(
                                  value: isSwitchedClass2,
                                  onChanged: (value) {
                                    if (value == false) {
                                      _filterClass2(value);
                                    } else {
                                      resetSwitches();
                                    }
                                  }),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                ' E3',
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
                              Checkbox(
                                  value: this.isSwitchedClassE3,
                                  onChanged: (value) {
                                    if (value == false) {
                                      _filterClassE3(value);
                                    } else {
                                      resetSwitches();
                                    }
                                  }),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                ' S3',
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
                              Checkbox(
                                  value: this.isSwitchedClass3,
                                  onChanged: (value) {
                                    if (value == false) {
                                      _filterClass3(value);
                                    } else {
                                      resetSwitches();
                                    }
                                  }),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                ' S4',
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
                              Checkbox(
                                  value: this.isSwitchedClass4,
                                  onChanged: (value) {
                                    if (value == false) {
                                      _filterClass4(value);
                                    } else {
                                      resetSwitches();
                                    }
                                  }),
                            ],
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'A1',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedA1,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterA1(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'A2',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedA2,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterA2(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'A3',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedA3,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterA3(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'B1',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedB1,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterB1(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'B2',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedB2,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterB2(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'B3',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedB3,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterB3(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'B4',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedB4,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterB4(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'C1',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedC1,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterC1(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'C2',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedC2,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterC2(value);
                                        }
                                      },
                                    ),
                                    Text(
                                      'C3',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSwitchedC3,
                                      activeColor: Colors.blue,
                                      onChanged: (value) {
                                        if (value == true) {
                                          resetSwitches();
                                        } else {
                                          _filterC3(value);
                                        }
                                      },
                                    )
                                  ])),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 10.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'Klasse:',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                onTap: () {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                },

                                items: groupDropdownList.map((option) {
                                  return DropdownMenuItem(
                                    child: Text(
                                      "$option",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    value: option,
                                  );
                                }).toList(),
                                value: selectedGroup, //asign the selected value
                                onChanged: (value) {
                                  if (selectedGroup == value) {
                                    setState(() {
                                      selectedGroup = value!;
                                      return;
                                    });
                                  } else {
                                    setState(() {
                                      selectedGroup = value!;
                                      _filterGroup(
                                          selectedGroup); //on selection, selectedDropDownValue i sUpdated
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ]),
                      Text(
                        'Anzahl:  ',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        filteredhermannpupils.length.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: myFocusNode,
                          controller: textEditingController,
                          onChanged: (string) => _filterTextfield(string),
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
                                myFocusNode.unfocus(),
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide'),
                                textEditingController.clear(),
                                resetSwitches(),
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
                      String _missedTypeDefaultValue = 'none';
                      String _dropdownValue = _setMissedTypeValue(
                          index, _missedTypeDefaultValue, thisDate);
                      bool _excusedValue = _setExcusedValue(index, thisDate);
                      bool _contactedValue =
                          _setContactedValue(index, thisDate);
                      String? _createdModifiedValue =
                          _setCreatedModifiedValue(index, thisDate);
                      bool? _returnedValue = _setReturnedValue(index, thisDate);
                      if (_returnedValue == null) {
                        _returnedValue = false;
                      }

                      return Card(
                        elevation: 1.0,
                        margin: EdgeInsets.only(
                            left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onLongPress: () => _longPressHermannpupil(
                                    context, hermannpupil),
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HermannpupilPage(
                                          hermannpupil: hermannpupil),
                                ))
                                    .then((_) {
                                  updateData(selectedGroup);
                                }),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15.0, left: 15.0),
                                          child: RichText(
                                            text: TextSpan(
                                                text: hermannpupil.group,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(text: '      '),
                                                  TextSpan(
                                                    text:
                                                        hermannpupil.schoolyear,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  TextSpan(
                                                    text: '  ' +
                                                        hermannpupil.id
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ]),
                                          ),
                                        ),
                                        if (hermannpupil.ogs == true)
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 15.0, right: 20.0),
                                              child: Text(
                                                'OGS',
                                                style: TextStyle(
                                                  color: Colors.deepPurple[400],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ))
                                        else
                                          Container(),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0,
                                                left: 15.0,
                                                bottom: 15.0),
                                            child: Text(
                                              hermannpupil.name,
                                              overflow: TextOverflow.fade,
                                              softWrap: false,
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
                            ),
                            Column(
                              children: [
                                _createdModifiedValue != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_createdModifiedValue),
                                      )
                                    : SizedBox(),
                              ],
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
                                          value: 'none',
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Text("A",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  )),
                                            ),
                                          )),
                                      DropdownMenuItem(
                                          value: 'late',
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                              color: Colors.yellow[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Text("V",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  )),
                                            ),
                                          )),
                                      DropdownMenuItem(
                                          value: 'missed',
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                              color: Colors.orange[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Text("F",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  )),
                                            ),
                                          )),
                                      DropdownMenuItem(
                                          value: 'distance',
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                              color: Colors.purple[600],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Text("Q",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  )),
                                            ),
                                          )),
                                    ],
                                    onChanged: (newvalue) {
                                      if (_dropdownValue == newvalue) {
                                        setState(() {
                                          _dropdownValue = newvalue!;
                                        });
                                      } else if (newvalue == 'none') {
                                        _deleteMissedClass(index, thisDate);
                                      } else if (_dropdownValue == 'none') {
                                        if (_returnedValue == false) {
                                          _createDropdownValue(
                                              index, newvalue!, thisDate);
                                        } else {
                                          _changeDropdownValue(
                                              index, newvalue!, thisDate);
                                        }
                                      } else {
                                        _changeDropdownValue(
                                            index, newvalue!, thisDate);
                                        setState(() {
                                          _dropdownValue = newvalue;
                                        });
                                      }
                                    }),
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: 5.0),
                                    child: Text('Unent.')),
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.orange[800],
                                  value: _excusedValue,
                                  onChanged: (bool? newvalue) {
                                    if (_dropdownValue == 'none') {
                                      _excusedValue = false;
                                    } else {
                                      _changeExcusedValue(
                                          index, newvalue!, thisDate);
                                      setState(() {
                                        _excusedValue = newvalue;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: 5.0),
                                    child: Text('Kon.')),
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.orange[900],
                                  value: _contactedValue,
                                  onChanged: (bool? newvalue) {
                                    if (_dropdownValue == 'none') {
                                      _contactedValue = false;
                                    } else {
                                      _changeContactedValue(
                                          index, newvalue!, thisDate);
                                      setState(() {
                                        _contactedValue = newvalue;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: 5.0),
                                    child: Text('abh.')),
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.green[900],
                                  value: _returnedValue,
                                  onChanged: (bool? newvalue) {
                                    // if (_dropdownValue == 'none') {
                                    //   _returnedValue = false;
                                    // } else {
                                    _changeReturnedValue(
                                        index, newvalue!, thisDate);
                                    print('tapped returned');
                                    setState(() {
                                      _returnedValue = newvalue;
                                    });
                                  },
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
          child: Icon(Icons.refresh),
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigo,
        ),
      );
}

class QRScanPupilCodes extends StatefulWidget {
  // QRScanPupilCodes({this.passedhermannpupils});
  //  final List<Hermannpupil> passedhermannpupils;

  @override
  State<StatefulWidget> createState() => _QRScanPupilCodesState();
}

class _QRScanPupilCodesState extends State<QRScanPupilCodes> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final storage = FlutterSecureStorage();
  List<CodedNames> codedNames = List.empty();

  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();

  //   return directory.path;
  // }

  // Future<File> get _localFile async {
  //   final path = await _localPath;
  //   return File('$path/codestonames.json');
  // }

  storeQR(result) async {
    try {
      final keyutf8 =
          await rootBundle.loadString('assets/keys/keyaes256cbc.txt');
      final ivutf8 = await rootBundle.loadString('assets/keys/ivaes256cbc.txt');
      final key = enc.Key.fromUtf8(keyutf8);
      final iv = enc.IV.fromUtf8(ivutf8);
      final encryptedResult = enc.Encrypted.fromBase64(result.code);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final codedNamesResult = encrypter.decrypt(encryptedResult, iv: iv);

      //  final decodedNames = utf8.decode(codedNamesResult.runes.toList());

      print('This is the result: ' + codedNamesResult);
      if (codedNamesResult[0] != '[') {
        print('Scan fehler');
        return;
      }
      codedNames = codedNamesFromJson(codedNamesResult);
      Get.back(result: codedNames);
    } catch (e) {
      print('Scan fehler: ' + e.toString());
      Get.snackbar(
        "Scan Fehler",
        "Bitte erneut versuchen",
        icon: Icon(Icons.error_outline_rounded),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.indigo,
        borderRadius: 20,
        margin: EdgeInsets.all(15),
        colorText: Colors.white,
        duration: Duration(seconds: 1),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      );
      codedNames = [];
      Get.off(() => MissedClassPage());
    }
  }
  //   print('This is the result: ' + result.code);
  //   if (result.code[0] != '[') {
  //     print('Scan fehler');
  //     return;
  //   }
  //   codedNames = codedNamesFromJson(result.code);
  //   Get.back(result: codedNames);
  // }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      }
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 5,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      // controller.stopCamera();
      controller.dispose();
      storeQR(scanData);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

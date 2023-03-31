import 'package:fehlzeiten/tools/models.dart';
import 'package:flutter/material.dart';
import 'package:fehlzeiten/tools/models.dart';
import 'package:fehlzeiten/tools/api.dart';
import 'package:fehlzeiten/tools/badges.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class HermannpupilPage extends StatefulWidget {
  final Hermannpupil hermannpupil;

  const HermannpupilPage({
    Key? key,
    required this.hermannpupil,
  }) : super(key: key);

  @override
  _HermannpupilPageState createState() => _HermannpupilPageState();
}

class _HermannpupilPageState extends State<HermannpupilPage> {
  bool deleteSuccess = false;
  late String _dropdownValueOgs = _setDropdownValueOgs();
  static DateFormat dateFormat = new DateFormat("dd.MM.yyyy");
  late StateSetter _setState;

  missedclassSum() {
    var missedclassCount = widget.hermannpupil.pupilmissedclasses
        .where((element) => element.missedtype == 'missed')
        .length;

    return missedclassCount;
  }

  missedclassUnexcusedSum() {
    var missedclassUnexcusedCount = widget.hermannpupil.pupilmissedclasses
        .where((element) =>
            element.missedtype == 'missed' && element.excused == true)
        .length;

    return missedclassUnexcusedCount;
  }

  distanceSum() {
    var distanceCount = widget.hermannpupil.pupilmissedclasses
        .where((element) => element.missedtype == 'distance')
        .length;

    return distanceCount;
  }

  contactedSum() {
    var contactedCount = widget.hermannpupil.pupilmissedclasses
        .where((element) => element.contacted == true)
        .length;

    return contactedCount;
  }

  Future _deleteAdmonitionHermannpupilPage(index, admonishedday) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Eintrag löschen?',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            content: Container(
              height: 150.0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${widget.hermannpupil.name}  ${widget.hermannpupil.group}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'am  ${dateFormat.format(admonishedday)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    deleteSuccess = false;
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Api.deletePostMissedType(
                      widget.hermannpupil.id,
                      DateFormat("yyyy-MM-dd")
                          .format(admonishedday)
                          .toString());

                  setState(() {
                    deleteSuccess = true;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future _deleteMissedClassHermannpupilPage(
      index, missedday, missedtype) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Eintrag löschen?',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            content: Container(
              height: 150.0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${widget.hermannpupil.name}  ${widget.hermannpupil.group}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'am  ${dateFormat.format(missedday)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          missedTypeBadge(missedtype),
                          excusedBadge(widget
                              .hermannpupil.pupilmissedclasses[index].excused),
                          contactedBadge(widget
                              .hermannpupil.pupilmissedclasses[index].contacted)
                        ]),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    deleteSuccess = false;
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Api.deletePostMissedType(widget.hermannpupil.id,
                      DateFormat("yyyy-MM-dd").format(missedday).toString());

                  setState(() {
                    deleteSuccess = true;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _changeMissedClassHermannpupilPage(
      context,
      index,
      thishermannpupil,
      thisdate,
      thismissedtype,
      thisexcused,
      thiscontacted) async {
    return showDialog(
        context: context,
        builder: (context) {
          String dialogdropdownValue = thismissedtype;
          bool excusedValue = thisexcused;
          bool contactedValue = thiscontacted;
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            _setState = setState;
            return AlertDialog(
              title: const Text(
                'Eintrag ändern',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              content: Container(
                height: 170.0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        thishermannpupil.name + '  ' + thishermannpupil.group,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        dateFormat.format(thisdate).toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    value: dialogdropdownValue,
                                    items: [
                                      DropdownMenuItem(
                                          value: 'late',
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
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
                                                    fontSize: 24,
                                                  )),
                                            ),
                                          )),
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
                                        dialogdropdownValue =
                                            newvalue.toString();
                                      });
                                    }),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text('Unent.')),
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.orange[800],
                                value: excusedValue,
                                onChanged: (bool? newvalue) {
                                  _setState(() {
                                    excusedValue = newvalue!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text('Kon.')),
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.orange[900],
                                value: contactedValue,
                                onChanged: (bool? newvalue) {
                                  setState(() {
                                    contactedValue = newvalue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('ABBRECHEN'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  child: const Text('ÄNDERN'),
                  onPressed: () async {
                    await Api.changeMissedEntry(
                        thishermannpupil.id,
                        DateFormat("yyyy-MM-dd").format(thisdate).toString(),
                        dialogdropdownValue,
                        excusedValue,
                        contactedValue);
                    setState(() {
                      widget.hermannpupil.pupilmissedclasses[index].missedtype =
                          dialogdropdownValue;
                      widget.hermannpupil.pupilmissedclasses[index].excused =
                          excusedValue;
                      widget.hermannpupil.pupilmissedclasses[index].contacted =
                          contactedValue;

                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
        });
  }

  _setDropdownValueOgs() {
    if (widget.hermannpupil.ogs == true) {
      return 'JA';
    } else {
      return 'NEIN';
    }
  }

  _changeDropdownValueOgs(id, ogsstatus) async {
    final bool OgsStatus;
    if (ogsstatus == 'JA') {
      OgsStatus = true;
    } else {
      OgsStatus = false;
    }
    await Api.patchOgsStatus(id, OgsStatus);
    return;
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Kontostand ändern'),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration:
                  const InputDecoration(hintText: "Neuen Kontostand eingeben"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ABBRECHEN'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: const Text('ÄNDERN'),
                onPressed: () {
                  print('Button geklickt');
                  Api.postCredit(this.widget.hermannpupil.id, this.valueText);

                  setState(() {
                    widget.hermannpupil.credit = int.parse(valueText);

                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  late String codeDialog;
  late String valueText;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              '${widget.hermannpupil.group} - ${widget.hermannpupil.name} - ID: ${widget.hermannpupil.id}'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // construct the profile details widget here
            SizedBox(
              height: 180,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 20.0, right: 20.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'OGS: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Column(children: [
                                  DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton(
                                        onTap: () {
                                          // FocusManager.instance.primaryFocus.unfocus();
                                        },

                                        items: [
                                          "JA",
                                          "NEIN",
                                        ].map((option) {
                                          return DropdownMenuItem(
                                            value: option,
                                            child: Text(
                                              option,
                                              textAlign: TextAlign.right,
                                              style: option == 'JA'
                                                  ? TextStyle(
                                                      color: Colors.green[800],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    )
                                                  : TextStyle(
                                                      color: Colors.grey[700],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                            ),
                                          );
                                        }).toList(),
                                        value:
                                            _dropdownValueOgs, //asign the selected value
                                        onChanged: (value) {
                                          if (_dropdownValueOgs == value) {
                                            setState(() {
                                              _dropdownValueOgs =
                                                  value.toString();
                                              return;
                                            });
                                          } else {
                                            _changeDropdownValueOgs(
                                                widget.hermannpupil.id, value);
                                            setState(() {
                                              _dropdownValueOgs = value
                                                  .toString(); //on selection, selectedDropDownValue i sUpdated
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ]),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        widget.hermannpupil.credit.toString(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Kontostand Hermanntaler:',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 20)),
                                onPressed: () {
                                  _displayTextInputDialog(context);
                                },
                                child: const Padding(
                                    padding: EdgeInsets.only(
                                        left: 5.0,
                                        right: 5.0,
                                        top: 15.0,
                                        bottom: 15.0),
                                    child: Text('Kontostand ändern')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // the tab bar with two items
            SizedBox(
              height: 50,
              child: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(
                      text: 'Fehlzeiten',
                    ),
                    Tab(
                      text: 'Karten',
                    ),
                  ],
                ),
              ),
            ),

            // create widgets for each tab bar here
            Expanded(
              child: TabBarView(
                children: [
                  // first tab bar view widget
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Fehlzeiten',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                      missedTypeBadge('missed'),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 20.0),
                                        child: Text(
                                          missedclassSum().toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                      missedTypeBadge('missed'),
                                      excusedBadge(true),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 20.0),
                                        child: Text(
                                          missedclassUnexcusedSum().toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                      missedTypeBadge('distance'),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 20.0),
                                        child: Text(
                                          distanceSum().toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                      contactedBadge(true),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 20.0),
                                        child: Text(
                                          contactedSum().toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: widget
                                        .hermannpupil.pupilmissedclasses.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      widget.hermannpupil.pupilmissedclasses
                                          .sort((a, b) => a.missedSchoolday
                                              .compareTo(b.missedSchoolday));
                                      key:
                                      UniqueKey();

                                      return Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _changeMissedClassHermannpupilPage(
                                                context,
                                                index,
                                                widget.hermannpupil,
                                                widget
                                                    .hermannpupil
                                                    .pupilmissedclasses[index]
                                                    .missedSchoolday,
                                                widget
                                                    .hermannpupil
                                                    .pupilmissedclasses[index]
                                                    .missedtype,
                                                widget
                                                    .hermannpupil
                                                    .pupilmissedclasses[index]
                                                    .excused,
                                                widget
                                                    .hermannpupil
                                                    .pupilmissedclasses[index]
                                                    .contacted);
                                            setState(() {
                                              widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .missedtype =
                                                  widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .missedtype;
                                              widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .excused =
                                                  widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .excused;
                                              widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .contacted =
                                                  widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .contacted;
                                            });
                                          },
                                          onLongPress: () async {
                                            await _deleteMissedClassHermannpupilPage(
                                                index,
                                                widget
                                                    .hermannpupil
                                                    .pupilmissedclasses[index]
                                                    .missedSchoolday,
                                                widget
                                                    .hermannpupil
                                                    .pupilmissedclasses[index]
                                                    .missedtype);
                                            if (deleteSuccess == true) {
                                              setState(() {
                                                widget.hermannpupil
                                                    .pupilmissedclasses
                                                    .removeAt(index);
                                              });
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Text(
                                                  DateFormat('dd.MM.yyyy')
                                                      .format(widget
                                                          .hermannpupil
                                                          .pupilmissedclasses[
                                                              index]
                                                          .missedSchoolday)
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                              missedTypeBadge(widget
                                                  .hermannpupil
                                                  .pupilmissedclasses[index]
                                                  .missedtype),
                                              excusedBadge(widget
                                                  .hermannpupil
                                                  .pupilmissedclasses[index]
                                                  .excused),
                                              contactedBadge(widget
                                                  .hermannpupil
                                                  .pupilmissedclasses[index]
                                                  .contacted),
                                              returnedBadge(widget
                                                  .hermannpupil
                                                  .pupilmissedclasses[index]
                                                  .returned),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        if (widget
                                                                .hermannpupil
                                                                .pupilmissedclasses[
                                                                    index]
                                                                .missedtype ==
                                                            'late')
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: RichText(
                                                                text: TextSpan(
                                                              text:
                                                                  'Verspätung: ',
                                                              style: DefaultTextStyle
                                                                      .of(context)
                                                                  .style,
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        '${widget.hermannpupil.pupilmissedclasses[index].lateAt!} min')
                                                              ],
                                                            )),
                                                          ),
                                                        if (widget
                                                                .hermannpupil
                                                                .pupilmissedclasses[
                                                                    index]
                                                                .returned ==
                                                            true)
                                                          RichText(
                                                              text: TextSpan(
                                                            text:
                                                                'Abgeholt um: ',
                                                            style: DefaultTextStyle
                                                                    .of(context)
                                                                .style,
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                  text: widget
                                                                      .hermannpupil
                                                                      .pupilmissedclasses[
                                                                          index]
                                                                      .returnedAt)
                                                            ],
                                                          )),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: RichText(
                                                              text: TextSpan(
                                                            text:
                                                                'Erstellt von: ',
                                                            style: DefaultTextStyle
                                                                    .of(context)
                                                                .style,
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                  text: widget
                                                                      .hermannpupil
                                                                      .pupilmissedclasses[
                                                                          index]
                                                                      .createdBy)
                                                            ],
                                                          )),
                                                        ),
                                                        if (widget
                                                                .hermannpupil
                                                                .pupilmissedclasses[
                                                                    index]
                                                                .modifiedBy !=
                                                            null)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: RichText(
                                                                text: TextSpan(
                                                              text:
                                                                  'Geändert von: ',
                                                              style: DefaultTextStyle
                                                                      .of(context)
                                                                  .style,
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                    text: widget
                                                                        .hermannpupil
                                                                        .pupilmissedclasses[
                                                                            index]
                                                                        .modifiedBy)
                                                              ],
                                                            )),
                                                          ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // second tab bar view widget
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.hermannpupil.pupiladmonitions.length,
                      itemBuilder: (BuildContext context, int index) {
                        widget.hermannpupil.pupiladmonitions.sort((a, b) => a
                            .admonishedSchoolday
                            .compareTo(b.admonishedSchoolday));
                        UniqueKey();

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onLongPress: () async {
                              await _deleteAdmonitionHermannpupilPage(
                                  index,
                                  widget.hermannpupil.pupiladmonitions[index]
                                      .admonishedSchoolday);
                              if (deleteSuccess == true) {
                                setState(() {
                                  widget.hermannpupil.pupilmissedclasses
                                      .removeAt(index);
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    DateFormat('dd.MM.yyyy')
                                        .format(widget
                                            .hermannpupil
                                            .pupilmissedclasses[index]
                                            .missedSchoolday)
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                missedTypeBadge(widget.hermannpupil
                                    .pupilmissedclasses[index].missedtype),
                                excusedBadge(widget.hermannpupil
                                    .pupilmissedclasses[index].excused),
                                contactedBadge(widget.hermannpupil
                                    .pupilmissedclasses[index].contacted),
                                returnedBadge(widget.hermannpupil
                                    .pupilmissedclasses[index].returned),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (widget
                                                .hermannpupil
                                                .pupilmissedclasses[index]
                                                .missedtype ==
                                            'late')
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RichText(
                                                text: TextSpan(
                                              text: 'Verspätung: ',
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style,
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text:
                                                        '${widget.hermannpupil.pupilmissedclasses[index].lateAt!} min')
                                              ],
                                            )),
                                          ),
                                        if (widget
                                                .hermannpupil
                                                .pupilmissedclasses[index]
                                                .returned ==
                                            true)
                                          RichText(
                                              text: TextSpan(
                                            text: 'Abgeholt um: ',
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .returnedAt)
                                            ],
                                          )),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RichText(
                                              text: TextSpan(
                                            text: 'Erstellt von: ',
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: widget
                                                      .hermannpupil
                                                      .pupilmissedclasses[index]
                                                      .createdBy)
                                            ],
                                          )),
                                        ),
                                        if (widget
                                                .hermannpupil
                                                .pupilmissedclasses[index]
                                                .modifiedBy !=
                                            null)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RichText(
                                                text: TextSpan(
                                              text: 'Geändert von: ',
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style,
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: widget
                                                        .hermannpupil
                                                        .pupilmissedclasses[
                                                            index]
                                                        .modifiedBy)
                                              ],
                                            )),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

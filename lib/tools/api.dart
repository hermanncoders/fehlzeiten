import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../login.dart';
import '../main.dart';
import 'package:get/get.dart';
import 'models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

apiSnackbar(title, text, icon, color) {
  Get.snackbar(
    title,
    text,
    icon: icon,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: color,
    borderRadius: 20,
    margin: EdgeInsets.all(15),
    colorText: Colors.white,
    duration: Duration(seconds: 1),
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}

var money = Icon(Icons.money, color: Colors.white);
var house = Icon(Icons.house, color: Colors.white);
var calendar = Icon(Icons.calendar_today_rounded, color: Colors.white);
var orange = Colors.orange[900];
var green = Colors.green;
const FlutterSecureStorage storage = FlutterSecureStorage();
const String error = 'Etwas hat nicht geklappt!';

class Api {
  static Future<String> postCredit(pupilId, credit) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'Transaktion erfolgreich!';
    const String successcomment = 'Der Betrag wurde verbucht';
    const String errorcomment = 'Der Betrag wurde nicht verbucht';
    try {
      final response =
          await http.patch(Uri.parse('$SERVER_IP/hermannkind/$pupilId/credit'),
              headers: {
                "x-access-token": mytoken.toString(),
                "Content-Type": "application/json;charset=UTF-8"
              },
              body: jsonEncode({"credit": credit.toString()}));
      if (200 == response.statusCode) {
        apiSnackbar(success, successcomment, money, green);
        return success;
      } else {
        apiSnackbar(error, errorcomment, money, orange);
        return '$error Statuscode ${response.statusCode}';
      }
    } catch (e) {
      apiSnackbar('Fehler', "Der Betrag wurde nicht verbucht", money, orange);
      return '$error catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> patchOgsStatus(pupilId, ogsstatus) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'OGS-Status aktualisiert';
    const String successcomment = 'Der Status wurde in den Server geschrieben';
    const String error = 'Etwas hat nicht funktioniert';
    const String errorcomment = 'Der Status wurde nicht geändert!';
    try {
      final response = await http.patch(
          Uri.parse('$SERVER_IP/hermannkind/${pupilId.toString()}/ogs'),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: jsonEncode({"ogs": ogsstatus}));
      if (200 == response.statusCode) {
        if (kDebugMode) {
          print('STATUS CODE: ${response.statusCode}');
        }
        apiSnackbar(success, successcomment, house, green);
        return success;
      } else {
        apiSnackbar(error, errorcomment, house, orange);
        return '$error Statuscode ${response.statusCode}';
      }
    } catch (e) {
      apiSnackbar("Etwas hat nicht funktioniert",
          "EXCEPTION - Der Status wurde nicht geändert!", house, orange);

      return 'Catched exception: ${e.toString()}';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> newMissedType(pupilId, missedschoolday, missedtype,
      username, lateAt, returned, returnedAt) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'Fehlzeit aktualisiert';
    const String successcomment =
        'Die Fehlzeit wurde in den Server geschrieben';
    const String error = 'Etwas hat nicht funktioniert';
    const String errorcomment = 'Der Status wurde nicht geändert!';
    final messagebody = jsonEncode(<String, dynamic>{
      "missedpupil_id": pupilId.toString(),
      "missedday": missedschoolday,
      "missedtype": missedtype,
      "excused": false,
      "contacted": false,
      "returned": returned,
      "created_by": username,
      "modified_by": null,
      "late_at": lateAt,
      "written_excuse": null,
      "returned_at": returnedAt
    });

    try {
      final response = await http.post(Uri.parse(SERVER_IP + '/fehlzeit'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-access-token': mytoken.toString(),
          },
          body: messagebody);

      if (200 == response.statusCode) {
        apiSnackbar(success, successcomment, house, green);
        return success;
      } else if (500 == response.statusCode) {
        apiSnackbar("Dieser Tag ist kein Schultag",
            "Bitte einen Schultag auswählen!", calendar, orange);
        return '$error Statuscode ${response.statusCode}';
      } else {
        apiSnackbar(error, errorcomment, house, orange);
        return '$error Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      return 'Catched exception: ${e.toString()}';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> changeMissedEntry(pupilId, missedschoolday, missedtype,
      missedexcused, missedcontacted) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'Fehlzeit aktualisiert';
    const String successcomment =
        'Die Fehlzeit wurde in den Server geschrieben';
    const String error = 'Etwas hat nicht funktioniert';
    const String errorcomment = 'Der Status wurde nicht geändert!';

    if (missedtype == 'none') {
      return error;
    }

    try {
      final response = await http.patch(
          Uri.parse('$SERVER_IP/fehlzeit/$pupilId/$missedschoolday'),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: jsonEncode(<String, dynamic>{
            // "missedpupil_id": pupilId.toString(),
            // "missedday": missedschoolday,
            "missedtype": missedtype,
            "excused": missedexcused,
            "contacted": missedcontacted
          }));

      if (200 == response.statusCode) {
        apiSnackbar(success, successcomment, house, green);
        return success;
      } else {
        if (kDebugMode) {
          print(
              'Error: ${error.toString()}, Statuscode ${response.statusCode}');
        }
        apiSnackbar(error, errorcomment, house, orange);
        return 'Error: ${error.toString()}, Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      return 'Catched exception: ${e.toString()}';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> changeMissedType(
      pupilId, missedschoolday, missedtype, username, lateAt) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'Eintrag geändert';
    const String successcomment =
        'Die Änderung wurde in die Datenbank geschrieben.';

    if (missedtype == 'none') {
      return error;
    }

    try {
      final response = await http.patch(
          Uri.parse(
              '$SERVER_IP/fehlzeit/type/${pupilId.toString()}/$missedschoolday'),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: jsonEncode(<String, dynamic>{
            "missedpupil_id": pupilId.toString(),
            "missedday": missedschoolday,
            "missedtype": missedtype,
            "modified_by": username,
            "late_at": lateAt
          }));

      if (200 == response.statusCode) {
        apiSnackbar(success, successcomment, calendar, green);

        return success;
      } else {
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> changeMissedStatus(
      pupilId, missedschoolday, bool missedstatus) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'Eintrag geändert';
    const String successcomment =
        'Die Änderung wurde in die Datenbank geschrieben.';
    final bodyresponse = jsonEncode(<String, dynamic>{
      "missedpupil_id": pupilId.toString(),
      "missedday": missedschoolday,
      "excused": missedstatus
    });

    try {
      final response = await http.patch(
          Uri.parse(SERVER_IP +
              '/fehlzeit/status/' +
              pupilId.toString() +
              '/' +
              missedschoolday),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: bodyresponse);

      if (200 == response.statusCode) {
        apiSnackbar(success, successcomment, calendar, green);

        return success;
      } else {
        print('STATUS CODE: ' + response.statusCode.toString());
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> changeContactedStatus(
      pupilId, missedschoolday, bool contactedstatus) async {
    print('Missedstatus angekommen');
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    final String success = 'Geklappt!';
    final String error = 'Etwas hat nicht geklappt:';
    final bodyresponse =
        jsonEncode(<String, dynamic>{"contacted": contactedstatus});

    try {
      final response = await http.patch(
          Uri.parse(SERVER_IP +
              '/fehlzeit/contacted/' +
              pupilId.toString() +
              '/' +
              missedschoolday),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: bodyresponse);

      if (200 == response.statusCode) {
        return success;
      } else {
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> changeReturnedStatus(
      pupilId, missedschoolday, bool returnedstatus, returnedtime) async {
    print('Returnedstatus angekommen');
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    final String success = 'Geklappt!';
    final String error = 'Etwas hat nicht geklappt:';
    final bodyresponse = jsonEncode(<String, dynamic>{
      "returned": returnedstatus,
      "returned_at": returnedtime
    });

    try {
      final response = await http.patch(
          Uri.parse(SERVER_IP +
              '/fehlzeit/returned/' +
              pupilId.toString() +
              '/' +
              missedschoolday),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: bodyresponse);

      if (200 == response.statusCode) {
        return success;
      } else {
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> deletePostMissedType(pupilId, missedschoolday) async {
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    final String success = 'Geklappt!';
    final String error = 'Etwas hat nicht geklappt:';

    try {
      final response = await http.delete(
          Uri.parse(SERVER_IP +
              '/fehlzeit/' +
              pupilId.toString() +
              '/' +
              missedschoolday),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          });
      if (200 == response.statusCode) {
        print('STATUS CODE: ' + response.statusCode.toString());
        apiSnackbar("Eintrag gelöscht",
            "Der Fehleintrag wurde erfolgreich gelöscht!", calendar, green);

        return success;
      } else {
        print('STATUS CODE: ' + response.statusCode.toString());
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<List<Hermannpupil>> getHermannpupils(String group) async {
    final mytoken = (await storage.read(key: 'jwt'))!;
    final String thisUrl;
    Map<String, String> requestHeaders = {
      // "Connection": "keep-alive",
      "x-access-token": mytoken.toString()
    };
    if (group == "Gesamt") {
      thisUrl = SERVER_IP + '/hermannkinder';
    } else {
      thisUrl = SERVER_IP + '/hermannkinder/' + group;
    }
    try {
      final response =
          await http.get(Uri.parse(thisUrl), headers: requestHeaders);

      if (200 == response.statusCode) {
        print('response');
        print(response.body.toString());
        final List<Hermannpupil> hermannpupils =
            hermannpupilFromJson(response.body);
        print('Hermannpupils gezogen');
        return hermannpupils;
      } else if (401 == response.statusCode) {
        Get.off(() => LoginPage());
        Get.defaultDialog(
          title: 'Token abgelaufen',
          middleText:
              'Aus Sicherheitsgründen ist eine Anmeldung nur 24 Stunden gültig. Bitte erneut einloggen!',
          radius: 10,
          titlePadding: EdgeInsets.only(top: 20.0, bottom: 10.0),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Text("SCHLIEßEN"),
            )
          ],
        );
        throw Exception('token invalid');
      } else {
        print(response.statusCode);
        throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e, s) {
      print(e);
      print(s);
      // Get.defaultDialog(
      //   title: 'Verbindung unterbrochen',
      //   middleText:
      //       'Die Verbindung wurde unterbrochen, während Daten empfangen wurden. Bitte nochmal versuchen!',
      //   radius: 10,
      //   titlePadding: EdgeInsets.only(top: 20.0, bottom: 10.0),
      //   actions: <Widget>[
      //     ElevatedButton(
      //       onPressed: () {
      //         Get.back();
      //       },
      //       child: Text("SCHLIEßEN"),
      //     )
      //   ],
      // );
      throw Exception('http.get error:');
    }
  }

  static Future<List<Schooldays>> getSchooldays() async {
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    try {
      final response = await http.get(Uri.parse(SERVER_IP + '/schultage'),
          headers: {"x-access-token": mytoken.toString()});
      if (200 == response.statusCode) {
        final List<Schooldays> schooldays = schooldaysFromJson(response.body);
        return schooldays;
      } else if (401 == response.statusCode) {
        Get.off(() => LoginPage());
        // Get.defaultDialog(
        //   title: 'Token abgelaufen',
        //   middleText:
        //       'Aus Sicherheitsgründen ist eine Anmeldung nur 24 Stunden gültig. Bitte erneut einloggen!',
        //   radius: 10,
        //   titlePadding: EdgeInsets.only(top: 20.0, bottom: 10.0),
        // );
        throw Exception('token invalid');
      } else {
        throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e, s) {
      print(e);
      print(s);
      throw Exception('http.get error:');
    }
  }

  static Future<List<Coronastatus>> getCoronastatus() async {
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    try {
      final response = await http.get(Uri.parse(SERVER_IP + '/coronastatus'),
          headers: {"x-access-token": mytoken.toString()});
      if (200 == response.statusCode) {
        final List<Coronastatus> coronastatus =
            coronastatusFromJson(response.body);
        return coronastatus;
      } else {
        throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('http.get error:');
    }
  }

  static Future<String> deleteCoronastatus(pupilId) async {
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    final String success = 'Geklappt!';
    final String error = 'Etwas hat nicht geklappt:';

    try {
      final response = await http.delete(
          Uri.parse(SERVER_IP + '/coronastatus/' + pupilId.toString()),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          });

      if (200 == response.statusCode) {
        print('STATUS CODE: ' + response.statusCode.toString());

        return success;
      } else {
        print('STATUS CODE: ' + response.statusCode.toString());
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> changeCoronastatusStatus(pupilId, coronastatus) async {
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    final String success = 'Geklappt!';
    final String error = 'Etwas hat nicht geklappt:';
    final bodyresponse =
        jsonEncode(<String, dynamic>{"corona_status": coronastatus});

    try {
      final response = await http.patch(
          Uri.parse(SERVER_IP + '/coronastatus/status/' + pupilId.toString()),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: bodyresponse);

      if (200 == response.statusCode) {
        print('STATUS CODE: ' + response.statusCode.toString());

        return success;
      } else {
        print('STATUS CODE: ' + response.statusCode.toString());
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> changeCoronastatusDate(pupilId, untildate) async {
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    final String success = 'Geklappt!';
    final String error = 'Etwas hat nicht geklappt:';
    final bodyresponse = jsonEncode(<String, dynamic>{
      "untildate": untildate,
    });

    try {
      final response = await http.patch(
          Uri.parse(SERVER_IP + '/coronastatus/date/' + pupilId.toString()),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          },
          body: bodyresponse);

      if (200 == response.statusCode) {
        print('STATUS CODE: ' + response.statusCode.toString());

        return success;
      } else {
        print('STATUS CODE: ' + response.statusCode.toString());
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> createCoronastatus(
      pupilId, untildate, coronastatus) async {
    final mytoken = await FlutterSecureStorage().read(key: 'jwt');
    final String success = 'Geklappt!';
    final String error = 'Etwas hat nicht geklappt:';
    final messagebody = jsonEncode(<String, dynamic>{
      "coronapupil_id": pupilId.toString(),
      "corona_status": coronastatus,
      "untildate": untildate
    });
    try {
      final response = await http.post(Uri.parse(SERVER_IP + '/coronastatus'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-access-token': mytoken.toString(),
          },
          body: messagebody);

      if (200 == response.statusCode) {
        return success;
      } else {
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> newAdmonition(
      pupilId, admonishedday, admonitiontype, admonitionreason) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'OGS-Status aktualisiert';
    final messagebody = jsonEncode(<String, dynamic>{
      "admonishedpupil_id": pupilId.toString(),
      "admonishedday": admonishedday,
      "admonitiontype": admonitiontype,
      "admonitionreason": admonitionreason
    });

    try {
      final response = await http.post(Uri.parse(SERVER_IP + '/fehlzeit'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-access-token': mytoken.toString(),
          },
          body: messagebody);

      if (200 == response.statusCode) {
        return success;
      } else if (500 == response.statusCode) {
        apiSnackbar("Dieser Tag ist kein Schultag",
            "Bitte einen Schultag auswählen!", calendar, orange);
        return error + ' Statuscode ${response.statusCode}';
      } else {
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }

  static Future<String> deleteAdmonition(admonitionId) async {
    final mytoken = await storage.read(key: 'jwt');
    const String success = 'Geklappt!';
    const String error = 'Etwas hat nicht geklappt:';

    try {
      final response = await http.delete(
          Uri.parse('$SERVER_IP/api/karte/${admonitionId.toString()}'),
          headers: {
            "x-access-token": mytoken.toString(),
            "Content-Type": "application/json;charset=UTF-8"
          });

      if (200 == response.statusCode) {
        print('STATUS CODE: ' + response.statusCode.toString());

        return success;
      } else {
        print('STATUS CODE: ' + response.statusCode.toString());
        return error + ' Statuscode ${response.statusCode}';
        // throw Exception('http.get error: statusCode= ${response.statusCode}');
      }
    } catch (e) {
      print('EXCEPTION');
      return error + ' catched exception';
      // throw Exception('http.get error:');
    }
  }
}

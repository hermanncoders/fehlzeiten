// Adapted from : https://dev.to/carminezacc/user-authentication-jwt-authorization-with-flutter-and-node-176l
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' show ascii, base64, base64Encode, json, jsonDecode, utf8;
import 'dart:io';
import 'loadingpage.dart';
import 'login.dart';
import 'home.dart';
import 'package:get/get.dart';

const SERVER_IP = 'https://datahub.hermannschule.de/api';
// const SERVER_IP = 'http://10.0.2.2:5000/api';
// const SERVER_IP = 'https://daten.medien-sandkasten.de/api';
// const SERVER_IP = 'http://172.16.1.79:5000/api';
//const SERVER_IP = 'http://192.168.178.53:5000/api';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget page = LoadingPage();
  final storage = const FlutterSecureStorage();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    String? token = await storage.read(key: 'jwt');
    await Future.delayed(const Duration(milliseconds: 800));

    if (token != null) {
      setState(() {
        page = MissedClassPage();
      });
    } else {
      setState(() {
        page = LoginPage();
      });
    }
  }

  static const MaterialColor myPrimaryColor =
      MaterialColor(0xfff03402, <int, Color>{
    50: Color(0xfff03402),
    100: Color(0xfff03402),
    200: Color(0xfff03402),
    300: Color(0xfff03402),
    400: Color(0xfff03402),
    500: Color(0xfff03402),
    600: Color(0xfff03402),
    700: Color(0xfff03402),
    800: Color(0xfff03402),
    900: Color(0xfff03402),
  });
  @override
  Widget build(BuildContext context) {
    var localizationsDelegates2 = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: localizationsDelegates2,
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
      ],
      locale: const Locale('de'),
      title: 'Authentication Demo',
      theme: ThemeData(
        primarySwatch: myPrimaryColor,
        primaryColor: myPrimaryColor,
      ),
      home: page,
    );
  }
}

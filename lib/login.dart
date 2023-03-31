import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' show ascii, base64, base64Encode, json, jsonDecode, utf8;
import 'dart:io';
import 'home.dart';
import 'main.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'package:get/get.dart';
import 'dart:convert' show base64Encode, jsonDecode, utf8;

import 'package:encrypt/encrypt.dart' as enc;

class LoginPage extends StatelessWidget {
  final storage = FlutterSecureStorage();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              child: Text('WEITER'),
              onPressed: () {
                Get.off(LoginPage());
              },
            ),
          ],
        ),
      );

  static Future<String?> attemptLogIn(String username, String password) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    var res = await http.get(
      Uri.parse('$SERVER_IP/login'),
      headers: {HttpHeaders.authorizationHeader: basicAuth},
    );
    if (res.statusCode == 200) {
      final token = jsonDecode(res.body)['token'];
      final isAdmin = jsonDecode(res.body)['admin'];
      FlutterSecureStorage().write(key: "jwt", value: isAdmin.toString());
      print('adminstatus: ' + isAdmin.toString());
      return token;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hermanndaten - bitte Einloggen"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Benutzername'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Passwort'),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                    onPressed: () async {
                      var username = _usernameController.text;
                      var password = _passwordController.text;
                      var mytoken = await attemptLogIn(username, password);
                      if (mytoken != null) {
                        storage.write(key: "jwt", value: mytoken);
                        print(mytoken);
                        storage.write(key: "username", value: username);
                        Get.off(() => MissedClassPage());
                      } else {
                        displayDialog(context, "Authentifizierungsfehler",
                            "Kein Konto mit diesem Benutzername/Passwort!");
                      }
                    },
                    child: Text(
                      "EINLOGGEN",
                      style: TextStyle(fontSize: 17.0),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                    onPressed: () async {
                      Get.to(() => QRScanCredentials());
                    },
                    child: Text(
                      "SCANNEN",
                      style: TextStyle(fontSize: 17.0),
                    )),
              ),
            ],
          ),
        ));
  }
}

class QRScanCredentials extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanCredentialsState();
}

class _QRScanCredentialsState extends State<QRScanCredentials> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final storage = FlutterSecureStorage();

  Future<String> _pinDialog(BuildContext context) async {
    final String valueText = await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _textFieldController = TextEditingController();
          late String thisvaluetext;
          return AlertDialog(
            title: Text('PIN eingeben'),
            content: TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  thisvaluetext = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Bitte PIN eingeben!"),
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

  loginQR(result) async {
    print('login läuft');
    final keyutf8 = await rootBundle.loadString('assets/keys/keyaes256cbc.txt');
    final ivutf8 = await rootBundle.loadString('assets/keys/ivaes256cbc.txt');
    final key = enc.Key.fromUtf8(keyutf8);
    final iv = enc.IV.fromUtf8(ivutf8);
    final encryptedResult = enc.Encrypted.fromBase64(result.code);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final decryptedCredentials = encrypter.decrypt(encryptedResult, iv: iv);
    final pin = await _pinDialog(context);
    if (pin == 'none') {
      Get.off(LoginPage());
      return;
    }
    var username = decryptedCredentials.split('*').first;
    var password = decryptedCredentials.split('*').last;
    password = password.trim();
    password = password + pin;

    var mytoken = await LoginPage.attemptLogIn(username, password);
    if (mytoken != null) {
      storage.write(key: "jwt", value: mytoken);
      print(mytoken);
      storage.write(key: "username", value: username);
      Get.off(() => MissedClassPage(), arguments: "Gesamt");
    } else {
      LoginPage.displayDialog(context, "Authentifizierungsfehler",
          "Kein Konto mit diesem Benutzername/Passwort!");
    }
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
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
        ? 150.0
        : 300.0;
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
      controller.stopCamera();
      controller.dispose();
      loginQR(scanData);

      // setState(() {
      //   result = scanData;
      // });
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

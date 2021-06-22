import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _defaultScannerOutput = '-1'; // Default value returned by the scanner plugin
  String _scanBarcode = '';

  @override
  void initState() {
    super.initState();
    _scanBarcode = _defaultScannerOutput;
  }

  Future<void> checkResultFromScanner(String barcodeScanRes) async {
    var response = await http.get(Uri.parse('http://85.234.139.82:8081/api/ticketValidate?id=' + barcodeScanRes));
    setState(() {
      _scanBarcode = response.statusCode.toString();
    });
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);

      if (barcodeScanRes != _defaultScannerOutput) {
        await checkResultFromScanner(barcodeScanRes);
      } else {
        setState(() {
          _scanBarcode = barcodeScanRes;
        });
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Color? getCorrectColorFromHttpStatusCode(String statusCode) {
    switch (statusCode) {
      case '-1': // _defaultScannerOutput
        return Colors.white;
      case '200': // Success -> Valid ticked
      case '201':
        return Colors.green[200];
      case '402': // Fail -> Ticked was not payed yet
        return Colors.orange[200];
      case '406': // Fail?? -> Ticked was already used one time
        return Colors.yellow[200];
      default: // Fail -> Ticked not found (also catchs any other exception)
        return Colors.red[200];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Builder(builder: (BuildContext context) {
          return Container(
              color: _scanBarcode == _defaultScannerOutput ? Colors.white : (_scanBarcode == '200' ? Colors.green[200] : Colors.red[200]),
              alignment: Alignment.center,
              child: Flex(direction: Axis.vertical, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                ElevatedButton(onPressed: () => scanBarcode(), child: Text('Scan QR/Barcode', style: TextStyle(fontSize: 25))),
                Visibility(
                    visible: _scanBarcode == _defaultScannerOutput ? false : true,
                    child: Column(
                      children: [
                        Text('$_scanBarcode\n', style: TextStyle(fontSize: 25)),
                        // ElevatedButton(
                        //     // onPressed: () => browseUrl(_scanBarcode),
                        //     onPressed: () => testLink(),
                        //     child: Text('Browse')),
                      ],
                    )),
              ]));
        })));
  }
}

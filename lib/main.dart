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
  String _defaultScannerOutput = '-1'; // Default value returned by the scanner plugin
  String _scanBarcode = '';

  @override
  void initState() {
    super.initState();
    _scanBarcode = _defaultScannerOutput;
  }

  Future<void> checkResultFromScanner(String barcodeScanRes) async {
    String successOrFailure = '';
    // TODO ..it should use the barcodeScanRes and correct endpoint to test if ticket/id is valid..for now dummy logic
    if (DateTime.now().second % 2 == 0) {
      successOrFailure = '200';
    } else {
      successOrFailure = '500';
    }
    var response = await http.get(Uri.parse('https://httpbin.org/status/' + successOrFailure));
    if (response.statusCode == 200) {
      // var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      // var itemCount = jsonResponse['totalItems'];
      // TODO - treat logic here - for now dummy colour
      setState(() {
        _scanBarcode = successOrFailure;
      });
    } else {
      // TODO - error communicating with server..or qr code is invalid - for now dummy colour
      setState(() {
        _scanBarcode = successOrFailure;
      });
    }
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);

      if (barcodeScanRes != _defaultScannerOutput) {
        await checkResultFromScanner(barcodeScanRes); // TODO ... this should be the ticket/ID to be sent to server later
      } else {
        setState(() {
          _scanBarcode = barcodeScanRes;
        });
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
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

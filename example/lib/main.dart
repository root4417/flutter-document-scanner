import 'dart:io';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:flutter_document_scanner/configs/configs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  PDFDocument? _scannedDocument;
  File? _scannedDocumentFile;
  File? _scannedImage;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterDocumentScanner.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }


  openPdfScanner(BuildContext context) async {
    var doc = await FlutterDocumentScanner.launchForPdf(
      context,
      labelsConfig: {
        ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next Steps",
        ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_SINGLE: "Only 1 Page",
        ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_MULTIPLE:
        "Only {PAGES_COUNT} Page"
      },
      //source: ScannerFileSource.CAMERA
    );
    if (doc != null) {
      _scannedDocument = null;
      setState(() {});
      await Future.delayed(Duration(milliseconds: 100));
      _scannedDocumentFile = doc;
      _scannedDocument = await PDFDocument.fromFile(doc);
      setState(() {});
    }
  }

  openImageScanner(BuildContext context) async {
    var image = await FlutterDocumentScanner.launch(context,
        //source: ScannerFileSource.CAMERA,
        labelsConfig: {
          ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next Step",
          ScannerLabelsConfig.ANDROID_OK_LABEL: "OK"
        });
    if (image != null) {
      _scannedImage = image;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Document Scanner Demo'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Running on: $_platformVersion\n'),
            if (_scannedDocument != null || _scannedImage != null) ...[
              if (_scannedImage != null)
                Image.file(_scannedImage!,
                    width: 300, height: 300, fit: BoxFit.contain),
              if (_scannedDocument != null)
                Expanded(
                    child: PDFViewer(
                      document: _scannedDocument!,
                    )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    _scannedDocumentFile?.path ?? _scannedImage?.path ?? ''),
              ),
            ],
            Center(
              child: Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () => openPdfScanner(context),
                    child: const Text("PDF Scan"));
              }),
            ),
            Center(
              child: Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () => openImageScanner(context),
                    child: const Text("Image Scan"));
              }),
            )
          ],
        ),
      ),
    );
  }
}

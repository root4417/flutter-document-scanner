import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:flutter_document_scanner/flutter_document_scanner_platform_interface.dart';
import 'package:flutter_document_scanner/flutter_document_scanner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterDocumentScannerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterDocumentScannerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterDocumentScannerPlatform initialPlatform = FlutterDocumentScannerPlatform.instance;

  test('$MethodChannelFlutterDocumentScanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterDocumentScanner>());
  });

  test('getPlatformVersion', () async {
    MockFlutterDocumentScannerPlatform fakePlatform = MockFlutterDocumentScannerPlatform();
    FlutterDocumentScannerPlatform.instance = fakePlatform;

    expect(await FlutterDocumentScanner.getPlatformVersion(), '42');
  });
}

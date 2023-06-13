import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_document_scanner/flutter_document_scanner_method_channel.dart';

void main() {
  MethodChannelFlutterDocumentScanner platform = MethodChannelFlutterDocumentScanner();
  const MethodChannel channel = MethodChannel('flutter_document_scanner');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

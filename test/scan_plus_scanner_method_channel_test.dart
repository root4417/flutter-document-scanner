import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_plus/scan_plus_method_channel.dart';

void main() {
  MethodChannelScanPlusDocumentScanner platform = MethodChannelScanPlusDocumentScanner();
  const MethodChannel channel = MethodChannel('scan_plus');

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

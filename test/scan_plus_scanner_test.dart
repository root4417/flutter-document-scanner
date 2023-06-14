import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:scan_plus/scan_plus.dart';
import 'package:scan_plus/scan_plus_method_channel.dart';
import 'package:scan_plus/scan_plus_platform_interface.dart';

class MockFlutterDocumentScannerPlatform
    with MockPlatformInterfaceMixin
    implements ScanPlusDocumentScannerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScanPlusDocumentScannerPlatform initialPlatform = ScanPlusDocumentScannerPlatform.instance;

  test('$MethodChannelScanPlusDocumentScanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScanPlusDocumentScanner>());
  });

  test('getPlatformVersion', () async {
    MockFlutterDocumentScannerPlatform fakePlatform = MockFlutterDocumentScannerPlatform();
    ScanPlusDocumentScannerPlatform.instance = fakePlatform;

    expect(await ScanPlusDocumentScanner.getPlatformVersion(), '42');
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:scan_plus/scan_plus_platform_interface.dart';


/// An implementation of [ScanPlusDocumentScannerPlatform] that uses method channels.
class MethodChannelScanPlusDocumentScanner extends ScanPlusDocumentScannerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('scan_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }







}

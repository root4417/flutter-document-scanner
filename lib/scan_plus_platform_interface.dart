import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:scan_plus/scan_plus_method_channel.dart';


abstract class ScanPlusDocumentScannerPlatform extends PlatformInterface {
  /// Constructs a FlutterDocumentScannerPlatform.
  ScanPlusDocumentScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScanPlusDocumentScannerPlatform _instance = MethodChannelScanPlusDocumentScanner();

  /// The default instance of [ScanPlusDocumentScannerPlatform] to use.
  ///
  /// Defaults to [MethodChannelScanPlusDocumentScanner].
  static ScanPlusDocumentScannerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScanPlusDocumentScannerPlatform] when
  /// they register themselves.
  static set instance(ScanPlusDocumentScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

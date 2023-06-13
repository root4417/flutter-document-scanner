import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_document_scanner_method_channel.dart';

abstract class FlutterDocumentScannerPlatform extends PlatformInterface {
  /// Constructs a FlutterDocumentScannerPlatform.
  FlutterDocumentScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDocumentScannerPlatform _instance = MethodChannelFlutterDocumentScanner();

  /// The default instance of [FlutterDocumentScannerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterDocumentScanner].
  static FlutterDocumentScannerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterDocumentScannerPlatform] when
  /// they register themselves.
  static set instance(FlutterDocumentScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

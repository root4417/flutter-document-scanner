#import "ScanPlusPlugin.h"
#if __has_include(<scan_plus/scan_plus-Swift.h>)
#import <scan_plus/scan_plus-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "scan_plus-Swift.h"
#endif

@implementation ScanPlusPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftScanPlusPlugin registerWithRegistrar:registrar];
}
@end

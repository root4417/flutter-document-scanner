import Flutter
import UIKit
import WeScan

public class SwiftScanPlusPlugin: NSObject, FlutterPlugin {
    var rootViewController: UIViewController?
    var result: FlutterResult?


    public override init() {
        super.init()
        rootViewController = (UIApplication.shared.delegate?.window??.rootViewController)!;
    }
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Utils.channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftScanPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        typealias channelMethod = () -> ()
        var channelMethods : Dictionary = [String : channelMethod]()
        channelMethods["camera"] = camera
        channelMethods["gallery"] = gallery
        channelMethods["getPlatformVersion"] = getPlatformVersion
        if(!channelMethods.keys.contains(call.method)){
          result(FlutterMethodNotImplemented)
        }

        //     channelMethods[call.method]!();
        //     result("iOS " + UIDevice.current.systemVersion)
    }

    private func camera() {
        let scannerViewController: ImageScannerController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        scannerViewController.modalPresentationStyle = .fullScreen

        if #available(iOS 13.0, *) {
          scannerViewController.overrideUserInterfaceStyle = .dark
        }

        rootViewController?.present(scannerViewController, animated:true, completion:nil)
    }

    private func getPlatformVersion(){
        result?("iOS " + UIDevice.current.systemVersion)
    }

    private func gallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen

        rootViewController?.present(imagePicker, animated: true)
    }
}

extension SwiftScanPlusPlugin : ImageScannerControllerDelegate{

    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true)
        let path = Utils.getScannedFile(results: results)
        result?(path)
    }

    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true)
    }

    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        scanner.dismiss(animated: true)
    }
}

extension SwiftScanPlusPlugin: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }
        pikedCamera(image: image)
    }

    private func pikedCamera(image: UIImage? = nil){
        let scannerViewController: ImageScannerController = ImageScannerController(image:image)
        scannerViewController.imageScannerDelegate = self
        scannerViewController.modalPresentationStyle = .fullScreen

        if #available(iOS 13.0, *) {
            scannerViewController.overrideUserInterfaceStyle = .dark
        }
        rootViewController?.present(scannerViewController, animated:true, completion:nil)
    }
}
import Flutter
import UIKit

public class ApliarteFlutterConnectPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.apliarte.flutter_connect/methods",
      binaryMessenger: registrar.messenger()
    )
    let instance = ApliarteFlutterConnectPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      result(nil)
    case "getCapabilities":
      result([
        "platformName": "ios-\(UIDevice.current.systemVersion)",
        "supportsDiscovery": false,
        "supportsAdvertising": false,
        "supportsLocalNetworkTransport": false,
        "supportsPermissionRequests": false,
        "supportedRoles": ["host", "viewer"]
      ])
    case "checkPermissions", "requestPermissions":
      let arguments = call.arguments as? [String: Any]
      result([
        "useCase": arguments?["useCase"] as? String ?? "discoveryOnly",
        "status": "unknown",
        "requiredPermissions": ["localNetwork"],
        "missingPermissions": ["localNetwork"],
        "canRequest": false,
        "message": "Native permission mapping is not implemented yet."
      ])
    case "startDiscovery", "stopDiscovery", "dispose":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

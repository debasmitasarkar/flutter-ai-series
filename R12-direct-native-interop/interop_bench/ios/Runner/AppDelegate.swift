import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // The platform-channel baseline: the same calls the FFIgen bindings make.
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BenchChannel")!
    let channel = FlutterMethodChannel(name: "bench", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "uptime": result(ProcessInfo.processInfo.systemUptime)
      case "osVersion": result(ProcessInfo.processInfo.operatingSystemVersionString)
      case "isMainThread": result(Thread.isMainThread)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }
}

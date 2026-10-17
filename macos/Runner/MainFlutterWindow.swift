import Cocoa
import FlutterMacOS
import SystemConfiguration

class MainFlutterWindow: NSWindow {
  private var platformChannel: FlutterMethodChannel?
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    platformChannel = FlutterMethodChannel(
      name: "dukto2/platform",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    platformChannel?.setMethodCallHandler { call, result in
      if call.method == "getDeviceName" {
        let computerName = SCDynamicStoreCopyComputerName(nil, nil) as String?
        result(computerName ?? Host.current().localizedName)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}

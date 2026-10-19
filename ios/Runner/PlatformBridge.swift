import Flutter
import Network
import UIKit
import UniformTypeIdentifiers
import UserNotifications

final class PlatformBridge: NSObject, UIDocumentPickerDelegate, UIAdaptivePresentationControllerDelegate, UNUserNotificationCenterDelegate {
  private let channel: FlutterMethodChannel
  private let storage = ReceiveStorage()
  private let discovery = BonjourDiscovery()
  private let monitor = NWPathMonitor()
  private var folderResult: FlutterResult?
  private weak var directoryBrowser: UIDocumentPickerViewController?
  private var directoryRelease: (() -> Void)?
  private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "dukto2/platform", binaryMessenger: messenger)
    super.init()
    UNUserNotificationCenter.current().delegate = self
    discovery.onEndpoint = { [weak self] host, port in
      self?.channel.invokeMethod("discoveredEndpoint", arguments: ["host": host, "port": port])
    }
    discovery.onError = { [weak self] message in
      self?.channel.invokeMethod("discoveryUnavailable", arguments: message)
    }
    monitor.pathUpdateHandler = { [weak self] _ in
      DispatchQueue.main.async { self?.channel.invokeMethod("networkChanged", arguments: nil) }
    }
    monitor.start(queue: DispatchQueue(label: "dev.dukto2.network-path"))
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result(FlutterError(code: "CLOSED", message: "应用已退出", details: nil)); return }
      if self.storage.handle(call, result: result) { return }
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "getDeviceName": result(UIDevice.current.name)
      case "getDeviceType":
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: result("tablet")
        case .phone: result("phone")
        case .mac: result("computer")
        default: result("unknown")
        }
      case "startDiscovery":
        guard let id = args["id"] as? String, let port = args["port"] as? Int, (1...65535).contains(port) else {
          result(FlutterError(code: "DISCOVERY", message: "无效的服务端口", details: nil)); return
        }
        self.discovery.start(id: id, port: port); result(nil)
      case "stopDiscovery": self.discovery.stop(); result(nil)
      case "startTransfer":
        if self.backgroundTask == .invalid {
          self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "Dukto2 transfer") { [weak self] in
            guard let self, self.backgroundTask != .invalid else { return }
            self.channel.invokeMethod("transferStopped", arguments: "expired")
            self.endBackgroundTask()
          }
          guard self.backgroundTask != .invalid else {
            result(FlutterError(code: "BACKGROUND", message: "请返回前台开始传输", details: nil)); return
          }
        }
        result(nil)
      case "stopTransfer": self.endBackgroundTask(); result(nil)
      case "keepAwake": UIApplication.shared.isIdleTimerDisabled = call.arguments as? Bool ?? false; result(nil)
      case "chooseReceiveFolder":
        guard self.folderResult == nil, let presenter = self.presenter else {
          result(FlutterError(code: "BUSY", message: "请关闭当前系统窗口后重试", details: nil)); return
        }
        self.folderResult = result
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        picker.delegate = self; picker.allowsMultipleSelection = false
        picker.modalPresentationStyle = .formSheet
        presenter.present(picker, animated: true)
      case "openHistoryDirectory":
        if let uri = args["receivedUri"] as? String {
          self.storage.withReceived(uri, body: { url, release in
            try self.browseDirectory(of: url, release: release)
          }, result: result)
        } else {
          guard let raw = args["sourceUri"] as? String ?? (args["path"] as? String).map({ URL(fileURLWithPath: $0).absoluteString }),
                let url = URL(string: raw), url.isFileURL else {
            result(FlutterError(code: "DIRECTORY", message: "没有可用的文件位置", details: nil)); return
          }
          let scoped = url.startAccessingSecurityScopedResource()
          guard scoped || url.standardizedFileURL.path.hasPrefix(NSHomeDirectory() + "/"),
                FileManager.default.fileExists(atPath: url.path) else {
            if scoped { url.stopAccessingSecurityScopedResource() }
            result(FlutterError(code: "DIRECTORY", message: "文件已移动或访问权限已失效", details: nil)); return
          }
          do {
            try self.browseDirectory(of: url, release: { if scoped { url.stopAccessingSecurityScopedResource() } })
            result(nil)
          } catch {
            if scoped { url.stopAccessingSecurityScopedResource() }
            result(FlutterError(code: "DIRECTORY", message: error.localizedDescription, details: nil))
          }
        }
      case "openReceived":
        guard let uri = args["uri"] as? String else { result(FlutterMethodNotImplemented); return }
        self.storage.withReceived(uri, body: { [weak self] url, release in
          guard let presenter = self?.presenter else {
            throw NSError(domain: "Dukto2.Export", code: 1, userInfo: [NSLocalizedDescriptionKey: "请返回 Dukto2 后重试"])
          }
          let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
          share.completionWithItemsHandler = { _, _, _, _ in release() }
          if let popover = share.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
            popover.permittedArrowDirections = []
          }
          presenter.present(share, animated: true)
        }, result: result)
      case "notificationStatus": self.notificationStatus(result)
      case "requestNotifications":
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
          if let error { DispatchQueue.main.async { result(FlutterError(code: "NOTIFICATIONS", message: error.localizedDescription, details: nil)) } }
          else { self.notificationStatus(result) }
        }
      case "openNotificationSettings":
        let settings: String
        if #available(iOS 16, *) { settings = UIApplication.openNotificationSettingsURLString }
        else { settings = UIApplication.openSettingsURLString }
        UIApplication.shared.open(URL(string: settings)!) { opened in
          result(opened ? nil : FlutterError(code: "NOTIFICATIONS", message: "请在系统设置中检查通知权限", details: nil))
        }
      case "notifyComplete":
        let content = UNMutableNotificationContent()
        content.title = args["title"] as? String ?? "Transfer complete"
        content.body = args["body"] as? String ?? "Content verified"
        content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "dukto2-completion", content: content, trigger: nil)) { error in
          DispatchQueue.main.async {
            if let error { result(FlutterError(code: "NOTIFICATIONS", message: error.localizedDescription, details: nil)) }
            else { result(nil) }
          }
        }
      default: result(FlutterMethodNotImplemented)
      }
    }
  }
  private func browseDirectory(of file: URL, release: @escaping () -> Void) throws {
    guard directoryRelease == nil, folderResult == nil, let presenter else {
      throw NSError(domain: "Dukto2.Directory", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "请关闭当前文件窗口后重试"])
    }
    let browser = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: false)
    browser.directoryURL = file.deletingLastPathComponent()
    browser.shouldShowFileExtensions = true
    browser.allowsMultipleSelection = false
    browser.delegate = self
    browser.modalPresentationStyle = .formSheet
    directoryBrowser = browser
    directoryRelease = release
    presenter.present(browser, animated: true)
    browser.presentationController?.delegate = self
  }
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if let browser = presentationController.presentedViewController as? UIDocumentPickerViewController {
      _ = closeDirectoryBrowser(browser)
    }
  }
  private func closeDirectoryBrowser(_ controller: UIDocumentPickerViewController) -> Bool {
    guard controller === directoryBrowser else { return false }
    directoryRelease?(); directoryRelease = nil; directoryBrowser = nil
    return true
  }
  private var presenter: UIViewController? {
    var controller = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }.first(where: { $0.isKeyWindow })?.rootViewController
    while let presented = controller?.presentedViewController { controller = presented }
    return controller
  }
  private func endBackgroundTask() {
    guard backgroundTask != .invalid else { return }
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
  }
  private func notificationStatus(_ result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      let value: String
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral: value = "granted"
      case .notDetermined: value = "notDetermined"
      default: value = "denied"
      }
      DispatchQueue.main.async { result(value) }
    }
  }
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    if closeDirectoryBrowser(controller) { return }
    let result = folderResult; folderResult = nil; result?(nil)
  }
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    if closeDirectoryBrowser(controller) { return }
    guard let result = folderResult else { return }
    folderResult = nil
    guard let url = urls.first else { result(nil); return }
    storage.select(url, result: result)
  }
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .sound])
  }
}

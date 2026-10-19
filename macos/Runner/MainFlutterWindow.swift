import Cocoa
import FlutterMacOS
import SystemConfiguration
import UserNotifications

class MainFlutterWindow: NSWindow {
  private let receiveFolders = ReceiveFolders()
  private let notifications = CompletionAlerts()
  private let bonjour = BonjourDiscovery()
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
    bonjour.onEndpoint = { [weak self] host, port in
      self?.platformChannel?.invokeMethod("discoveredEndpoint", arguments: ["host": host, "port": port])
    }
    platformChannel?.setMethodCallHandler { [weak self] call, result in
      if call.method == "startDiscovery" {
        let data = call.arguments as? [String: Any] ?? [:]
        if let id = data["id"] as? String, let port = data["port"] as? Int {
          self?.bonjour.start(id: id, port: port)
        }
        result(nil)
      } else if call.method == "stopDiscovery" {
        self?.bonjour.stop(); result(nil)
      } else if call.method == "notificationStatus" {
        self?.notifications.status(result)
      } else if call.method == "requestNotifications" {
        self?.notifications.request(result)
      } else if call.method == "notifyComplete" {
        let data = call.arguments as? [String: String] ?? [:]
        self?.notifications.show(title: data["title"] ?? "传输完成", body: data["body"] ?? "内容已校验完成", result: result)
      } else if call.method == "openNotificationSettings" {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.systempreferences"), NSWorkspace.shared.open(url) {
          result(nil)
        } else { result(FlutterError(code: "NOTIFICATIONS", message: "请打开系统设置中的通知", details: nil)) }
      } else if call.method == "getDeviceName" {
        let computerName = SCDynamicStoreCopyComputerName(nil, nil) as String?
        result(computerName ?? Host.current().localizedName)
      } else if call.method == "receiveLocation" {
        result(self?.receiveFolders.location())
      } else if call.method == "resetReceiveFolder" {
        self?.receiveFolders.reset()
        result(nil)
      } else if call.method == "chooseReceiveFolder", let window = self {
        let panel = NSOpenPanel()
        panel.title = "选择 Dukto2 接收文件夹"
        panel.prompt = "选择文件夹"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { response in
          guard response == .OK, let url = panel.url else { result(nil); return }
          do {
            try window.receiveFolders.select(url)
            result(window.receiveFolders.location())
          } catch {
            result(FlutterError(code: "STORAGE", message: error.localizedDescription, details: nil))
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}

private final class CompletionAlerts: NSObject, UNUserNotificationCenterDelegate {
  private let center = UNUserNotificationCenter.current()
  override init() { super.init(); center.delegate = self }
  private func label(_ value: UNAuthorizationStatus) -> String {
    switch value {
    case .authorized, .provisional: return "granted"
    case .notDetermined: return "notDetermined"
    default: return "denied"
    }
  }
  func status(_ result: @escaping FlutterResult) {
    center.getNotificationSettings { settings in
      DispatchQueue.main.async { result(self.label(settings.authorizationStatus)) }
    }
  }
  func request(_ result: @escaping FlutterResult) {
    center.requestAuthorization(options: [.alert, .sound]) { _, error in
      if let error = error {
        DispatchQueue.main.async { result(FlutterError(code: "NOTIFICATIONS", message: error.localizedDescription, details: nil)) }
      } else { self.status(result) }
    }
  }
  func show(title: String, body: String, result: @escaping FlutterResult) {
    center.getNotificationSettings { settings in
      guard self.label(settings.authorizationStatus) == "granted" else {
        DispatchQueue.main.async { result(nil) }; return
      }
      let content = UNMutableNotificationContent()
      content.title = title; content.body = body; content.sound = .default
      self.center.add(UNNotificationRequest(identifier: "dukto2-completion", content: content, trigger: nil)) { error in
        DispatchQueue.main.async {
          if let error = error { result(FlutterError(code: "NOTIFICATIONS", message: error.localizedDescription, details: nil)) }
          else { result(nil) }
        }
      }
    }
  }
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .sound])
  }
}

// Persistent sandbox authorization is owned by the native process so Dart file
// streams keep access for the whole transfer and history remains accessible.
private final class ReceiveFolders {
  private let defaults = UserDefaults.standard
  private let currentKey = "receive-folder-path-v1"
  private let bookmarksKey = "receive-folder-bookmarks-v1"
  private var scopes: [URL] = []
  private var restored = false

  deinit { scopes.forEach { $0.stopAccessingSecurityScopedResource() } }

  private func restore() {
    guard !restored else { return }
    restored = true
    var bookmarks = defaults.dictionary(forKey: bookmarksKey) as? [String: Data] ?? [:]
    for (path, data) in bookmarks {
      do {
        var stale = false
        let url = try URL(resolvingBookmarkData: data, options: [.withSecurityScope],
                          relativeTo: nil, bookmarkDataIsStale: &stale)
        if url.startAccessingSecurityScopedResource() {
          scopes.append(url)
          if stale {
            bookmarks[path] = try url.bookmarkData(options: [.withSecurityScope],
                includingResourceValuesForKeys: nil, relativeTo: nil)
          }
          if defaults.string(forKey: currentKey) == path && url.path != path {
            defaults.set(url.path, forKey: currentKey)
          }
        }
      } catch { /* The current folder error is reported by location, never redirected. */ }
    }
    defaults.set(bookmarks, forKey: bookmarksKey)
  }

  private func defaultFolder() -> URL {
    FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("Dukto2", isDirectory: true).resolvingSymlinksInPath()
  }

  private func validate(_ url: URL) throws {
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    let probe = url.appendingPathComponent(".dukto2-access-" + UUID().uuidString)
    try Data().write(to: probe, options: [.withoutOverwriting])
    try FileManager.default.removeItem(at: probe)
  }

  func reset() { defaults.removeObject(forKey: currentKey) }

  func location() -> [String: Any] {
    restore()
    let custom = defaults.string(forKey: currentKey)
    let url = custom.map { URL(fileURLWithPath: $0) } ?? defaultFolder()
    var answer: [String: Any] = ["direct": true, "path": url.path, "custom": custom != nil,
        "label": custom == nil ? "下载 / Dukto2" : url.path,
        "roots": scopes.map { $0.path } + [defaultFolder().path]]
    do {
      try validate(url)
      answer["available"] = true
    } catch {
      answer["available"] = false
      answer["error"] = "无法访问接收文件夹，请重新选择：" + error.localizedDescription
    }
    return answer
  }

  func select(_ url: URL) throws {
    restore()
    let scoped = url.startAccessingSecurityScopedResource()
    do {
      try validate(url)
      let bookmark = try url.bookmarkData(options: [.withSecurityScope],
          includingResourceValuesForKeys: nil, relativeTo: nil)
      var bookmarks = defaults.dictionary(forKey: bookmarksKey) as? [String: Data] ?? [:]
      bookmarks[url.path] = bookmark
      defaults.set(bookmarks, forKey: bookmarksKey)
      defaults.set(url.path, forKey: currentKey)
      if scoped { scopes.append(url) }
    } catch {
      if scoped { url.stopAccessingSecurityScopedResource() }
      throw error
    }
  }
}

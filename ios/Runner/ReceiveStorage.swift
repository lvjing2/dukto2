import CryptoKit
import Flutter
import Foundation

// Incoming bytes stay in private staging. External file providers are accessed
// only inside a coordinated commit; the final name appears after verification.
final class ReceiveStorage {
  private typealias Record = [String: String]
  private let defaults: UserDefaults
  private let documentsDirectory: URL
  private let supportDirectory: URL
  private let worker = DispatchQueue(label: "dev.dukto2.receive-storage")
  private let fm = FileManager.default
  private var stages: [String: Stage] = [:]
  private var pending: [String: Record] = [:]
  private var recovered = false
  init(documentsDirectory: URL? = nil, supportDirectory: URL? = nil, defaults: UserDefaults = .standard) {
    self.defaults = defaults
    self.documentsDirectory = documentsDirectory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    self.supportDirectory = supportDirectory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
  }
  private var base: URL { supportDirectory.appendingPathComponent("Dukto2Staging", isDirectory: true) }
  private var standard: URL { documentsDirectory.appendingPathComponent("接收文件", isDirectory: true) }
  private var journal: URL { base.appendingPathComponent("pending.json") }
  private var selected: String { defaults.string(forKey: "dukto2.receive-folder") ?? "default" }
  private struct Stage {
    let record: Record
    let size: Int64
    var bytes: Int64 = 0
    var output: FileHandle?
  }
  private struct Access {
    let url: URL
    let scoped: Bool
    func close() { if scoped { url.stopAccessingSecurityScopedResource() } }
  }
  private func failure(_ message: String) -> NSError {
    NSError(domain: "Dukto2.Storage", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
  }
  private func validID(_ id: String) -> Bool { id.range(of: "^[a-f0-9]{48}$", options: .regularExpression) != nil }
  private func partial(_ id: String) -> URL { base.appendingPathComponent("\(id).partial") }
  private func saveJournal() throws {
    try JSONSerialization.data(withJSONObject: pending).write(to: journal, options: .atomic)
  }
  private func root(_ key: String) throws -> Access {
    if key == "default" {
      try fm.createDirectory(at: standard, withIntermediateDirectories: true)
      return Access(url: standard, scoped: false)
    }
    guard let data = (defaults.dictionary(forKey: "dukto2.folder-bookmarks") as? [String: Data])?[key] else {
      throw failure("接收文件夹授权已失效，请重新选择")
    }
    var stale = false
    let url = try URL(resolvingBookmarkData: data, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &stale)
    let scoped = url.startAccessingSecurityScopedResource()
    guard scoped || url.path.hasPrefix(NSHomeDirectory() + "/") else {
      throw failure("无法访问接收文件夹，请重新选择")
    }
    return Access(url: url, scoped: scoped)
  }
  private func coordinated(_ url: URL, body: (URL) throws -> Void) throws {
    var coordinationError: NSError?
    var operationError: Error?
    NSFileCoordinator().coordinate(writingItemAt: url, options: .forMerging, error: &coordinationError) { writable in
      do { try body(writable) } catch { operationError = error }
    }
    if let error = operationError ?? coordinationError { throw error }
  }
  private func clean(_ id: String, record: Record) throws {
    if fm.fileExists(atPath: partial(id).path) { try fm.removeItem(at: partial(id)) }
    let access = try root(record["root"] ?? "default")
    defer { access.close() }
    try coordinated(access.url) { directory in
      let folder = directory.appendingPathComponent(id, isDirectory: true)
      let staging = folder.appendingPathComponent(".partial")
      if self.fm.fileExists(atPath: staging.path) { try self.fm.removeItem(at: staging) }
      if self.fm.fileExists(atPath: folder.path), try self.fm.contentsOfDirectory(atPath: folder.path).isEmpty {
        try self.fm.removeItem(at: folder)
      }
      // A published name is the commit point and is never removed by cleanup.
    }
  }
  private func recover() throws {
    guard !recovered else { return }
    try fm.createDirectory(at: base, withIntermediateDirectories: true)
    var values = URLResourceValues(); values.isExcludedFromBackup = true
    var directory = base; try directory.setResourceValues(values)
    if fm.fileExists(atPath: journal.path) {
      guard let saved = try JSONSerialization.jsonObject(with: Data(contentsOf: journal)) as? [String: Record], saved.count <= 100 else {
        throw failure("无法读取未完成传输记录")
      }
      pending = saved
    }
    for (id, record) in pending where validID(id) {
      do { try clean(id, record: record); pending.removeValue(forKey: id) }
      catch { /* Retain only our journal entry for a temporarily unavailable provider. */ }
    }
    try saveJournal()
    recovered = true
  }
  func select(_ url: URL, result: @escaping FlutterResult) {
    worker.async {
      do {
        try self.recover()
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        guard scoped || url.path.hasPrefix(NSHomeDirectory() + "/") else { throw self.failure("无法获取文件夹授权") }
        let data = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        let key = UUID().uuidString
        var bookmarks = self.defaults.dictionary(forKey: "dukto2.folder-bookmarks") as? [String: Data] ?? [:]
        bookmarks[key] = data
        self.defaults.set(bookmarks, forKey: "dukto2.folder-bookmarks")
        self.defaults.set(key, forKey: "dukto2.receive-folder")
        let value = try self.location()
        DispatchQueue.main.async { result(value) }
      } catch { self.reply(error, result) }
    }
  }
  private func location() throws -> [String: Any] {
    do {
      let access = try root(selected); defer { access.close() }
      let label = selected == "default" ? "文件 / Dukto2 / 接收文件" :
        (access.url.standardizedFileURL == documentsDirectory.standardizedFileURL ? "文件 / Dukto2" : access.url.lastPathComponent)
      return ["direct": true, "available": true, "custom": selected != "default",
              "label": label,
              "kind": selected == "default" ? "documents" : "folder"]
    } catch {
      return ["direct": true, "available": false, "custom": selected != "default",
              "label": "接收文件夹不可用", "error": error.localizedDescription]
    }
  }
  private func reply(_ error: Error, _ result: @escaping FlutterResult) {
    DispatchQueue.main.async { result(FlutterError(code: "STORAGE", message: error.localizedDescription, details: nil)) }
  }
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> Bool {
    guard ["receiveLocation", "resetReceiveFolder", "prepareReceive", "writeReceive", "closeReceive", "commitReceive", "discardReceive"].contains(call.method) else { return false }
    worker.async {
      var preparedID: String?
      do {
        try self.recover()
        let args = call.arguments as? [String: Any] ?? [:]
        let id = args["id"] as? String ?? ""
        var value: Any?
        switch call.method {
        case "receiveLocation": value = try self.location()
        case "resetReceiveFolder": self.defaults.removeObject(forKey: "dukto2.receive-folder")
        case "prepareReceive":
          guard self.validID(id), self.stages[id] == nil, self.pending[id] == nil, self.pending.count < 100,
                let name = args["name"] as? String, !name.isEmpty, name.count <= 240,
                name != ".", name != "..", name != ".partial", !name.contains("/"), !name.contains("\\"),
                !name.unicodeScalars.contains(where: { $0.value < 32 }),
                let size = args["size"] as? NSNumber, size.int64Value >= 0 else { throw self.failure("无效的文件信息") }
          let access = try self.root(self.selected); access.close()
          let record = ["root": self.selected, "name": name]
          self.pending[id] = record
          preparedID = id
          try self.saveJournal()
          guard self.fm.createFile(atPath: self.partial(id).path, contents: nil) else { throw self.failure("无法创建接收暂存文件") }
          self.stages[id] = Stage(record: record, size: size.int64Value, output: try FileHandle(forWritingTo: self.partial(id)))
        case "writeReceive":
          guard var stage = self.stages[id], let bytes = args["bytes"] as? FlutterStandardTypedData,
                bytes.data.count <= 256 * 1024, stage.bytes + Int64(bytes.data.count) <= stage.size,
                let handle = stage.output else { throw self.failure("接收目标不可写") }
          try handle.write(contentsOf: bytes.data)
          stage.bytes += Int64(bytes.data.count); self.stages[id] = stage
        case "closeReceive":
          if var stage = self.stages[id] {
            try stage.output?.synchronize(); try stage.output?.close()
            stage.output = nil; self.stages[id] = stage
          }
        case "commitReceive": value = try self.commit(id, digest: args["sha256"] as? String ?? "")
        case "discardReceive":
          if let stage = self.stages.removeValue(forKey: id) { try stage.output?.close() }
          if let record = self.pending[id] {
            try self.clean(id, record: record); self.pending.removeValue(forKey: id); try self.saveJournal()
          }
        default: break
        }
        let response = value
        DispatchQueue.main.async { result(response) }
      } catch {
        if call.method == "prepareReceive" {
          if let id = preparedID, let record = self.pending[id] {
            try? self.stages.removeValue(forKey: id)?.output?.close()
            do { try self.clean(id, record: record); self.pending.removeValue(forKey: id); try self.saveJournal() }
            catch { /* Preserve the journal for recovery if the provider disappeared. */ }
          }
        }
        self.reply(error, result)
      }
    }
    return true
  }
  private func commit(_ id: String, digest: String) throws -> [String: String] {
    guard let stage = stages[id], stage.output == nil, stage.bytes == stage.size,
          digest.range(of: "^[a-f0-9]{64}$", options: .regularExpression) != nil else { throw failure("接收内容尚未校验完成") }
    let access = try root(stage.record["root"]!); defer { access.close() }
    try coordinated(access.url) { directory in
      let folder = directory.appendingPathComponent(id, isDirectory: true)
      guard !self.fm.fileExists(atPath: folder.path) else { throw self.failure("接收目标已存在") }
      try self.fm.createDirectory(at: folder, withIntermediateDirectories: false)
      let target = folder.appendingPathComponent(".partial")
      try self.fm.copyItem(at: self.partial(id), to: target)
      let input = try FileHandle(forReadingFrom: target)
      defer { try? input.close() }
      var hash = SHA256(); var size: Int64 = 0
      while let data = try input.read(upToCount: 256 * 1024), !data.isEmpty { hash.update(data: data); size += Int64(data.count) }
      let actual = hash.finalize().map { String(format: "%02x", $0) }.joined()
      guard size == stage.size, actual == digest else { throw self.failure("保存后的文件校验失败") }
      try self.fm.moveItem(at: target, to: folder.appendingPathComponent(stage.record["name"]!))
    }
    // The file is published. Later journal/history errors must not delete it.
    stages.removeValue(forKey: id)
    var completed = defaults.dictionary(forKey: "dukto2.completed") as? [String: Record] ?? [:]
    var record = stage.record; record["time"] = ISO8601DateFormatter().string(from: Date())
    completed[id] = record
    let keys = completed.keys.sorted { (completed[$0]?["time"] ?? "") > (completed[$1]?["time"] ?? "") }
    defaults.set(Dictionary(uniqueKeysWithValues: keys.prefix(100).map { ($0, completed[$0]!) }), forKey: "dukto2.completed")
    try? fm.removeItem(at: partial(id))
    pending.removeValue(forKey: id); try? saveJournal()
    return ["uri": "dukto2-received://\(id)"]
  }
  func withReceived(_ value: String, body: @escaping (URL, @escaping () -> Void) throws -> Void, result: @escaping FlutterResult) {
    worker.async {
      do {
        guard let uri = URL(string: value), uri.scheme == "dukto2-received", let id = uri.host, self.validID(id),
              let record = (self.defaults.dictionary(forKey: "dukto2.completed") as? [String: Record])?[id] else { throw self.failure("未知的接收文件") }
        let access = try self.root(record["root"]!)
        let url = access.url.appendingPathComponent(id).appendingPathComponent(record["name"]!)
        guard self.fm.fileExists(atPath: url.path) else { access.close(); throw self.failure("接收文件已移动或删除") }
        DispatchQueue.main.async {
          do { try body(url, { access.close() }); result(nil) }
          catch { access.close(); self.reply(error, result) }
        }
      } catch { self.reply(error, result) }
    }
  }
}

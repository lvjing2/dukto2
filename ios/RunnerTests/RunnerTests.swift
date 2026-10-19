import CryptoKit
import Flutter
import XCTest
@testable import Runner

final class RunnerTests: XCTestCase {
  private var directory: URL!
  private var defaults: UserDefaults!
  private var suite: String!
  private var documents: URL { directory.appendingPathComponent("Documents") }
  private var support: URL { directory.appendingPathComponent("Support") }
  private let id = String(repeating: "a", count: 48)
  private let fileName = "中文 emoji 🦆.bin"

  override func setUpWithError() throws {
    directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    suite = "Dukto2.Tests.\(UUID().uuidString)"
    defaults = UserDefaults(suiteName: suite)!
  }
  override func tearDownWithError() throws {
    defaults.removePersistentDomain(forName: suite)
    try FileManager.default.removeItem(at: directory)
  }
  private func storage() -> ReceiveStorage {
    ReceiveStorage(documentsDirectory: documents, supportDirectory: support, defaults: defaults)
  }
  private func digest(_ bytes: Data) -> String {
    SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
  }
  @MainActor
  @discardableResult
  private func call(_ storage: ReceiveStorage, _ method: String, _ arguments: [String: Any] = [:]) async throws -> Any? {
    try await withCheckedThrowingContinuation { continuation in
      XCTAssertTrue(storage.handle(FlutterMethodCall(methodName: method, arguments: arguments)) { value in
        if let error = value as? FlutterError {
          continuation.resume(throwing: NSError(domain: error.code, code: 1,
            userInfo: [NSLocalizedDescriptionKey: error.message ?? "Storage error"]))
        } else { continuation.resume(returning: value) }
      })
    }
  }
  @MainActor
  private func prepare(_ storage: ReceiveStorage, _ bytes: Data) async throws {
    try await call(storage, "prepareReceive", ["id": id, "name": fileName, "size": bytes.count])
    var offset = 0
    while offset < bytes.count {
      let end = min(offset + 256 * 1024, bytes.count)
      try await call(storage, "writeReceive", ["id": id, "bytes": FlutterStandardTypedData(bytes: bytes.subdata(in: offset..<end))])
      offset = end
    }
    try await call(storage, "closeReceive", ["id": id])
  }
  private var published: URL { documents.appendingPathComponent("接收文件/\(id)/\(fileName)") }
  private var partial: URL { support.appendingPathComponent("Dukto2Staging/\(id).partial") }

  @MainActor
  func testVerifiedCommitSurvivesStorageRestartAndCanExport() async throws {
    let bytes = Data((0..<800001).map { UInt8($0 % 251) })
    let receiver = storage()
    try await prepare(receiver, bytes)
    XCTAssertFalse(FileManager.default.fileExists(atPath: published.path))
    let receipt = try await call(receiver, "commitReceive", ["id": id, "sha256": digest(bytes)]) as! [String: String]
    XCTAssertEqual(try Data(contentsOf: published), bytes)
    XCTAssertFalse(FileManager.default.fileExists(atPath: partial.path))
    let restarted = storage()
    try await call(restarted, "receiveLocation")
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      restarted.withReceived(receipt["uri"]!, body: { url, release in
        defer { release() }
        XCTAssertEqual(try Data(contentsOf: url), bytes)
      }, result: { result in
        if let error = result as? FlutterError {
          continuation.resume(throwing: NSError(domain: error.code, code: 1))
        } else { continuation.resume() }
      })
    }
  }

  @MainActor
  func testCorruptCommitAndRestartCleanOnlyIncompleteFiles() async throws {
    let bytes = Data("actual content".utf8)
    let receiver = storage()
    try await prepare(receiver, bytes)
    do {
      try await call(receiver, "commitReceive", ["id": id, "sha256": String(repeating: "0", count: 64)])
      XCTFail("A corrupt file must never publish")
    } catch { }
    XCTAssertFalse(FileManager.default.fileExists(atPath: published.path))
    XCTAssertTrue(FileManager.default.fileExists(atPath: partial.path))
    let restarted = storage()
    try await call(restarted, "receiveLocation")
    XCTAssertFalse(FileManager.default.fileExists(atPath: partial.path))
    XCTAssertFalse(FileManager.default.fileExists(atPath: published.deletingLastPathComponent().path))
    try await prepare(restarted, bytes)
    try await call(restarted, "commitReceive", ["id": id, "sha256": digest(bytes)])
    XCTAssertEqual(try Data(contentsOf: published), bytes)
  }

  @MainActor
  func testChunkBoundAndDuplicatePrepareKeepOriginalStage() async throws {
    let receiver = storage()
    let bytes = Data("first stage".utf8)
    try await call(receiver, "prepareReceive", ["id": id, "name": fileName, "size": bytes.count])
    do {
      try await call(receiver, "prepareReceive", ["id": id, "name": fileName, "size": 0])
      XCTFail("Duplicate stage must be rejected")
    } catch { }
    do {
      try await call(receiver, "writeReceive", ["id": id, "bytes": FlutterStandardTypedData(bytes: Data(count: 256 * 1024 + 1))])
      XCTFail("Oversized writes must be rejected")
    } catch { }
    try await call(receiver, "writeReceive", ["id": id, "bytes": FlutterStandardTypedData(bytes: bytes)])
    try await call(receiver, "closeReceive", ["id": id])
    try await call(receiver, "commitReceive", ["id": id, "sha256": digest(bytes)])
    XCTAssertEqual(try Data(contentsOf: published), bytes)
  }

  @MainActor
  func testExistingDestinationIsNeverOverwrittenOrRemovedOnDiscard() async throws {
    let receiver = storage()
    let bytes = Data("incoming".utf8)
    try await prepare(receiver, bytes)
    try FileManager.default.createDirectory(at: published.deletingLastPathComponent(), withIntermediateDirectories: true)
    let original = Data("existing".utf8)
    try original.write(to: published)
    do {
      try await call(receiver, "commitReceive", ["id": id, "sha256": digest(bytes)])
      XCTFail("Must not overwrite an existing destination")
    } catch { }
    try await call(receiver, "discardReceive", ["id": id])
    XCTAssertEqual(try Data(contentsOf: published), original)
    XCTAssertFalse(FileManager.default.fileExists(atPath: partial.path))
  }

  @MainActor
  func testSelectedFolderPersistsAcrossRestartAndResetKeepsFiles() async throws {
    let custom = directory.appendingPathComponent("Chosen")
    try FileManager.default.createDirectory(at: custom, withIntermediateDirectories: true)
    let receiver = storage()
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      receiver.select(custom) { value in
        if let error = value as? FlutterError { continuation.resume(throwing: NSError(domain: error.code, code: 1)) }
        else { continuation.resume() }
      }
    }
    let restarted = storage()
    let location = try await call(restarted, "receiveLocation") as! [String: Any]
    XCTAssertEqual(location["custom"] as? Bool, true)
    let bytes = Data("custom folder".utf8)
    try await prepare(restarted, bytes)
    try await call(restarted, "commitReceive", ["id": id, "sha256": digest(bytes)])
    let target = custom.appendingPathComponent(id).appendingPathComponent(fileName)
    XCTAssertEqual(try Data(contentsOf: target), bytes)
    try await call(restarted, "resetReceiveFolder")
    XCTAssertEqual(try Data(contentsOf: target), bytes)
    let standard = try await call(restarted, "receiveLocation") as! [String: Any]
    XCTAssertEqual(standard["custom"] as? Bool, false)
  }
}

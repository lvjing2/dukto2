import Foundation
import Darwin

// Bonjour delegates run on the main run loop. Names/TXT are never trusted;
// Dart confirms every endpoint against its actual HTTPS identity.
final class BonjourDiscovery: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
  var onEndpoint: ((String, Int) -> Void)?
  var onError: ((String) -> Void)?
  private let browser = NetServiceBrowser()
  private var published: NetService?
  private var resolving: [String: NetService] = [:]

  func start(id: String, port: Int) {
    stop()
    let service = NetService(domain: "local.", type: "_dukto2._tcp.",
                             name: "Dukto2-\(id)", port: Int32(port))
    published = service
    service.delegate = self
    service.publish()
    browser.delegate = self
    browser.searchForServices(ofType: "_dukto2._tcp.", inDomain: "local.")
  }

  func stop() {
    browser.stop()
    published?.stop()
    published = nil
    for service in resolving.values { service.stop() }
    resolving.removeAll()
  }

  private func key(_ service: NetService) -> String {
    "\(service.domain)|\(service.type)|\(service.name)"
  }

  func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService,
                         moreComing: Bool) {
    guard service.name != published?.name, resolving.count < 128 else { return }
    resolving[key(service)] = service
    service.delegate = self
    service.resolve(withTimeout: 5)
  }

  func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService,
                         moreComing: Bool) {
    resolving.removeValue(forKey: key(service))?.stop()
  }

  func netServiceDidResolveAddress(_ sender: NetService) {
    guard (1...65535).contains(sender.port) else { return }
    for data in sender.addresses ?? [] where data.count >= MemoryLayout<sockaddr_in>.size {
      var address = sockaddr_in()
      _ = withUnsafeMutableBytes(of: &address) { data.copyBytes(to: $0) }
      guard address.sin_family == sa_family_t(AF_INET) else { continue }
      var output = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
      guard inet_ntop(AF_INET, &address.sin_addr, &output, socklen_t(output.count)) != nil else { continue }
      onEndpoint?(String(cString: output), sender.port)
    }
  }

  func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
    onError?("Bonjour 暂不可用，请检查系统的本地网络权限")
  }
}

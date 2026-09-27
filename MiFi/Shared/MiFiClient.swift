import CryptoKit
import Foundation

public struct MiFiStatus: Codable, Sendable {
    public let batteryPercentage: Int
    public let monthlyRxBytes: UInt64
    public let monthlyTxBytes: UInt64
    public let networkType: String
    public let pppStatus: String

    public var monthlyTotalBytes: UInt64 { monthlyRxBytes + monthlyTxBytes }
    public var isConnected: Bool { pppStatus.contains("connected") }

    public init(
        batteryPercentage: Int,
        monthlyRxBytes: UInt64,
        monthlyTxBytes: UInt64,
        networkType: String,
        pppStatus: String
    ) {
        self.batteryPercentage = batteryPercentage
        self.monthlyRxBytes = monthlyRxBytes
        self.monthlyTxBytes = monthlyTxBytes
        self.networkType = networkType
        self.pppStatus = pppStatus
    }
}

public enum MiFiClientError: Error {
    case invalidResponse
    case requestFailed
    case loginFailed
    case rebootFailed
}

public struct MiFiClient: Sendable {
    var host: String
    var username: String
    var password: String

    private static let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 2
        config.timeoutIntervalForResource = 2
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }()

    public init(host: String, username: String, password: String) {
        self.host = host
        self.username = username
        self.password = password
    }

    public func fetchStatus() async throws -> MiFiStatus {
        let json = try await post(["cmd": "3", "method": "GET", "sessionId": ""])
        guard json["success"] as? Bool == true else { throw MiFiClientError.invalidResponse }

        let battery = parseInt(json["battery_percentage"]) ?? 0
        let rx = parseUInt64(json["monthly_rx_bytes"]) ?? 0
        let tx = parseUInt64(json["monthly_tx_bytes"]) ?? 0
        let network = (json["network_type"] as? String) ?? ""
        let ppp = (json["ppp_status"] as? String) ?? ""

        return MiFiStatus(
            batteryPercentage: battery,
            monthlyRxBytes: rx,
            monthlyTxBytes: tx,
            networkType: network,
            pppStatus: ppp
        )
    }

    public func reboot() async throws {
        let tokenJSON = try await post(["cmd": "99", "method": "GET", "sessionId": ""])
        guard tokenJSON["success"] as? Bool == true,
              let token = tokenJSON["token"] as? String
        else { throw MiFiClientError.loginFailed }

        let passwd = sha256Hex(token + password)
        let loginJSON = try await post([
            "cmd": "100",
            "method": "POST",
            "username": username,
            "passwd": passwd,
            "sessionId": "",
        ])
        guard loginJSON["success"] as? Bool == true,
              let sessionId = loginJSON["sessionId"] as? String
        else { throw MiFiClientError.loginFailed }

        let rebootJSON = try await post([
            "cmd": "10",
            "method": "POST",
            "sessionId": sessionId,
        ])
        guard rebootJSON["success"] as? Bool == true else { throw MiFiClientError.rebootFailed }
    }

    private func post(_ body: [String: Any]) async throws -> [String: Any] {
        let url = URL(string: "http://\(host)/cgi-bin/http.cgi")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue(
            "application/x-www-form-urlencoded;charset=utf-8",
            forHTTPHeaderField: "Content-Type"
        )
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("http://\(host)/index.html", forHTTPHeaderField: "Referer")

        let (data, response) = try await Self.session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw MiFiClientError.requestFailed
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw MiFiClientError.invalidResponse
        }
        return json
    }

    private func sha256Hex(_ string: String) -> String {
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func parseInt(_ value: Any?) -> Int? {
        if let n = value as? Int { return n }
        if let s = value as? String { return Int(s) }
        return nil
    }

    private func parseUInt64(_ value: Any?) -> UInt64? {
        if let n = value as? UInt64 { return n }
        if let n = value as? Int { return UInt64(n) }
        if let s = value as? String { return UInt64(s) }
        return nil
    }
}

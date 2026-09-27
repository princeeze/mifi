import Foundation
import Security

enum CredentialsStore {
    private static let service = "com.mifi.credentials"
    private static let hostKey = "host"
    private static let usernameKey = "username"
    private static let passwordKey = "password"

    static func load() -> (host: String, username: String, password: String)? {
        guard let host = read(account: hostKey),
              let username = read(account: usernameKey),
              let password = read(account: passwordKey)
        else { return nil }
        return (host, username, password)
    }

    static func seedDefaultsIfNeeded() {
        guard load() == nil else { return }
        save(host: "192.168.0.1", username: "admin", password: "admin")
    }

    static func save(host: String, username: String, password: String) {
        write(account: hostKey, value: host)
        write(account: usernameKey, value: username)
        write(account: passwordKey, value: password)
    }

    static func makeClient() -> MiFiClient? {
        guard let creds = load() else { return nil }
        return MiFiClient(host: creds.host, username: creds.username, password: creds.password)
    }

    private static func read(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func write(account: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let attrs: [String: Any] = [kSecValueData as String: data]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
        } else {
            var add = query
            add[kSecValueData as String] = data
            SecItemAdd(add as CFDictionary, nil)
        }
    }
}

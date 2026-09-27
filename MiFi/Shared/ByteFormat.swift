import Foundation

public enum ByteFormat {
    public static func string(_ bytes: UInt64) -> String {
        let d = Double(bytes)
        if d >= 1_073_741_824 {
            return String(format: "%.1f GB", d / 1_073_741_824)
        }
        if d >= 1_048_576 {
            return String(format: "%.0f MB", d / 1_048_576)
        }
        if d >= 1024 {
            return String(format: "%.0f KB", d / 1024)
        }
        return "\(bytes) B"
    }
}

struct Options {
    let keyStrategy: KeyStrategy
    let userInfo: [CodingUserInfoKey: Any]
}

public enum KeyStrategy {
    case defaultKeys
    case snakeCase
    
    case custom((_ codingPath: [CodingKey]) -> CodingKey)
}

extension KeyStrategy {
    static func convertFromSnakeCase(_ key: CodingKey) -> CodingKey {
        guard !key.stringValue.isEmpty else { return key }
        return key
    }
}

extension KeyStrategy {
    static func convertToSnakeCase(_ key: CodingKey) -> CodingKey {
        guard !key.stringValue.isEmpty else { return key }
        return key
    }
}

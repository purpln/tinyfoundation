open class DictionaryEncoder {
    open var keyStrategy: KeyStrategy = .defaultKeys
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    
    private var options: Options {
        Options(keyStrategy: keyStrategy, userInfo: userInfo)
    }
    
    public init() {}
    
    open func encode<T: Encodable>(_ value: T) throws -> Any {
        try EncoderImplementation(codingPath: [], options: options).wrap(encodable: value, for: nil)
    }
}

open class DictionaryDecoder {
    open var keyStrategy: KeyStrategy = .defaultKeys
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    
    private var options: Options {
        Options(keyStrategy: keyStrategy, userInfo: userInfo)
    }
    
    public init() {}
    
    open func decode<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        try DecoderImplementation(codingPath: [], value: value, options: options).unwrap(as: type)
    }
}

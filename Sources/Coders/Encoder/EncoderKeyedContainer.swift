struct EncoderKeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var implementation: EncoderImplementation
    let codingPath: [CodingKey]
    var options: Options { implementation.options }
    
    init(implementation: EncoderImplementation, codingPath: [CodingKey]) {
        self.implementation = implementation
        self.codingPath = codingPath
        
        implementation.dictionary = [:]
    }
    
    func converted(_ key: Key) -> CodingKey {
        switch implementation.options.keyStrategy {
        case .defaultKeys:
            return key
        case .snakeCase:
            return KeyStrategy.convertToSnakeCase(key)
        case .custom(let converter):
            return converter(codingPath + [key])
        }
    }
}

extension EncoderKeyedContainer {
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let nestedContainer = EncoderKeyedContainer<NestedKey>(implementation: implementation, codingPath: codingPath + [converted(key)])
        return KeyedEncodingContainer(nestedContainer)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        preconditionFailure("call for (nested unkeyed container for key \(key.stringValue)) in container")
        //return EncoderUnkeyedContainer(implementation: implementation, codingPath: codingPath + [converted(key)])
    }
    
    mutating func superEncoder() -> Encoder {
        preconditionFailure("call for (super encoder) in container")
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        preconditionFailure("call for (super encoder for key \(key.stringValue)) in container")
    }
}

extension EncoderKeyedContainer {
    mutating func new<T: Encodable>(value: T, for key: Key) {
        implementation.dictionary[converted(key).stringValue] = value
    }
}

extension EncoderKeyedContainer {
    mutating func encodeNil(forKey key: Key) throws {
        new(value: Optional<Never>.none, for: key)
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        new(value: value, for: key)
    }
    
    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        let object = try wrap(encodable: value, for: key)
        implementation.dictionary[converted(key).stringValue] = object
    }
}

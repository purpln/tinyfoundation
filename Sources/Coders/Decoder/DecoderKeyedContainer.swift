struct DecoderKeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let implementation: DecoderImplementation
    let codingPath: [CodingKey]
    let dictionary: [AnyHashable: Any]
    
    init(implementation: DecoderImplementation, codingPath: [CodingKey], dictionary: [AnyHashable: Any]) {
        self.implementation = implementation
        self.codingPath = codingPath
        
        switch implementation.options.keyStrategy {
        case .defaultKeys:
            self.dictionary = dictionary
        case .snakeCase:
            var converted = [String: Any]()
            converted.reserveCapacity(dictionary.count)
            dictionary.forEach { (key, value) in
                guard let key = ContainerKey(hashable: key) else { return }
                converted[KeyStrategy.convertFromSnakeCase(key).stringValue] = value
            }
            self.dictionary = converted
        case .custom(let converter):
            var converted = [String: Any]()
            converted.reserveCapacity(dictionary.count)
            dictionary.forEach { (key, value) in
                guard let key = ContainerKey(hashable: key) else { return }
                var pathForKey = codingPath
                pathForKey.append(key)
                converted[converter(pathForKey).stringValue] = value
            }
            self.dictionary = converted
        }
    }
}

private extension DecoderKeyedContainer {
    func value<LocalKey: CodingKey>(for key: LocalKey) throws -> Any {
        if let value = dictionary[key.hashable] {
            return value
        } else {
            let description = "No value associated with key \(key) (\"\(key.stringValue)\")."
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.keyNotFound(key, context)
        }
    }
    
    func value<LocalKey: CodingKey, T>(for key: LocalKey, as type: T.Type) throws -> T {
        let value = try value(for: key)
        guard let wrapped = value as? T else {
            let description = "Expected to decode \(type) but found \(value) instead."
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch(type, context)
        }
        return wrapped
    }
    
    func decoder<LocalKey: CodingKey>(for key: LocalKey) throws -> DecoderImplementation {
        let value: Any
        if let collection = dictionary[key.hashable] as? any Collection {
            value = collection
        } else {
            value = dictionary
        }
        /*
        guard let value = dictionary[key.stringValue] else {
            let description = "- decode \(key.stringValue) \(dictionary)"
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch([String: Any].self, context)
        }
        */
        let options = implementation.options
        var codingPath = codingPath
        codingPath.append(key)
        return DecoderImplementation(codingPath: codingPath, value: value, options: options)
    }
    
    private func decoderNoThrow<LocalKey: CodingKey>(for key: LocalKey) -> DecoderImplementation {
        let dictionary: [String: Any]
        do {
            dictionary = try value(for: key, as: [String: Any].self)
        } catch {
            dictionary = [:]
        }
        let options = implementation.options
        var codingPath = codingPath
        codingPath.append(key)
        return DecoderImplementation(codingPath: codingPath, value: dictionary, options: options)
    }
}

extension DecoderKeyedContainer {
    var allKeys: [Key] {
        dictionary.keys.compactMap {
            Key(hashable: $0)
        }
    }
    
    func contains(_ key: Key) -> Bool {
        guard let _ = dictionary[key.hashable] else { return false }
        return true
    }
}

extension DecoderKeyedContainer {
    func decodeNil(forKey key: Key) throws -> Bool {
        true
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try value(for: key, as: type)
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try value(for: key, as: type)
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try value(for: key, as: type)
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try value(for: key, as: type)
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try value(for: key, as: type)
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try value(for: key, as: type)
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try value(for: key, as: type)
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try value(for: key, as: type)
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try value(for: key, as: type)
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try value(for: key, as: type)
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try value(for: key, as: type)
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try value(for: key, as: type)
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try value(for: key, as: type)
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try value(for: key, as: type)
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        try decoder(for: key).unwrap(as: type)
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        try decoder(for: key).container(keyedBy: type)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try decoder(for: key).unkeyedContainer()
    }
    
    func superDecoder() throws -> Decoder {
        decoderNoThrow(for: ContainerKey.super)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        decoderNoThrow(for: key)
    }
}

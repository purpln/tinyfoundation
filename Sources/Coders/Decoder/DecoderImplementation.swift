class DecoderImplementation {
    let codingPath: [CodingKey]
    let options: Options
    var userInfo: [CodingUserInfoKey: Any] {
        options.userInfo
    }
    
    let value: Any
    
    init(codingPath: [CodingKey], value: Any, options: Options) {
        self.codingPath = codingPath
        self.value = value
        self.options = options
    }
}

extension DecoderImplementation: Decoder {
    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard let dictionary = value as? [AnyHashable: Any] else { throw error("not dictionary") }
        let container = DecoderKeyedContainer<Key>(implementation: self, codingPath: codingPath, dictionary: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        if let dictionary = value as? [AnyHashable: Any] {
            let array = dictionary.reduce(into: [[AnyHashable: Any]]()) { array, value in
                array.append([value.key: value.value])
            }
            return DecoderUnkeyedContainer(implementation: self, codingPath: codingPath, array: array)
        }
        guard let array = value as? [Any] else { throw error("not array") }
        return DecoderUnkeyedContainer(implementation: self, codingPath: codingPath, array: array)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        DecoderSingleValueContainer(implementation: self, codingPath: codingPath, value: value)
    }
}

extension DecoderImplementation {
    func error(_ description: String) -> Error {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
        return DecodingError.dataCorrupted(context)
    }
    
    func unwrap<T: Decodable>(as type: T.Type) throws -> T {
        if type is any ExpressibleByDictionaryLiteral {
            return try unwrapDictionary(as: type)
        }
        
        return try type.init(from: self)
    }
    
    func unwrapDictionary<T: Decodable>(as type: T.Type) throws -> T {
        guard let dictionary = value as? [AnyHashable: Any] else {
            throw error("not dictionary unwrap")
        }
        
        var result = [AnyHashable: Any]()
        
        for (key, value) in dictionary {
            var codingPath = codingPath
            if let key = key as? String {
                codingPath.append(ContainerKey(stringValue: key))
            } else if let key = key as? Int {
                codingPath.append(ContainerKey(intValue: key))
            } else {
                continue
            }
            
            guard let dictionary = value as? [AnyHashable: Any] else {
                let description = "Expected to decode \([AnyHashable: Any].self) but found \(value) instead."
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
                throw DecodingError.typeMismatch([String: Any].self, context)
            }
            let decoder = DecoderImplementation(codingPath: codingPath, value: dictionary, options: options)
            
            result[key] = try type.init(from: decoder)
        }
        
        return result as! T
    }
}

class EncoderImplementation {
    let codingPath: [CodingKey]
    let options: Options
    var userInfo: [CodingUserInfoKey: Any] {
        options.userInfo
    }
    
    var value: (any Encodable)!
    var array: [Any]!
    var dictionary: [String: Any]!
    
    init(codingPath: [CodingKey], options: Options) {
        self.codingPath = codingPath
        self.options = options
    }
}

extension EncoderImplementation: Encoder {
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        guard value == nil, array == nil else { preconditionFailure() }
        return KeyedEncodingContainer(EncoderKeyedContainer(implementation: self, codingPath: codingPath))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        guard value == nil, dictionary == nil else { preconditionFailure() }
        return EncoderUnkeyedContainer(implementation: self, codingPath: codingPath)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        guard dictionary == nil, array == nil else { preconditionFailure() }
        return EncoderSingleValueContainer(implementation: self, codingPath: codingPath)
    }
}

extension EncoderImplementation {
    var result: Any {
        if let dictionary = dictionary {
            return dictionary
        }
        if let array = array {
            return array
        }
        if let value = value {
            return value
        }
        return Optional<Never>.none as Any
    }
}

extension EncoderImplementation: SpecialTreatmentEncoder {
    var implementation: EncoderImplementation {
        self
    }
}

extension EncoderKeyedContainer: SpecialTreatmentEncoder {
    
}

extension EncoderUnkeyedContainer: SpecialTreatmentEncoder {
    
}

protocol SpecialTreatmentEncoder {
    var codingPath: [CodingKey] { get }
    var options: Options { get }
    var implementation: EncoderImplementation { get }
}

extension SpecialTreatmentEncoder {
    func wrap<E: Encodable>(encodable: E, for additionalKey: CodingKey?) throws -> Any {
        let encoder = encoder(for: additionalKey)
        try encodable.encode(to: encoder)
        return encoder.result
    }
    
    func encoder(for additionalKey: CodingKey?) -> EncoderImplementation {
        if let additionalKey = additionalKey {
            var codingPath = codingPath
            codingPath.append(additionalKey)
            return EncoderImplementation(codingPath: codingPath, options: options)
        }
        return implementation
    }
}

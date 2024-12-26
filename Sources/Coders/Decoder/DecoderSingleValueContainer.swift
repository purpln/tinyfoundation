struct DecoderSingleValueContainer: SingleValueDecodingContainer {
    let implementation: DecoderImplementation
    let codingPath: [CodingKey]
    let value: Any
    
    init(implementation: DecoderImplementation, codingPath: [CodingKey], value: Any) {
        self.implementation = implementation
        self.codingPath = codingPath
        self.value = value
    }
}

extension DecoderSingleValueContainer {
    func unwrap<T>(value: Any, as type: T.Type) throws -> T {
        guard let wrapped = value as? T else {
            let description = "Expected to decode \(type) but found \(value) instead."
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch(type, context)
        }
        return wrapped
    }
}

extension DecoderSingleValueContainer {
    func decodeNil() -> Bool {
        true
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: String.Type) throws -> String {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try unwrap(value: value, as: type)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try unwrap(value: value, as: type)
    }
    
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try implementation.unwrap(as: type)
    }
}

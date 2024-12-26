struct EncoderSingleValueContainer: SingleValueEncodingContainer {
    let implementation: EncoderImplementation
    let codingPath: [CodingKey]
    var options: Options { implementation.options }
    
    init(implementation: EncoderImplementation, codingPath: [CodingKey]) {
        self.implementation = implementation
        self.codingPath = codingPath
    }
}

extension EncoderSingleValueContainer {
    func new<T: Encodable>(value: T) {
        implementation.value = value
    }
}

extension EncoderSingleValueContainer {
    mutating func encodeNil() throws {
        new(value: Optional<Never>.none)
    }
    
    mutating func encode(_ value: Bool) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: String) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: Double) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: Float) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: Int) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: Int8) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: Int16) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: Int32) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: Int64) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: UInt) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: UInt8) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: UInt16) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: UInt32) throws {
        new(value: value)
    }
    
    mutating func encode(_ value: UInt64) throws {
        new(value: value)
    }
    
    mutating func encode<T: Encodable>(_ value: T) throws {
        preconditionFailure("encode single value: \(value)")
    }
}

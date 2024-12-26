struct EncoderUnkeyedContainer: UnkeyedEncodingContainer {
    let implementation: EncoderImplementation
    let codingPath: [CodingKey]
    var options: Options { implementation.options }
    
    var count: Int {
        implementation.array.count
    }
    
    init(implementation: EncoderImplementation, codingPath: [CodingKey]) {
        self.implementation = implementation
        self.codingPath = codingPath
        
        implementation.array = []
    }
}

extension EncoderUnkeyedContainer {
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        preconditionFailure("call for (nested container) in unkeyed container")
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        preconditionFailure("call for (nested unkeyed container) in unkeyed container")
    }
    
    mutating func superEncoder() -> Encoder {
        preconditionFailure("call for (super encoder) in unkeyed container")
    }
}

extension EncoderUnkeyedContainer {
    mutating func new<T: Encodable>(value: T) {
        implementation.array.append(value)
    }
}

extension EncoderUnkeyedContainer {
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
        let object = try wrap(encodable: value, for: ContainerKey(intValue: count))
        implementation.array.append(object)
    }
}

struct DecoderUnkeyedContainer: UnkeyedDecodingContainer {
    let implementation: DecoderImplementation
    let codingPath: [CodingKey]
    let array: [Any]
    
    var count: Int? { array.count }
    var isAtEnd: Bool { currentIndex >= (count ?? 0) }
    var currentIndex: Int = 0
    
    init(implementation: DecoderImplementation, codingPath: [CodingKey], array: [Any]) {
        self.implementation = implementation
        self.codingPath = codingPath
        self.array = array
    }
}

extension DecoderUnkeyedContainer {
    mutating func next<T>(type: T.Type) throws -> T {
        guard !isAtEnd else {
            var description = "Unkeyed container is at end."
            if T.self == DecoderUnkeyedContainer.self {
                description = "Cannot get nested unkeyed container -- unkeyed container is at end."
            }
            if T.self == Decoder.self {
                description = "Cannot get superDecoder() -- unkeyed container is at end."
            }
            
            var codingPath = codingPath
            codingPath.append(ContainerKey(index: currentIndex))
            
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            
            throw DecodingError.valueNotFound(T.self, context)
        }
        let value = array[currentIndex]
        guard let wrapped = value as? T else {
            let description = "Expected to decode \(type) but found \(value) instead."
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch(type, context)
        }
        currentIndex += 1
        return wrapped
    }
    
    mutating func decoder<T>(type: T.Type) throws -> DecoderImplementation {
        guard !isAtEnd else {
            var description = "Unkeyed container is at end."
            if T.self == DecoderUnkeyedContainer.self {
                description = "Cannot get nested unkeyed container -- unkeyed container is at end."
            }
            if T.self == Decoder.self {
                description = "Cannot get superDecoder() -- unkeyed container is at end."
            }
            
            var codingPath = codingPath
            codingPath.append(ContainerKey(index: currentIndex))
            
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            
            throw DecodingError.valueNotFound(T.self, context)
        }
        let value = array[currentIndex]
        let options = implementation.options
        var codingPath = codingPath
        codingPath.append(ContainerKey(index: currentIndex))
        
        currentIndex += 1
        
        return DecoderImplementation(
            codingPath: codingPath,
            value: value,
            options: options
        )
    }
}

extension DecoderUnkeyedContainer {
    mutating func decodeNil() throws -> Bool {
        true
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        try next(type: type)
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        try next(type: type)
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        try next(type: type)
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        try next(type: type)
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        try next(type: type)
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try next(type: type)
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try next(type: type)
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try next(type: type)
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try next(type: type)
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try next(type: type)
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try next(type: type)
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try next(type: type)
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try next(type: type)
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try next(type: type)
    }
    
    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try decoder(type: type).unwrap(as: type)
    }
    
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        let decoder = try decoder(type: KeyedDecodingContainer<NestedKey>.self)
        return try decoder.container(keyedBy: type)
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let decoder = try decoder(type: UnkeyedDecodingContainer.self)
        return try decoder.unkeyedContainer()
    }
    
    mutating func superDecoder() throws -> Decoder {
        try decoder(type: Decoder.self)
    }
}

internal struct ContainerKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

internal extension CodingKey {
    init?(hashable value: AnyHashable) {
        if let value = value as? String, let key = Self(stringValue: value) {
            self = key
        } else if let value = value as? Int, let key = Self(intValue: value) {
            self = key
        } else {
            return nil
        }
    }
    
    var hashable: AnyHashable {
        if let intValue = intValue {
            return intValue
        } else {
            return stringValue
        }
    }
}

internal extension ContainerKey {
    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
    
    static let `super`: Self = ContainerKey(stringValue: "super")
}

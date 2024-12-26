extension Path: RawRepresentable {
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Path: Equatable {
    public static func == (lhs: Path, rhs: Path) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Path: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
extension Path: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Path(rawValue: string)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Path: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
}

extension Path: ExpressibleByStringInterpolation {}

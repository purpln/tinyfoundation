public struct UniqueID: Sendable {
    public typealias Bytes = (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )
    
    public let bytes: Bytes
    
    @inlinable
    public init(bytes: Bytes) {
        self.bytes = bytes
    }
}

extension UniqueID: LosslessStringConvertible {
    @inlinable
    public init?(_ string: String) {
        self.init(internal: string)
    }
    
    @inlinable
    internal init?<S: StringProtocol>(internal string: S) where S.UTF8View: BidirectionalCollection {
        let parsed = string.utf8.withContiguousStorageIfAvailable { UniqueID(utf8: $0) } ?? UniqueID(utf8: string.utf8)
        guard let parsed = parsed else {
            return nil
        }
        self = parsed
    }
}

extension UniqueID: CustomStringConvertible {
    @inlinable
    public var description: String {
        serialized()
    }
}

extension UniqueID: Codable {
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let value = UniqueID(internal: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid UUID string")
        }
        self = value
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension UniqueID: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: bytes) { hasher.combine(bytes: $0) }
    }
}

extension UniqueID: Equatable {
    @inlinable
    public static func == (lhs: UniqueID, rhs: UniqueID) -> Bool {
        withUnsafeBytes(of: lhs.bytes) { lhsBytes in
            withUnsafeBytes(of: rhs.bytes) { rhsBytes in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}

extension UniqueID: Comparable {
    @inlinable
    public static func < (lhs: UniqueID, rhs: UniqueID) -> Bool {
        withUnsafeBytes(of: lhs.bytes) { lhsBytes in
            withUnsafeBytes(of: rhs.bytes) { rhsBytes in
                lhsBytes.lexicographicallyPrecedes(rhsBytes)
            }
        }
    }
}

public extension UniqueID {
    @inlinable 
    static var zero: UniqueID {
        UniqueID(bytes: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
    
    @inlinable 
    var version: Int? {
        guard (bytes.8 &>> 6) == 0b00000010 else { return nil }
        return Int((bytes.6 & 0b1111_0000) &>> 4)
    }
}

public extension UniqueID {
    @inlinable
    init?<Bytes: Sequence>(bytes: Bytes) where Bytes.Element == UInt8 {
        var uuid = UniqueID.zero.bytes
        let copied = withUnsafeMutableBytes(of: &uuid) { bytes in
            UnsafeMutableBufferPointer(
                start: bytes.baseAddress.unsafelyUnwrapped.assumingMemoryBound(to: UInt8.self),
                count: 16
            ).initialize(from: bytes).1
        }
        guard copied == 16 else { return nil }
        self.init(bytes: uuid)
    }
    
    @inlinable
    init() {
        self = .random()
    }
}

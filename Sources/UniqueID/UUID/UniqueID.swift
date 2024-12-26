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
    
    @inlinable
    public init(_ uuid: UniqueID = .random()) {
        self = uuid
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
    
    @inlinable
    var string: String {
        serialized(lowercase: true)
    }
}

public extension UniqueID {
    @inlinable init?<Bytes: Sequence>(bytes: Bytes) where Bytes.Element == UInt8 {
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
}

extension UniqueID: Equatable, Hashable, Comparable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs.bytes) { lhsBytes in
            withUnsafeBytes(of: rhs.bytes) { rhsBytes in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: bytes) { hasher.combine(bytes: $0) }
    }
    
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs.bytes) { lhsBytes in
            withUnsafeBytes(of: rhs.bytes) { rhsBytes in
                lhsBytes.lexicographicallyPrecedes(rhsBytes)
            }
        }
    }
}

extension UniqueID: CustomStringConvertible, LosslessStringConvertible {
    @inlinable
    public var description: String {
        serialized()
    }
}

extension UniqueID: Codable {
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let decoded = UniqueID(try container.decode(String.self)) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid UUID string")
        }
        self = decoded
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(serialized())
    }
}

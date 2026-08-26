import TinySystem

internal struct SystemCharacter: RawRepresentable, Equatable, Hashable, Sendable, Comparable, Codable {
    internal typealias RawValue = PlatformCharacter
    
    internal var rawValue: RawValue
    
    internal init(rawValue: RawValue) { self.rawValue = rawValue }
    
    internal init(_ rawValue: RawValue) { self.init(rawValue: rawValue) }
    
    static func < (lhs: SystemCharacter, rhs: SystemCharacter) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension SystemCharacter {
    internal init(ascii: Unicode.Scalar) {
        self.init(rawValue: numericCast(UInt8(ascii: ascii)))
    }
    internal init(codeUnit: PlatformUnicodeEncoding.CodeUnit) {
        self.init(rawValue: codeUnit.platformChar)
    }
    
    internal static var null: SystemCharacter { SystemCharacter(0x0) }
    internal static var slash: SystemCharacter { SystemCharacter(ascii: "/") }
    internal static var backslash: SystemCharacter { SystemCharacter(ascii: #"\"#) }
    internal static var dot: SystemCharacter { SystemCharacter(ascii: ".") }
    internal static var colon: SystemCharacter { SystemCharacter(ascii: ":") }
    internal static var question: SystemCharacter { SystemCharacter(ascii: "?") }
    
    internal var codeUnit: PlatformUnicodeEncoding.CodeUnit {
        rawValue.platformCodeUnit
    }
    
    internal var asciiScalar: Unicode.Scalar? {
        guard isASCII else { return nil }
        return Unicode.Scalar(UInt8(truncatingIfNeeded: rawValue))
    }
    
    internal var isASCII: Bool {
        (0...0x7F).contains(rawValue)
    }
    
    internal var isLetter: Bool {
        guard isASCII else { return false }
        let asciiRaw: UInt8 = numericCast(rawValue)
        return (UInt8(ascii: "a") ... UInt8(ascii: "z")).contains(asciiRaw) ||
        (UInt8(ascii: "A") ... UInt8(ascii: "Z")).contains(asciiRaw)
    }
}

// A platform-native string representation, currently for file paths
//
// Always null-terminated.
internal struct SystemString: Sendable {
    internal typealias Storage = [SystemCharacter]
    internal var nullTerminatedStorage: Storage
}

extension SystemString {
    internal init() {
        self.nullTerminatedStorage = [.null]
        invariantCheck()
    }
    
    internal var length: Int {
        let len = nullTerminatedStorage.count - 1
        assert(len == self.count)
        return len
    }
    
    // Common funnel point. Ensure all non-empty inits go here.
    internal init(nullTerminated storage: Storage) {
        self.nullTerminatedStorage = storage
        invariantCheck()
    }
    
    // Ensures that result is null-terminated
    internal init<C: Collection>(_ characters: C) where C.Element == SystemCharacter {
        var raw = Storage(characters)
        if raw.last != .null {
            raw.append(.null)
        }
        self.init(nullTerminated: raw)
    }
}

extension SystemString {
    fileprivate func invariantsSatisfied() -> Bool {
        guard !nullTerminatedStorage.isEmpty else { return false }
        guard nullTerminatedStorage.last! == .null else { return false }
        guard nullTerminatedStorage.firstIndex(of: .null) == length else {
            return false
        }
        return true
    }
    
    fileprivate func invariantCheck() {
#if DEBUG
        precondition(invariantsSatisfied())
#endif
    }
}

extension SystemString: RandomAccessCollection, MutableCollection {
    internal typealias Element = SystemCharacter
    internal typealias Index = Storage.Index
    internal typealias Indices = Range<Index>
    
    internal var startIndex: Index {
        nullTerminatedStorage.startIndex
    }
    
    internal var endIndex: Index {
        nullTerminatedStorage.index(before: nullTerminatedStorage.endIndex)
    }
    
    internal subscript(position: Index) -> SystemCharacter {
        _read {
            precondition(position >= startIndex && position < endIndex)
            yield nullTerminatedStorage[position]
        }
        set(newValue) {
            precondition(position >= startIndex && position < endIndex)
            nullTerminatedStorage[position] = newValue
            invariantCheck()
        }
    }
}
extension SystemString: RangeReplaceableCollection {
    internal mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Index>, with newElements: C
    ) where C.Element == SystemCharacter {
        defer { invariantCheck() }
        nullTerminatedStorage.replaceSubrange(subrange, with: newElements)
    }
    
    internal mutating func reserveCapacity(_ n: Int) {
        defer { invariantCheck() }
        nullTerminatedStorage.reserveCapacity(1 + n)
    }
    
    internal func withContiguousStorageIfAvailable<T, E>(
        _ body: (UnsafeBufferPointer<SystemCharacter>) throws(E) -> T
    ) throws(E) -> T? {
        // Do not include the null terminator, it is outside the Collection
        try nullTerminatedStorage.withContiguousStorageIfAvailable({ buffer -> Result<T, E> in
            do throws(E) {
                let value = try body(UnsafeBufferPointer(
                    start: buffer.baseAddress,
                    count: buffer.count-1
                ))
                return .success(value)
            } catch {
                return .failure(error)
            }
        })?.get()
    }
    
    internal mutating func withContiguousMutableStorageIfAvailable<T, E>(
        _ body: (inout UnsafeMutableBufferPointer<SystemCharacter>) throws(E) -> T
    ) throws(E) -> T? {
        defer { invariantCheck() }
        // Do not include the null terminator, it is outside the Collection
        return try nullTerminatedStorage.withContiguousMutableStorageIfAvailable({ buffer -> Result<T, E> in
            var buffer = UnsafeMutableBufferPointer<SystemCharacter>(
                start: buffer.baseAddress, count: buffer.count-1
            )
            do throws(E) {
                let result = try body(&buffer)
                return .success(result)
            } catch {
                return .failure(error)
            }
        })?.get()
    }
}

extension SystemString: Hashable, Codable {
    // Encoder is synthesized; it probably should have been explicit and used
    // a single-value container, but making that change now is somewhat risky.
    
    // Decoder is written explicitly to ensure that we validate invariants on
    // untrusted input.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nullTerminatedStorage = try container.decode(
            Storage.self, forKey: .nullTerminatedStorage
        )
        guard invariantsSatisfied() else {
            throw DecodingError.dataCorruptedError(
                forKey: .nullTerminatedStorage,
                in: container,
                debugDescription:
                    "Encoding does not satisfy the invariants of SystemString"
            )
        }
    }
}

extension SystemString {
    
    internal func withNullTerminatedSystemCharacters<T, E>(
        _ body: (UnsafeBufferPointer<SystemCharacter>) throws(E) -> T
    ) throws(E) -> T {
        try nullTerminatedStorage.withUnsafeBufferPointer(body)
    }
    
    // withCodeUnits does not include the null terminator
    internal func withCodeUnits<T, E>(
        _ body: (UnsafeBufferPointer<PlatformUnicodeEncoding.CodeUnit>) throws(E) -> T
    ) throws(E) -> T {
        try withNullTerminatedSystemCharacters({ characters throws(E) in
            try characters.withMemoryRebound(to: PlatformUnicodeEncoding.CodeUnit.self, { buffer throws(E) in
                assert(buffer.last == .zero)
                return try body(UnsafeBufferPointer(
                    start: buffer.baseAddress,
                    count: buffer.count - 1
                ))
            })
        })
    }
}

extension Slice where Base == SystemString {
    internal func withCodeUnits<T, E>(
        _ body: (UnsafeBufferPointer<PlatformUnicodeEncoding.CodeUnit>) throws(E) -> T
    ) throws(E) -> T {
        try base.withCodeUnits({ units throws(E) in
            try body(UnsafeBufferPointer(rebasing: units[indices]))
        })
    }
    
    internal var string: String {
        withCodeUnits({
            String(decoding: $0, as: PlatformUnicodeEncoding.self)
        })
    }
    
    internal func withPlatformString<T, E>(
        _ body: (UnsafePointer<PlatformCharacter>) throws(E) -> T
    ) throws(E) -> T {
        return try SystemString(self).withPlatformString(body)
    }
    
}

extension String {
    internal init(decoding str: SystemString) {
        self = str.withPlatformString({
            String(platformString: $0)
        })
    }
    internal init?(validating str: SystemString) {
        guard let str = str.withPlatformString(String.init(validatingPlatformString:))
        else { return nil }
        
        self = str
    }
}

extension SystemString: ExpressibleByStringLiteral {
    internal init(stringLiteral: String) {
        self.init(stringLiteral)
    }
    
    internal init(_ string: String) {
        self = string.withPlatformString({
            SystemString(platformString: $0)
        })
    }
}

extension SystemString: CustomStringConvertible, CustomDebugStringConvertible {
    internal var string: String {
        self.withCodeUnits({
            String(decoding: $0, as: PlatformUnicodeEncoding.self)
        })
    }
    
    internal var description: String { string }
    internal var debugDescription: String { description.debugDescription }
}

extension SystemString {
    internal init(platformString: UnsafePointer<PlatformCharacter>) {
        let count = 1 + system_platform_strlen(platformString)
        
        let characters: Array<SystemCharacter> = platformString.withMemoryRebound(
            to: SystemCharacter.self, capacity: count, {
                let buffer = UnsafeBufferPointer(start: $0, count: count)
                return Array(buffer)
            })
        
        self.init(nullTerminated: characters)
    }
    
    internal func withPlatformString<T, E>(
        _ body: (UnsafePointer<PlatformCharacter>) throws(E) -> T
    ) throws(E) -> T {
        try withNullTerminatedSystemCharacters({ characters throws(E) in
            let length = characters.count * MemoryLayout<SystemCharacter>.stride
            return try characters.baseAddress!.withMemoryRebound(
                to: PlatformCharacter.self,
                capacity: length / MemoryLayout<PlatformCharacter>.stride, { pointer throws(E) in
                    assert(pointer[self.count] == 0)
                    return try body(pointer)
                })
        })
    }
}

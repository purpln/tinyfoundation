import LibC

@inlinable
internal func numberOfDigits<T: BinaryInteger>(in number: T) -> Int {
    if number < 10 && number >= 0 || number > -10 && number < 0 {
        return 1
    } else {
        return 1 + numberOfDigits(in: number/10)
    }
}

public struct Timestamp: Sendable {
    @usableFromInline
    internal let value: timespec
    
    @inlinable
    public init(_ value: Int) {
        switch numberOfDigits(in: value) {
        case 0..<12:
            self = .seconds(value)
        case 12..<15:
            self = .milliseconds(value)
        case 15..<18:
            self = .microseconds(value)
        case 18...:
            self = .nanoseconds(value)
        default:
            preconditionFailure()
        }
    }
}

extension Timestamp: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt) {
        self = Timestamp(Int(value))
    }
}

extension Timestamp: CustomStringConvertible {
    @inlinable
    public var description: String {
        var seconds = value.tv_sec
        let ts = localtime(&seconds)
        
        let length = 64
        let buffer = [UInt8](unsafeUninitializedCapacity: length) { buffer, count in
            count = strftime(buffer.baseAddress!, length, /* %A */ "%Y-%m-%d %H:%M:%S %z", ts!)
        }
        return String(decoding: buffer, as: UTF8.self)
    }
}

extension Timestamp: Codable {
    @inlinable
    public init(from decoder: any Decoder) throws {
        let value = try decoder.singleValueContainer().decode(UInt.self)
        self = Timestamp(timespec: .init(value, precision: .milliseconds))
    }
    
    @inlinable
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.interval(for: .milliseconds) as Int)
    }
}

extension Timestamp: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension Timestamp: Equatable {
    @inlinable
    public static func == (lhs: Timestamp, rhs: Timestamp) -> Bool {
        lhs.value == rhs.value
    }
}

extension Timestamp: Comparable {
    @inlinable
    public static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        lhs.value < rhs.value
    }
}

extension Timestamp: AdditiveArithmetic {
    @inlinable
    public static func - (lhs: Timestamp, rhs: Timestamp) -> Timestamp {
        Timestamp(timespec: lhs.value - rhs.value)
    }
    
    @inlinable
    public static func + (lhs: Timestamp, rhs: Timestamp) -> Timestamp {
        Timestamp(timespec: lhs.value + rhs.value)
    }
    
    @inlinable
    public static var zero: Timestamp {
        Timestamp(timespec: .zero)
    }
}

public extension Timestamp {
    @inlinable
    static var now: Timestamp {
        Timestamp(timespec: .now())
    }
    
    @inlinable
    init() {
        self = .now
    }
}

public extension Timestamp {
    static func seconds<T: BinaryInteger>(_ seconds: T) -> Timestamp {
        Timestamp(timespec: .init(seconds, precision: .seconds))
    }
    
    static func seconds(_ seconds: Double) -> Timestamp {
        Timestamp(timespec: .init(seconds, precision: .seconds))
    }
    
    static func milliseconds<T: BinaryInteger>(_ milliseconds: T) -> Timestamp {
        Timestamp(timespec: .init(milliseconds, precision: .milliseconds))
    }
    
    static func milliseconds(_ milliseconds: Double) -> Timestamp {
        Timestamp(timespec: .init(milliseconds, precision: .milliseconds))
    }
    
    static func microseconds<T: BinaryInteger>(_ microseconds: T) -> Timestamp {
        Timestamp(timespec: .init(microseconds, precision: .microseconds))
    }
    
    static func microseconds(_ microseconds: Double) -> Timestamp {
        Timestamp(timespec: .init(microseconds, precision: .microseconds))
    }
    
    static func nanoseconds<T: BinaryInteger>(_ nanoseconds: T) -> Timestamp {
        Timestamp(timespec: .init(nanoseconds, precision: .nanoseconds))
    }
}

public extension Timestamp {
    @inlinable
    var elapsed: Double {
        (Timestamp.now - self).value.interval(for: .seconds)
    }
    @inlinable
    var components: (seconds: time_t, nanoseconds: Int) {
        (value.tv_sec, value.tv_nsec)
    }
}

public extension Timestamp {
    @inlinable
    init(timespec: timespec) {
        self.value = timespec
    }
    
    var timespec: timespec {
        value
    }
}

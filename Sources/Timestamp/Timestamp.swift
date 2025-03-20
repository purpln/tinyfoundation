import LibC

public typealias TimeInterval = Double

public struct Timestamp: Sendable {
    @usableFromInline
    internal let value: timespec
    
    @inlinable
    public init<T: BinaryInteger>(_ value: T) {
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
            self = .zero
        }
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        let (whole, _) = modf(Double(value))
        switch numberOfDigits(in: Int(whole)) {
        case 0..<12:
            self = .seconds(value)
        case 12..<15:
            self = .milliseconds(value)
        case 15..<18:
            self = .microseconds(value)
        default:
            self = .zero
        }
    }
}

extension Timestamp: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: FloatLiteralType) {
        self = Timestamp(value)
    }
}

extension Timestamp: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt) {
        self = Timestamp(value)
    }
}

extension Timestamp: CustomStringConvertible {
    @inlinable
    public var description: String {
        value.description
    }
}

extension Timestamp: Codable {
    @inlinable
    public init(from decoder: any Decoder) throws {
        let precision = decoder.userInfo[.precision] as? TimestampPrecision ?? .milliseconds
        let value = try decoder.singleValueContainer().decode(Double.self)
        self = Timestamp(timespec: .init(value, precision: precision))
    }
    
    @inlinable
    public func encode(to encoder: any Encoder) throws {
        let precision = encoder.userInfo[.precision] as? TimestampPrecision ?? .milliseconds
        var container = encoder.singleValueContainer()
        try container.encode(value.interval(for: precision) as Double)
    }
}

public extension CodingUserInfoKey {
    static let precision = CodingUserInfoKey(rawValue: "precision")!
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

extension Timestamp: Strideable {
    public typealias Stride = TimeInterval
    
    public func distance(to other: Timestamp) -> TimeInterval {
        (other - self).value.interval(for: .seconds)
    }
    
    public func advanced(by n: TimeInterval) -> Timestamp {
        self + Timestamp(timespec: .init(interval: n))
    }
}

public extension Timestamp {
    @inlinable
    static var now: Timestamp {
        Timestamp(timespec: .now)
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
    
    static func seconds<T: BinaryFloatingPoint>(_ seconds: T) -> Timestamp {
        Timestamp(timespec: .init(seconds, precision: .seconds))
    }
    
    static func milliseconds<T: BinaryInteger>(_ milliseconds: T) -> Timestamp {
        Timestamp(timespec: .init(milliseconds, precision: .milliseconds))
    }
    
    static func milliseconds<T: BinaryFloatingPoint>(_ milliseconds: T) -> Timestamp {
        Timestamp(timespec: .init(milliseconds, precision: .milliseconds))
    }
    
    static func microseconds<T: BinaryInteger>(_ microseconds: T) -> Timestamp {
        Timestamp(timespec: .init(microseconds, precision: .microseconds))
    }
    
    static func microseconds<T: BinaryFloatingPoint>(_ microseconds: T) -> Timestamp {
        Timestamp(timespec: .init(microseconds, precision: .microseconds))
    }
    
    static func nanoseconds<T: BinaryInteger>(_ nanoseconds: T) -> Timestamp {
        Timestamp(timespec: .init(nanoseconds, precision: .nanoseconds))
    }
}

public extension Timestamp {
    @inlinable
    var elapsed: TimeInterval {
        distance(to: .now)
    }
#if !os(Windows)
    @inlinable
    var components: (seconds: time_t, nanoseconds: Int) {
        (value.tv_sec, value.tv_nsec)
    }
#else
    @inlinable
    var components: (seconds: time_t, nanoseconds: CInt) {
        (value.tv_sec, value.tv_nsec)
    }
#endif
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

@inlinable
internal func numberOfDigits<T: BinaryInteger>(in number: T) -> T {
    if number < 10 && number >= 0 || number > -10 && number < 0 {
        return 1
    } else {
        return 1 + numberOfDigits(in: number/10)
    }
}

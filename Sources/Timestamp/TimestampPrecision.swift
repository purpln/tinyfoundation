import LibC

public enum TimestampPrecision: Sendable {
    case seconds
    case milliseconds // 1/1_000
    case microseconds // 1/1_000_000
    case nanoseconds  // 1/1_000_000_000
}

internal extension timespec {
    init<T: BinaryFloatingPoint>(_ interval: T, precision: TimestampPrecision) {
        let seconds: Int
        let nanoseconds: Int
        switch precision {
        case .seconds:
            let (integer, decimal) = modf(interval)
            seconds = Int(integer)
            nanoseconds = Int(decimal * 1_000_000_000) % 1_000_000_000
        case .milliseconds:
            seconds = Int(interval) / 1_000
            nanoseconds = Int(interval * 1_000_000) % 1_000_000_000
        case .microseconds:
            seconds = Int(interval) / 1_000_000
            nanoseconds = Int(interval * 1_000) % 1_000_000_000
        case .nanoseconds:
            seconds = Int(interval) / 1_000_000_000
            nanoseconds = Int(interval) % 1_000_000_000
        }
        self = timespec(tv_sec: seconds, tv_nsec: nanoseconds)
    }
    
    @inlinable
    init<T: BinaryInteger>(_ interval: T, precision: TimestampPrecision) {
        let seconds: Int
        let nanoseconds: Int
        switch precision {
        case .seconds:
            seconds = Int(interval)
            nanoseconds = 0
        case .milliseconds:
            seconds = Int(interval) / 1_000
            nanoseconds = (Int(interval) % 1_000) * 1_000_000
        case .microseconds:
            seconds = Int(interval) / 1_000_000
            nanoseconds = (Int(interval) % 1_000_000) * 1_000
        case .nanoseconds:
            let value = Int(interval)
            seconds = value / 1_000_000_000
            nanoseconds = value % 1_000_000_000
        }
        self = timespec(tv_sec: seconds, tv_nsec: nanoseconds)
    }
    
    @inlinable
    func interval(for precision: TimestampPrecision) -> Double {
        switch precision {
        case .seconds:
            Double(tv_sec + (tv_nsec / 1_000_000_000))
        case .milliseconds:
            Double((tv_sec * 1_000) + (tv_nsec / 1_000_000))
        case .microseconds:
            Double((tv_sec * 1_000_000) + (tv_nsec / 1_000))
        case .nanoseconds:
            Double((tv_sec * 1_000_000_000) + tv_nsec)
        }
    }
    
    @inlinable
    func interval(for precision: TimestampPrecision) -> Int {
        switch precision {
        case .seconds:
            tv_sec
        case .milliseconds:
            (tv_sec * 1_000) + (tv_nsec / 1_000_000)
        case .microseconds:
            (tv_sec * 1_000_000) + (tv_nsec / 1_000)
        case .nanoseconds:
            (tv_sec * 1_000_000_000 + tv_nsec)
        }
    }
}

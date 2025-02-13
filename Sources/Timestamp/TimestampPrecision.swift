import LibC

public enum TimestampPrecision: Sendable {
    case seconds
    case milliseconds // 1/1_000
    case microseconds // 1/1_000_000
    case nanoseconds  // 1/1_000_000_000
}

internal extension timespec {
    init<T: BinaryFloatingPoint>(_ interval: T, precision: TimestampPrecision) {
        let seconds: time_t
        let nanoseconds: Int
        switch precision {
        case .seconds:
            let (integer, decimal) = modf(interval)
            seconds = time_t(integer)
            nanoseconds = Int(decimal * 1_000_000_000) % 1_000_000_000
        case .milliseconds:
            seconds = time_t(interval) / 1_000
            nanoseconds = Int(interval * 1_000_000) % 1_000_000_000
        case .microseconds:
            seconds = time_t(interval) / 1_000_000
            nanoseconds = Int(interval * 1_000) % 1_000_000_000
        case .nanoseconds:
            seconds = time_t(interval) / 1_000_000_000
            nanoseconds = Int(interval) % 1_000_000_000
        }
        self = timespec(tv_sec: seconds, tv_nsec: nanoseconds)
    }
    
    @inlinable
    init<T: BinaryInteger>(_ interval: T, precision: TimestampPrecision) {
        let seconds: time_t
        let nanoseconds: Int
        switch precision {
        case .seconds:
            seconds = time_t(interval)
            nanoseconds = 0
        case .milliseconds:
            seconds = time_t(interval) / 1_000
            nanoseconds = (Int(interval) % 1_000) * 1_000_000
        case .microseconds:
            seconds = time_t(interval) / 1_000_000
            nanoseconds = (Int(interval) % 1_000_000) * 1_000
        case .nanoseconds:
            seconds = time_t(interval) / 1_000_000_000
            nanoseconds = Int(interval) % 1_000_000_000
        }
        self = timespec(tv_sec: seconds, tv_nsec: nanoseconds)
    }
    
    @inlinable
    func interval(for precision: TimestampPrecision) -> Double {
        switch precision {
        case .seconds:
            Double(tv_sec + time_t(tv_nsec / 1_000_000_000))
        case .milliseconds:
            Double((tv_sec * 1_000) + time_t(tv_nsec / 1_000_000))
        case .microseconds:
            Double((tv_sec * 1_000_000) + time_t(tv_nsec / 1_000))
        case .nanoseconds:
            Double((tv_sec * 1_000_000_000) + time_t(tv_nsec))
        }
    }
    
    @inlinable
    func interval(for precision: TimestampPrecision) -> Int {
        switch precision {
        case .seconds:
            Int(tv_sec)
        case .milliseconds:
            Int(tv_sec * 1_000) + Int(tv_nsec / 1_000_000)
        case .microseconds:
            Int(tv_sec * 1_000_000) + Int(tv_nsec / 1_000)
        case .nanoseconds:
            Int(tv_sec * 1_000_000_000) + Int(tv_nsec)
        }
    }
}

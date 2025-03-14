import LibC

public enum TimestampPrecision: Sendable {
    case seconds
    case milliseconds // 1/1_000
    case microseconds // 1/1_000_000
    case nanoseconds  // 1/1_000_000_000
}

internal extension timespec {
    @inlinable
    init<T: BinaryFloatingPoint>(_ interval: T, precision: TimestampPrecision) {
        let seconds: time_t
        let nanoseconds: Int
        switch precision {
        case .seconds:
            let (integer, decimal) = modf(interval)
            seconds = time_t(integer)
            nanoseconds = Int(decimal * 1e9) % 1_000_000_000
        case .milliseconds:
            seconds = time_t(interval * 1e-3)
            nanoseconds = Int(interval * 1e6) % 1_000_000_000
        case .microseconds:
            seconds = time_t(interval * 1e-6)
            nanoseconds = Int(interval * 1e3) % 1_000_000_000
        case .nanoseconds:
            seconds = time_t(interval * 1e-9)
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
    func interval<T: BinaryFloatingPoint>(for precision: TimestampPrecision) -> T {
        switch precision {
        case .seconds:
            T(tv_sec) + (T(tv_nsec) * 1e-9)
        case .milliseconds:
            (T(tv_sec) * 1e3) + (T(tv_nsec) * 1e-6)
        case .microseconds:
            (T(tv_sec) * 1e6) + (T(tv_nsec) * 1e-3)
        case .nanoseconds:
            (T(tv_sec) * 1e9) + T(tv_nsec)
        }
    }
    
    @inlinable
    func interval<T: BinaryInteger>(for precision: TimestampPrecision) -> T {
        switch precision {
        case .seconds:
            T(tv_sec)
        case .milliseconds:
            T(tv_sec * 1_000) + T(tv_nsec / 1_000_000)
        case .microseconds:
            T(tv_sec * 1_000_000) + T(tv_nsec / 1_000)
        case .nanoseconds:
            T(tv_sec * 1_000_000_000) + T(tv_nsec)
        }
    }
}

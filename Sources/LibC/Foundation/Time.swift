public extension timespec {
    @inlinable
    static func now() -> timespec {
        var timespec = timespec()
        clock_gettime(CLOCK_REALTIME, &timespec)
        return timespec
    }
}

#if hasFeature(RetroactiveAttribute)
extension timespec: @retroactive Equatable {}
extension timespec: @retroactive Comparable {}
extension timespec: @retroactive Hashable {}
extension timespec: @retroactive AdditiveArithmetic {}
#else
extension timespec: Equatable {}
extension timespec: Comparable {}
extension timespec: Hashable {}
extension timespec: AdditiveArithmetic {}
#endif

extension timespec /* Equatable */ {
    public static func == (lhs: timespec, rhs: timespec) -> Bool {
        lhs.tv_sec == rhs.tv_sec && lhs.tv_nsec == rhs.tv_nsec
    }
}

extension timespec /* Comparable */ {
    public static func < (lhs: timespec, rhs: timespec) -> Bool {
        if lhs.tv_sec < rhs.tv_sec { return true }
        if lhs.tv_sec > rhs.tv_sec { return false }
        
        if lhs.tv_nsec < rhs.tv_nsec { return true }
        
        return false
    }
}

extension timespec /* Hashable */ {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tv_sec)
        hasher.combine(tv_nsec)
    }
}

extension timespec /* AdditiveArithmetic */ {
    public static func + (lhs: timespec, rhs: timespec) -> timespec {
        let raw = rhs.tv_nsec + lhs.tv_nsec
        let ns = raw % 1_000_000_000
        let s = lhs.tv_sec + rhs.tv_sec + (raw / 1_000_000_000)
        return timespec(tv_sec: s, tv_nsec: ns)
    }
    
    public static func - (lhs: timespec, rhs: timespec) -> timespec {
        let raw = lhs.tv_nsec - rhs.tv_nsec
        
        if raw >= 0 {
            let ns = raw % 1_000_000_000
            let s = lhs.tv_sec - rhs.tv_sec + (raw / 1_000_000_000)
            return timespec(tv_sec: s, tv_nsec: ns)
        } else {
            let ns = 1_000_000_000 - (-raw % 1_000_000_000)
            let s = lhs.tv_sec - rhs.tv_sec - 1 - (-raw / 1_000_000_000)
            return timespec(tv_sec: s, tv_nsec: ns)
        }
    }
    
    public static var zero: timespec {
        timespec()
    }
}

public extension timeval {
    @inlinable
    static func now() -> timeval {
        var timeval = timeval()
        gettimeofday(&timeval, nil)
        return timeval
    }
}

#if hasFeature(RetroactiveAttribute)
extension timeval: @retroactive Equatable {}
extension timeval: @retroactive Comparable {}
extension timeval: @retroactive Hashable {}
extension timeval: @retroactive AdditiveArithmetic {}
#else
extension timeval: Equatable {}
extension timeval: Comparable {}
extension timeval: Hashable {}
extension timeval: AdditiveArithmetic {}
#endif

extension timeval /* Equatable */ {
    public static func == (lhs: timeval, rhs: timeval) -> Bool {
        lhs.tv_sec == rhs.tv_sec && lhs.tv_usec == rhs.tv_usec
    }
}

extension timeval /* Comparable */ {
    public static func < (lhs: timeval, rhs: timeval) -> Bool {
        if lhs.tv_sec < rhs.tv_sec { return true }
        if lhs.tv_sec > rhs.tv_sec { return false }
        
        if lhs.tv_usec < rhs.tv_usec { return true }
        
        return false
    }
}

extension timeval /* Hashable */ {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tv_sec)
        hasher.combine(tv_usec)
    }
}

extension timeval /* AdditiveArithmetic */ {
    public static func + (lhs: timeval, rhs: timeval) -> timeval {
        let raw = rhs.tv_usec + lhs.tv_usec
        let ns = raw % 1_000_000
        let s = lhs.tv_sec + rhs.tv_sec + (Int(raw) / 1_000_000)
        return timeval(tv_sec: s, tv_usec: ns)
    }
    
    public static func - (lhs: timeval, rhs: timeval) -> timeval {
        let raw = lhs.tv_usec - rhs.tv_usec
        
        if raw >= 0 {
            let ns = raw % 1_000_000
            let s = lhs.tv_sec - rhs.tv_sec + (Int(raw) / 1_000_000)
            return timeval(tv_sec: s, tv_usec: ns)
        } else {
            let ns = 1_000_000 - (-raw % 1_000_000)
            let s = lhs.tv_sec - rhs.tv_sec - 1 - (-Int(raw) / 1_000_000)
            return timeval(tv_sec: s, tv_usec: ns)
        }
    }
    
    public static var zero: timeval {
        timeval()
    }
}

import LibC

extension ContinuousClock.Instant {
#if canImport(Darwin.C)
    var timeoutSinceNow: timespec {
        let components = Self.now.duration(to: self).components
        return timespec(
            tv_sec: max(0, Int(components.seconds)),
            tv_nsec: max(0, Int(components.attoseconds / 1_000_000_000)))
    }
#elseif canImport(Glibc) || canImport(Musl) || canImport(Android)
    var timeoutSinceNow: CInt {
        let components = Self.now.duration(to: self).components
        let timeout = components.seconds * 1_000 +
        components.attoseconds / 1_000_000_000_000_000
        return max(0, CInt(clamping: timeout))
    }
#endif
}

extension Duration {
#if canImport(Darwin.C)
    var timeoutSinceNow: timespec {
        ContinuousClock.now.advanced(by: self).timeoutSinceNow
    }
#elseif canImport(Glibc) || canImport(Musl) || canImport(Android)
    var timeoutSinceNow: CInt {
        ContinuousClock.now.advanced(by: self).timeoutSinceNow
    }
#endif
}

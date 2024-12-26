import LibC

@inlinable
internal func _get_system_timestamp() -> UInt64 {
    let timestamp: UInt64
    if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
        var time = timespec()
        clock_gettime(CLOCK_REALTIME, &time)
        timestamp =
            (UInt64(bitPattern: Int64(time.tv_sec)) &* 10_000_000)
            &+ (UInt64(bitPattern: Int64(time.tv_nsec)) / 100)
    } else {
        var time = timeval()
        gettimeofday(&time, nil)
        timestamp =
            (UInt64(bitPattern: Int64(time.tv_sec)) &* 10_000_000)
            &+ (UInt64(bitPattern: Int64(time.tv_usec)) &* 10)
    }
    return timestamp & 0x0FFF_FFFF_FFFF_FFFF
}

@inlinable
internal func _unix_to_uuid_timestamp(unix: UInt64) -> UInt64 {
    unix &+ 0x01B2_1DD2_1381_4000
}

@inlinable
internal func _uuid_timestamp_to_unix(timestamp: UInt64) -> UInt64 {
    timestamp &- 0x01B2_1DD2_1381_4000
}

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

@usableFromInline
internal var _uuidv6GeneratorStateLock:
UnsafeMutablePointer<os_unfair_lock> = {
    let lock = UnsafeMutablePointer<os_unfair_lock>.allocate(
        capacity: 1)
    lock.initialize(to: os_unfair_lock())
    return lock
}()

@inlinable
public func thread_lock() {
    os_unfair_lock_lock(_uuidv6GeneratorStateLock)
}

@inlinable
public func thread_unlock() {
    os_unfair_lock_unlock(_uuidv6GeneratorStateLock)
}

#elseif os(Linux) || os(Android)

@usableFromInline
internal var _uuidv6GeneratorStateLock:
UnsafeMutablePointer<pthread_mutex_t> = {
    let mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(
        capacity: 1)
    mutex.initialize(to: pthread_mutex_t())
    
    var attrs = pthread_mutexattr_t()
    guard pthread_mutexattr_init(&attrs) == 0 else {
        preconditionFailure("Failed to create pthread_mutexattr_t")
    }
    // Use adaptive spinning before calling in to the kernel (GNU extension).
    let _ = pthread_mutexattr_settype(
        &attrs, CInt(PTHREAD_MUTEX_ADAPTIVE_NP))
    guard pthread_mutex_init(mutex, &attrs) == 0 else {
        preconditionFailure("Failed to create pthread_mutex_t")
    }
    pthread_mutexattr_destroy(&attrs)
    
    return mutex
}()

@inlinable
public func thread_lock() {
    pthread_mutex_lock(_uuidv6GeneratorStateLock)
}

@inlinable
public func thread_unlock() {
    pthread_mutex_unlock(_uuidv6GeneratorStateLock)
}

#endif

#if canImport(os)
internal import os
#if canImport(C.os.lock)
internal import C.os.lock
#endif
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WinSDK)
import WinSDK
#endif

// Internal implementation for a cheap lock to aid sharing code across platforms
internal struct Lock {
#if canImport(os)
    typealias Primitive = os_unfair_lock
#elseif os(FreeBSD)
    typealias Primitive = pthread_mutex_t?
#elseif canImport(Bionic) || canImport(Glibc) || canImport(Musl)
    typealias Primitive = pthread_mutex_t
#elseif canImport(WinSDK)
    typealias Primitive = SRWLOCK
#elseif os(WASI)
    // WASI is single-threaded, so we don't need a lock.
    typealias Primitive = Void
#endif

    typealias PlatformLock = UnsafeMutablePointer<Primitive>
    private var platformLock: PlatformLock

    internal static func initialize(_ platformLock: PlatformLock) {
#if canImport(os)
        platformLock.initialize(to: os_unfair_lock())
#elseif canImport(Bionic) || canImport(Glibc) || canImport(Musl)
        pthread_mutex_init(platformLock, nil)
#elseif canImport(WinSDK)
        InitializeSRWLock(platformLock)
#elseif os(WASI)
        // no-op
#else
#error("LockedState.Lock.initialize is unimplemented on this platform")
#endif
    }

    internal static func deinitialize(_ platformLock: PlatformLock) {
#if canImport(Bionic) || canImport(Glibc) || canImport(Musl)
        pthread_mutex_destroy(platformLock)
#endif
        platformLock.deinitialize(count: 1)
    }

    internal static func lock(_ platformLock: PlatformLock) {
#if canImport(os)
        os_unfair_lock_lock(platformLock)
#elseif canImport(Bionic) || canImport(Glibc) || canImport(Musl)
        pthread_mutex_lock(platformLock)
#elseif canImport(WinSDK)
        AcquireSRWLockExclusive(platformLock)
#elseif os(WASI)
        // no-op
#else
#error("LockedState.Lock.lock is unimplemented on this platform")
#endif
    }

    internal static func unlock(_ platformLock: PlatformLock) {
#if canImport(os)
        os_unfair_lock_unlock(platformLock)
#elseif canImport(Bionic) || canImport(Glibc) || canImport(Musl)
        pthread_mutex_unlock(platformLock)
#elseif canImport(WinSDK)
        ReleaseSRWLockExclusive(platformLock)
#elseif os(WASI)
        // no-op
#else
#error("LockedState.Lock.unlock is unimplemented on this platform")
#endif
    }
}

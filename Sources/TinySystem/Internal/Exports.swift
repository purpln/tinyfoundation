#if compiler(>=6.0)
public import LibC
#else
import LibC
#endif

#if os(Windows)
public var system_errno: CInt {
    get {
        var value: CInt = 0
        _ = ucrt._get_errno(&value)
        return value
    }
    set {
        _ = ucrt._set_errno(newValue)
    }
}
#else
public var system_errno: CInt {
    get { errno }
    set { errno = newValue }
}
#endif

public func system_strerror(_ number: CInt) -> UnsafeMutablePointer<CChar>? {
    strerror(number)
}

/// The C `off_t` type.
public typealias PlatformOffset = off_t

#if os(Windows)
/// The C `mode_t` type.
public typealias PlatformMode = CInt

/// The platform's preferred character type. On Unix, this is an 8-bit C
/// `char` (which may be signed or unsigned, depending on platform). On
/// Windows, this is `UInt16` (a "wide" character).
public typealias PlatformChar = UInt16

/// The platform's preferred Unicode encoding. On Unix this is UTF-8 and on
/// Windows it is UTF-16. Native strings may contain invalid Unicode,
/// which will be handled by either error-correction or failing, depending
/// on API.
public typealias PlatformUnicodeEncoding = UTF16
#else
/// The C `mode_t` type.
public typealias PlatformMode = mode_t

/// The platform's preferred character type. On Unix, this is an 8-bit C
/// `char` (which may be signed or unsigned, depending on platform). On
/// Windows, this is `UInt16` (a "wide" character).
public typealias PlatformChar = CChar

/// The platform's preferred Unicode encoding. On Unix this is UTF-8 and on
/// Windows it is UTF-16. Native strings may contain invalid Unicode,
/// which will be handled by either error-correction or failing, depending
/// on API.
public typealias PlatformUnicodeEncoding = UTF8
#endif

// strlen for the platform string
public func system_platform_strlen(_ s: UnsafePointer<PlatformChar>) -> Int {
#if os(Windows)
    return wcslen(s)
#else
    return strlen(s)
#endif
}

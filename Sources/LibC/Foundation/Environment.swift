@inlinable
public var environment: [String: String] {
#if os(macOS) || os(iOS) || os(Linux) || os(Android) || os(WASI)
    return parse(environ: environ)
#elseif os(Windows)
    return parseWindowsEnvironment()
#else
#warning("Platform-specific implementation missing: environment variables unavailable")
    return [:]
#endif
}

#if os(macOS) || os(iOS) || os(Linux) || os(Android) || os(WASI)
@inlinable
internal func parse(environ: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> [String: String] {
    var result = [String: String]()
    
    for i in 0... {
        guard let pointer = environ[i] else { break }
        
        guard let row = String(validatingCString: pointer),
           let (key, value) = split(row: row) else {
            continue
        }
        
        result[key] = value
    }
    
    return result
}

@inlinable
internal func split(row: String) -> (key: String, value: String)? {
    row.firstIndex(of: "=").map { index in
        let key = String(row.prefix(upTo: index))
        let value = String(row.suffix(from: index).dropFirst())
        return (key, value)
    }
}

@inlinable nonisolated(unsafe)
internal var environ: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?> {
    _platform_shims_lock_environ()
    defer {
        _platform_shims_unlock_environ()
    }
    return _platform_shims_get_environ()
}
#elseif os(Windows)
@inlinable
internal func parseWindowsEnvironment() -> [String: String] {
    guard let environ = GetEnvironmentStringsW() else {
        return [:]
    }
    defer {
        FreeEnvironmentStringsW(environ)
    }
    
    var result = [String: String]()
    var rowp = environ
    while rowp.pointee != 0 {
        defer {
            rowp += wcslen(rowp) + 1
        }
        if let row = String.decodeCString(rowp, as: UTF16.self)?.result,
           let (key, value) = _splitEnvironmentVariable(row) {
            result[key] = value
        }
    }
    return result
}
#endif

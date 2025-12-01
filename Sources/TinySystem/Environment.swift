#if compiler(>=6.0)
public import LibC
#else
import LibC
#endif

public var environment: [String: String] {
#if os(Windows)
    return parseWindowsEnvironment()
#else
    return parse(environ: environ)
#endif
}

@inlinable
internal var environ: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?> {
    _platform_shims_lock_environ()
    defer {
        _platform_shims_unlock_environ()
    }
    return _platform_shims_get_environ()
}

@inlinable
internal func split(row: String) -> (key: String, value: String)? {
    row.firstIndex(of: "=").map { index in
        let key = String(row.prefix(upTo: index))
        let value = String(row.suffix(from: index).dropFirst())
        return (key, value)
    }
}

#if os(Windows)
@inlinable
internal func parseWindowsEnvironment() -> [String: String] {
    guard let environ = GetEnvironmentStringsW() else {
        return [:]
    }
    defer {
        FreeEnvironmentStringsW(environ)
    }
    
    var result = [String: String]()
    var pointer = environ
    while pointer.pointee != 0 {
        defer {
            pointer += wcslen(pointer) + 1
        }
        if let row = String.decodeCString(pointer, as: UTF16.self)?.result,
           let (key, value) = split(row: row) {
            result[key] = value
        }
    }
    return result
}
#else
@inlinable
internal func parse(environ: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> [String: String] {
    var result = [String: String]()
    
    for i in 0... {
        guard let pointer = environ[i] else { break }
        
        let row = String(cString: pointer)
        
        guard let (key, value) = split(row: row) else {
            continue
        }
        
        result[key] = value
    }
    
    return result
}
#endif

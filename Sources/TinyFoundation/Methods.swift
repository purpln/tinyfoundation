#if !os(Windows)

#if compiler(>=6.0)
public import LibC

public func lstat(_ path: String) throws(Errno) -> stat {
    var info = stat()
    try nothingOrErrno(retryOnInterrupt: false, {
        lstat(path, &info)
    }).get()
    return info
}

public func stat(_ path: String) throws(Errno) -> stat {
    var info = stat()
    try nothingOrErrno(retryOnInterrupt: false, {
        stat(path, &info)
    }).get()
    return info
}
#else
import LibC

public func lstat(_ path: String) throws -> stat {
    var info = stat()
    try nothingOrErrno(retryOnInterrupt: false, {
        lstat(path, &info)
    }).get()
    return info
}

public func stat(_ path: String) throws -> stat {
    var info = stat()
    try nothingOrErrno(retryOnInterrupt: false, {
        stat(path, &info)
    }).get()
    return info
}
#endif

#endif

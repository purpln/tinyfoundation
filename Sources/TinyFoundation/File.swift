import LibC

#if !os(Windows)
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
#endif

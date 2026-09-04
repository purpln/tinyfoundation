#if !os(Windows)
#if compiler(>=6.0)
public import LibC
#else
import LibC
#endif

#if compiler(>=6.0)
public func lstat(_ path: String) throws(Errno) -> stat {
    try _lstat(path).get()
}

public func stat(_ path: String) throws(Errno) -> stat {
    try _stat(path).get()
}
#else
public func lstat(_ path: String) throws -> stat {
    try _lstat(path).get()
}

public func stat(_ path: String) throws -> stat {
    try _stat(path).get()
}
#endif
@inline(__always)
private func _lstat(_ path: String) -> Result<stat, Errno> {
    var info = stat()
    return nothingOrErrno(retryOnInterrupt: false, {
        lstat(path, &info)
    }).map({ _ in info })
}

@inline(__always)
private func _stat(_ path: String) -> Result<stat, Errno> {
    var info = stat()
    return nothingOrErrno(retryOnInterrupt: false, {
        stat(path, &info)
    }).map({ _ in info })
}

#endif

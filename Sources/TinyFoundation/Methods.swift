#if !os(Windows)

#if compiler(>=6.0)
public import LibC

public func lstat(_ path: String) throws(Errno) -> stat {
    try _lstat(path).get()
}

public func stat(_ path: String) throws(Errno) -> stat {
    try _stat(path).get()
}
#else
import LibC

public func lstat(_ path: String) throws -> stat {
    try _lstat(path).get()
}

public func stat(_ path: String) throws -> stat {
    try _stat(path).get()
}
#endif
@inline(__always)
private func _lstat(_ path: String) -> Result<stat, Errno> {
    do {
        var info = stat()
        try nothingOrErrno(retryOnInterrupt: false, {
            lstat(path, &info)
        }).get()
        return .success(info)
    } catch {
        return .failure(error)
    }
}

@inline(__always)
private func _stat(_ path: String) -> Result<stat, Errno> {
    do {
        var info = stat()
        try nothingOrErrno(retryOnInterrupt: false, {
            stat(path, &info)
        }).get()
        return .success(info)
    } catch {
        return .failure(error)
    }
}

#endif

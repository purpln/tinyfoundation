import LibC
import TinySystem

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

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
public func confstr(_ name: CInt) -> String? {
    let length = system_confstr(name, nil, 0)
    guard length > 0 else { return nil }
    var buffer = [CChar](repeating: 0, count: length)
    let result = system_confstr(name, &buffer, buffer.count)
    guard result == length else { return nil }
    return buffer.withUnsafeBufferPointer({
        String(cString: $0.baseAddress!)
    })
}
#endif

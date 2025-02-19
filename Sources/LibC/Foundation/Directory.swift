public func getCurrentDirectory() throws(Errno) -> String {
    guard let path = system_getcwd(nil, 0) else {
        throw Errno.current
    }
    defer {
        system_free(path)
    }
    return String(cString: path)
}

public func setCurrentDirectory(_ path: String) throws(Errno) {
    try nothingOrErrno(retryOnInterrupt: false, {
        chdir(path)
    }).get()
}

public func getHomeDirectory(for user: String? = nil) -> String? {
#if !os(WASI)
    let id: UnsafeMutablePointer<passwd>?
    if let user = user {
        id = getpwnam(user)
    } else {
        id = getpwuid(getuid())
    }
    guard let dir = id, let pointer = dir.pointee.pw_dir else {
        return nil
    }
    return String(cString: pointer)
#else
    return nil
#endif
}

public func getDocumentsDirectory() -> String? {
#if os(macOS) || os(iOS)
    guard let value = getenv("HOME") else { return nil }
    return String(cString: value)
#elseif os(Linux) || os(Android)
    let id: UnsafeMutablePointer<passwd>? = getpwuid(getuid())
    guard let dir = id, let pointer = dir.pointee.pw_dir else {
        return nil
    }
    return String(cString: pointer)
#else
    return nil
#endif
}

public func getExecutablePath() -> String? {
#if os(macOS) || os(iOS)
    var result: String?
#if DEBUG
    var capacity = UInt32(1) // force looping
#else
    var capacity = UInt32(PATH_MAX)
#endif
    while result == nil {
        withUnsafeTemporaryAllocation(of: CChar.self, capacity: Int(capacity)) { buffer in
            // _NSGetExecutablePath returns 0 on success and -1 if bufferCount is
            // too small. If that occurs, we'll return nil here and loop with the
            // new value of bufferCount.
            if 0 == _NSGetExecutablePath(buffer.baseAddress, &capacity) {
                result = String(cString: buffer.baseAddress!)
            }
        }
    }
    return result!
#elseif os(Linux) || os(Android)
    let capacity = Int(PATH_MAX)
    let buffer = [UInt8](unsafeUninitializedCapacity: capacity) { buffer, count in
        count = readlink("/proc/self/exe", buffer.baseAddress!, capacity)
    }
    return String(decoding: buffer, as: UTF8.self)
#else
    return nil
#endif
}

public func getCurrentDirectory() -> String {
    let capacity = Int(PATH_MAX)
    //var buffer = [UInt8](repeating: 0, count: capacity)
    //_ = buffer.withUnsafeMutableBufferPointer({ pointer in
    //    getcwd(pointer.baseAddress!, capacity)
    //})
    let buffer = [UInt8](unsafeUninitializedCapacity: capacity) { buffer, count in
        getcwd(buffer.baseAddress!, capacity)
        var length = 0
        while buffer.baseAddress?.advanced(by: length).pointee != 0 {
            length += 1
        }
        count = length
    }
    return String(decoding: buffer, as: UTF8.self)
}

public func setCurrentDirectory(_ path: String) throws {
    try nothingOrErrno(retryOnInterrupt: false, {
        chdir(path)
    }).get()
}

public func getHomeDirectory(for user: String? = nil) -> String? {
    let id: UnsafeMutablePointer<passwd>?
    if let user = user {
        id = getpwnam(user)
    } else {
        id = getpwuid(getuid())
    }
    guard let dir = id, let pointer = dir.pointee.pw_dir else {
        return nil
    }
    
    //let buffer = UnsafeBufferPointer<UInt8>.init(start: UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self), count: length)
    //let string = String(decoding: buffer, as: UTF8.self)
    //print(Array(string.utf8))
    //return string
    return String(cString: pointer)
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
#if os(macOS) || targetEnvironment(macCatalyst)
    let buffer = [UInt8](unsafeUninitializedCapacity: Int(PROC_PIDPATHINFO_SIZE)) { buffer, count in
        let result = proc_pidpath(getpid(), buffer.baseAddress, UInt32(PROC_PIDPATHINFO_SIZE))
        count = Int(result)
    }
    return String(decoding: buffer, as: UTF8.self)
#elseif os(iOS)
    String(cString: realpath(CommandLine.arguments[0], nil))
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

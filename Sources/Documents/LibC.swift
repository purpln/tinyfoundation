import LibC

internal func attributes(at path: String) -> stat? {
    var buffer = stat()
    guard lstat(path, &buffer) == 0 else {
        return nil
    }
    return buffer
}

internal func exists(at path: String) -> Bool {
    var s = stat()
    if lstat(path, &s) >= 0 {
        // don't chase the link for this magic case -- we might be /Net/foo
        // which is a symlink to /private/Net/foo which is not yet mounted...
        if (s.st_mode & S_IFMT) == S_IFLNK {
            if (s.st_mode & S_ISVTX) == S_ISVTX {
                return true
            }
            // chase the link; too bad if it is a slink to /Net/foo
            stat(path, &s)
        }
    } else {
        return false
    }
    return true
}

internal func homeDirectory(for user: String? = nil) -> String {
#if os(Android)
    let id: UnsafeMutablePointer<passwd>?
#else
    let id: UnsafeMutablePointer<passwd>
#endif
    if let user = user {
        id = getpwnam(user)
    } else {
        id = getpwuid(getuid())
    }
#if os(Android)
    guard let dir = id, let pointer = dir.pointee.pw_dir else {
        preconditionFailure()
    }
    return String(cString: pointer)
#else
    return String(cString: id.pointee.pw_dir)
#endif
}

internal func getCurrentDirectory() throws -> String {
    var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
    guard
        let result = buffer.withUnsafeMutableBufferPointer({ pointer in
            getcwd(pointer.baseAddress!, pointer.count)
        })
    else {
        throw Errno()
    }
    return String(cString: result)
}

internal func setCurrentDirectory(_ path: String) throws {
    guard chdir(path) == -1 else { return }
    throw Errno()
}

internal var documentsPath: String {
#if os(macOS) || os(iOS)
    String(cString: getenv("HOME"))
#elseif os(Linux)
    String(cString: getpwuid(getuid()).pointee.pw_dir)
#elseif os(Android)
    String(cString: getpwuid(getuid())!.pointee.pw_dir!)
#else
#error("unsupported os")
#endif
}

internal var executablePath: String {
#if os(macOS) || targetEnvironment(macCatalyst)
    var path = [CChar](repeating: 0, count: Int(PROC_PIDPATHINFO_SIZE) + 1)
    let result = proc_pidpath(
        getpid(), &path, UInt32(PROC_PIDPATHINFO_SIZE))
    guard result >= 0 else { return "" }
    return String(cString: path)
#elseif os(iOS)
    String(cString: realpath(CommandLine.arguments[0], nil))
#elseif os(Linux) || os(Android)
    var path = [CChar](repeating: 0, count: Int(PATH_MAX) + 1)
    let result = readlink("/proc/self/exe", &path, Int(PATH_MAX))
    guard result >= 0 else { return "" }
    return String(cString: path)
#else
#error("unsupported os")
#endif
}

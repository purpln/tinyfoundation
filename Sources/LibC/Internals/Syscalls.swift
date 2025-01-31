// unlink
public func system_unlink(
    _ path: UnsafePointer<CChar>?
) -> Int32 {
#if os(Android) || os(Linux)
    var zero = CChar.zero
    return withUnsafePointer(to: &zero) {
        // has a non-nullable pointer
        unlink(path ?? $0)
    }
#else
    unlink(path)
#endif
}

// accept
public func system_accept(
    _ descriptor: CInt,
    _ address: UnsafeMutablePointer<sockaddr>?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> Int32 {
    accept(descriptor, address, length)
}

// bind
public func system_bind(
    _ descriptor: CInt,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> Int32 {
    bind(descriptor, address!, length)
}

// connect
public func system_connect(
    _ descriptor: CInt,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> Int32 {
    connect(descriptor, address!, length)
}

// listen
public func system_listen(
    _ descriptor: CInt,
    _ backlog: Int32
) -> Int32 {
    listen(descriptor, backlog)
}

// recieve
public func system_recv(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int,
    _ flags: Int32
) -> Int {
    recv(descriptor, buffer, size, flags)
}

public func system_recvfrom(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int,
    _ flags: Int32,
    _ address: UnsafeMutablePointer<sockaddr>?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> Int {
    recvfrom(descriptor, buffer, size, flags, address, length)
}

// send
public func system_send(
    _ descriptor: CInt,
    _ buffer: UnsafeRawPointer?,
    _ size: Int,
    _ flags: Int32
) -> Int {
#if os(Android)
    var zero = UInt8.zero
    return withUnsafePointer(to: &zero) {
        // has a non-nullable pointer
        send(descriptor, buffer ?? UnsafeRawPointer($0), size, flags)
    }
#else
    send(descriptor, buffer, size, flags)
#endif
}

public func system_sendto(
    _ descriptor: CInt,
    _ buffer: UnsafeRawPointer?,
    _ size: Int,
    _ flags: Int32,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> Int {
#if os(Android)
    var zero = UInt8.zero
    return withUnsafePointer(to: &zero) {
        // has a non-nullable pointer
        sendto(descriptor, buffer ?? UnsafeRawPointer($0), size, flags, address, length)
    }
#else
    sendto(descriptor, buffer, size, flags, address, length)
#endif
}

// open
public func system_open(
    _ path: UnsafePointer<CChar>,
    _ oflag: Int32
) -> CInt {
    open(path, oflag)
}

public func system_open(
    _ path: UnsafePointer<CChar>,
    _ oflag: Int32,
    _ mode: mode_t
) -> CInt {
    open(path, oflag, mode)
}

// close
public func system_close(
    _ descriptor: CInt
) -> CInt {
    close(descriptor)
}

// read
public func system_read(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int
) -> Int {
    read(descriptor, buffer, size)
}

// pread
public func system_pread(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int,
    _ offset: off_t
) -> Int {
#if os(Android)
    var zero = UInt8.zero
    return withUnsafeMutablePointer(to: &zero) {
        // has a non-nullable pointer
        pread(descriptor, buffer ?? UnsafeMutableRawPointer($0), size, offset)
    }
#else
    pread(descriptor, buffer, size, offset)
#endif
}

// lseek
public func system_lseek(
    _ descriptor: CInt,
    _ offset: off_t,
    _ whence: Int32
) -> off_t {
    lseek(descriptor, offset, whence)
}

// write
public func system_write(
    _ descriptor: CInt,
    _ buffer: UnsafeRawPointer?,
    _ size: Int
) -> Int {
    write(descriptor, buffer, size)
}

// pwrite
public func system_pwrite(
    _ descriptor: CInt,
    _ buffer: UnsafeRawPointer?,
    _ size: Int,
    _ offset: off_t
) -> Int {
#if os(Android)
    var zero = UInt8.zero
    return withUnsafeMutablePointer(to: &zero) {
        // this pwrite has a non-nullable `buf` pointer
        pwrite(descriptor, buffer ?? UnsafeRawPointer($0), size, offset)
    }
#else
    return pwrite(descriptor, buffer, size, offset)
#endif
}

#if !os(WASI)
public func system_dup(_ fd: Int32) -> Int32 {
    dup(fd)
}

public func system_dup2(_ fd: Int32, _ fd2: Int32) -> Int32 {
    dup2(fd, fd2)
}
#endif

#if !os(WASI)
public func system_pipe(_ fds: UnsafeMutablePointer<Int32>) -> CInt {
    pipe(fds)
}
#endif

public func system_ftruncate(_ fd: Int32, _ length: off_t) -> Int32 {
    ftruncate(fd, length)
}

public func system_mkdir(
    _ path: UnsafePointer<PlatformChar>,
    _ mode: PlatformMode
) -> CInt {
    mkdir(path, mode)
}

public func system_rmdir(
    _ path: UnsafePointer<PlatformChar>
) -> CInt {
    rmdir(path)
}

#if canImport(Darwin.C)
public let SYSTEM_CS_DARWIN_USER_TEMP_DIR = _CS_DARWIN_USER_TEMP_DIR

public func system_confstr(
    _ name: CInt,
    _ buf: UnsafeMutablePointer<PlatformChar>,
    _ len: Int
) -> Int {
    confstr(name, buf, len)
}
#endif

#if !os(Windows)
internal let SYSTEM_AT_REMOVE_DIR = AT_REMOVEDIR
internal let SYSTEM_DT_DIR = DT_DIR
internal typealias system_dirent = dirent
#if os(Linux) || os(Android) || os(FreeBSD)
public typealias system_DIRPtr = OpaquePointer
#else
public typealias system_DIRPtr = UnsafeMutablePointer<DIR>
#endif

public func system_unlinkat(
    _ fd: CInt,
    _ path: UnsafePointer<PlatformChar>,
    _ flag: CInt
) -> CInt {
    unlinkat(fd, path, flag)
}

public func system_fdopendir(
    _ fd: CInt
) -> system_DIRPtr? {
    fdopendir(fd)
}

public func system_readdir(
    _ dir: system_DIRPtr
) -> UnsafeMutablePointer<dirent>? {
    readdir(dir)
}

public func system_rewinddir(
    _ dir: system_DIRPtr
) {
    rewinddir(dir)
}

public func system_closedir(
    _ dir: system_DIRPtr
) -> CInt {
    closedir(dir)
}

public func system_openat(
    _ fd: CInt,
    _ path: UnsafePointer<PlatformChar>,
    _ oflag: Int32
) -> CInt {
    openat(fd, path, oflag)
}
#endif

public func system_umask(
    _ mode: PlatformMode
) -> PlatformMode {
    umask(mode)
}

public func system_getenv(
    _ name: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>? {
    getenv(name)
}

// unlink
public func system_unlink(
    _ path: UnsafePointer<CChar>?
) -> CInt {
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
#if !os(WASI)
// accept
public func system_accept(
    _ descriptor: CInt,
    _ address: UnsafeMutablePointer<sockaddr>?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> CInt {
    accept(descriptor, address, length)
}

// bind
public func system_bind(
    _ descriptor: CInt,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> CInt {
    bind(descriptor, address!, length)
}

// connect
public func system_connect(
    _ descriptor: CInt,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> CInt {
    connect(descriptor, address!, length)
}

// listen
public func system_listen(
    _ descriptor: CInt,
    _ backlog: CInt
) -> CInt {
    listen(descriptor, backlog)
}

// recieve
public func system_recv(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int,
    _ flags: CInt
) -> Int {
    recv(descriptor, buffer, size, flags)
}

public func system_recvfrom(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int,
    _ flags: CInt,
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
    _ flags: CInt
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
    _ flags: CInt,
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
#endif
// open
public func system_open(
    _ path: UnsafePointer<CChar>,
    _ oflag: CInt
) -> CInt {
    open(path, oflag)
}

public func system_open(
    _ path: UnsafePointer<CChar>,
    _ oflag: CInt,
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
    _ whence: CInt
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
    pwrite(descriptor, buffer, size, offset)
#endif
}

#if !os(WASI)
public func system_dup(_ descriptor: CInt) -> CInt {
    dup(descriptor)
}

public func system_dup2(_ descriptor1: CInt, _ descriptor2: CInt) -> CInt {
    dup2(descriptor1, descriptor2)
}
#endif

#if !os(WASI)
public func system_pipe(_ descriptors: UnsafeMutablePointer<CInt>) -> CInt {
    pipe(descriptors)
}
#endif

public func system_ftruncate(_ descriptor: CInt, _ length: off_t) -> CInt {
    ftruncate(descriptor, length)
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

#if os(macOS) || os(iOS)
public let SYSTEM_CS_DARWIN_USER_TEMP_DIR = _CS_DARWIN_USER_TEMP_DIR

public func system_confstr(
    _ name: CInt,
    _ buffer: UnsafeMutablePointer<PlatformChar>,
    _ length: Int
) -> Int {
    confstr(name, buffer, length)
}
#endif

#if !os(Windows)
internal let SYSTEM_AT_REMOVE_DIR = AT_REMOVEDIR
internal let SYSTEM_DT_DIR = _DT_DIR
internal typealias system_dirent = dirent
#if os(Linux) || os(Android) || os(WASI)
public typealias system_DIRPtr = OpaquePointer
#else
public typealias system_DIRPtr = UnsafeMutablePointer<DIR>
#endif

public func system_unlinkat(
    _ descriptor: CInt,
    _ path: UnsafePointer<PlatformChar>,
    _ flag: CInt
) -> CInt {
    unlinkat(descriptor, path, flag)
}

public func system_fdopendir(
    _ descriptor: CInt
) -> system_DIRPtr? {
    fdopendir(descriptor)
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
    _ descriptor: CInt,
    _ path: UnsafePointer<PlatformChar>,
    _ oflag: CInt
) -> CInt {
    openat(descriptor, path, oflag)
}
#endif

public func system_umask(
    _ mode: PlatformMode
) -> PlatformMode {
#if !os(WASI)
    umask(mode)
#else
    0755
#endif
}

public func system_getenv(
    _ name: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>? {
    getenv(name)
}

#if !os(Windows)
public func system_getcwd(
    _ buffer: UnsafeMutablePointer<PlatformChar>?,
    _ size: size_t
) -> UnsafeMutablePointer<PlatformChar>? {
    getcwd(buffer, size)
}
#endif
#if !os(Windows)
public func system_free(
    _ pointer: UnsafeMutableRawPointer?
) {
  free(pointer)
}
#endif

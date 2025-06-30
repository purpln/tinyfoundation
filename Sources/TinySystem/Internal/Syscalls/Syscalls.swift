import LibC

// open
public func system_open(
    _ path: UnsafePointer<PlatformChar>,
    _ oflag: CInt
) -> CInt {
    open(path, oflag)
}

public func system_open(
    _ path: UnsafePointer<PlatformChar>,
    _ oflag: CInt,
    _ mode: PlatformMode
) -> CInt {
    open(path, oflag, mode)
}

// close
public func system_close(
    _ descriptor: CInt
) -> CInt {
    close(descriptor)
}

// remove
public func system_remove(
    _ path: UnsafePointer<PlatformChar>
) -> CInt {
    remove(path)
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

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
public let SYSTEM_CS_DARWIN_USER_DIR = _CS_DARWIN_USER_DIR
public let SYSTEM_CS_DARWIN_USER_TEMP_DIR = _CS_DARWIN_USER_TEMP_DIR
public let SYSTEM_CS_DARWIN_USER_CACHE_DIR = _CS_DARWIN_USER_CACHE_DIR

public func system_confstr(
    _ name: CInt,
    _ buffer: UnsafeMutablePointer<PlatformChar>?,
    _ length: Int
) -> Int {
    confstr(name, buffer, length)
}
#endif

#if !os(Windows)

#if os(Linux) || os(Android) || os(WASI)
public typealias system_DIRPtr = OpaquePointer
#else
public typealias system_DIRPtr = UnsafeMutablePointer<DIR>
#endif

#if canImport(Android) || os(WASI)
public typealias system_FILEPtr = OpaquePointer
#else
public typealias system_FILEPtr = UnsafeMutablePointer<FILE>
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
    _ directory: system_DIRPtr
) -> UnsafeMutablePointer<dirent>? {
    readdir(directory)
}

public func system_rewinddir(
    _ directory: system_DIRPtr
) {
    rewinddir(directory)
}

public func system_opendir(
    _ path: UnsafePointer<PlatformChar>
) -> system_DIRPtr? {
    opendir(path)
}

public func system_closedir(
    _ directory: system_DIRPtr
) -> CInt {
    closedir(directory)
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
    _ name: UnsafePointer<PlatformChar>
) -> UnsafeMutablePointer<PlatformChar>? {
    getenv(name)
}

public func system_setenv(
    _ name: UnsafePointer<PlatformChar>,
    _ value: UnsafePointer<PlatformChar>,
    _ overwrite: Int32
) -> CInt {
    setenv(name, value, overwrite)
}

public func system_unsetenv(
    _ name: UnsafePointer<PlatformChar>
) -> CInt {
    unsetenv(name)
}

public func system_getcwd(
    _ buffer: UnsafeMutablePointer<PlatformChar>?,
    _ size: size_t
) -> UnsafeMutablePointer<PlatformChar>? {
    getcwd(buffer, size)
}

public func system_chdir(
    _ path: UnsafePointer<PlatformChar>
) -> CInt {
    chdir(path)
}

public func system_free(
    _ pointer: UnsafeMutableRawPointer?
) {
    free(pointer)
}

public func system_symlink(
    _ original: UnsafePointer<PlatformChar>,
    _ target: UnsafePointer<PlatformChar>
) -> CInt {
    symlink(original, target)
}
#if os(Windows)
public func system_closesocket(
    _ descriptor: CInt
) -> CInt {
    closesocket(descriptor)
}
#endif

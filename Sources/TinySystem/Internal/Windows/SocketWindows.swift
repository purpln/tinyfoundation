#if os(Windows)
import WinSDK

private let winsockStartupResult: CInt = {
    var data = WSADATA()
    return WSAStartup(0x0202, &data)
}()

@inline(__always)
internal func socket(
    _ family: CInt,
    _ type: CInt,
    _ protocol: CInt
) -> CInt {
    guard winsockStartupResult == 0 else {
        system_errno = EIO
        return -1
    }
    let result = socket(family, type, `protocol`) as SOCKET
    guard result != INVALID_SOCKET else {
        setErrnoFromLastSocketError()
        return -1
    }
    return CInt(result)
}

@inline(__always)
internal func closesocket(
    _ descriptor: CInt
) -> CInt {
    let result = closesocket(SOCKET(descriptor))
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}

@inline(__always)
internal func inet_ntop(
    _ family: CInt,
    _ address: UnsafeRawPointer?,
    _ value: UnsafeMutablePointer<CChar>?,
    _ length: socklen_t
) -> UnsafePointer<CChar>? {
    inet_ntop(family, address, value, Int(length))
}

@inline(__always)
internal func getsockopt(
    _ descriptor: CInt,
    _ level: CInt,
    _ name: CInt,
    _ value: UnsafeMutableRawPointer?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> CInt {
    let result = getsockopt(SOCKET(descriptor), level, name, value, length)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}
@inline(__always)
internal func setsockopt(
    _ descriptor: CInt,
    _ level: CInt,
    _ name: CInt,
    _ value: UnsafeRawPointer?,
    _ length: socklen_t
) -> CInt {
    let result = setsockopt(SOCKET(descriptor), level, name, value, length)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}

@inline(__always)
internal func getsockname(
    _ descriptor: CInt,
    _ name: UnsafeMutablePointer<sockaddr>?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> CInt {
    let result = getsockname(SOCKET(descriptor), name, length)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}

@inline(__always)
internal func getpeername(
    _ descriptor: CInt,
    _ name: UnsafeMutablePointer<sockaddr>?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> CInt {
    let result = getpeername(SOCKET(descriptor), name, length)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}

@inline(__always)
internal func accept(
    _ descriptor: CInt,
    _ address: UnsafeMutablePointer<sockaddr>?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> CInt {
    let result = accept(SOCKET(descriptor), address, length)
    guard result != INVALID_SOCKET else {
        setErrnoFromLastSocketError()
        return -1
    }
    return CInt(result)
}

@inline(__always)
internal func bind(
    _ descriptor: CInt,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> CInt {
    let result = bind(SOCKET(descriptor), address, length)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}

@inline(__always)
internal func connect(
    _ descriptor: CInt,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> CInt {
    let result = connect(SOCKET(descriptor), address, length)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}

@inline(__always)
internal func listen(
    _ descriptor: CInt,
    _ backlog: CInt
) -> CInt {
    let result = listen(SOCKET(descriptor), backlog)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return result
    }
    return result
}

@inline(__always)
internal func recv(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int,
    _ flags: CInt
) -> Int {
    let result = recv(SOCKET(descriptor), buffer, numericCast(size), flags)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return Int(result)
    }
    return Int(result)
}

@inline(__always)
internal func recvfrom(
    _ descriptor: CInt,
    _ buffer: UnsafeMutableRawPointer?,
    _ size: Int,
    _ flags: CInt,
    _ address: UnsafeMutablePointer<sockaddr>?,
    _ length: UnsafeMutablePointer<socklen_t>?
) -> Int {
    let result = recvfrom(
        SOCKET(descriptor), buffer, numericCast(size), flags, address, length
    )
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return Int(result)
    }
    return Int(result)
}


@inline(__always)
internal func send(
    _ descriptor: CInt,
    _ buffer: UnsafeRawPointer?,
    _ size: Int,
    _ flags: CInt
) -> Int {
    let result = send(SOCKET(descriptor), buffer, numericCast(size), flags)
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return Int(result)
    }
    return Int(result)
}

@inline(__always)
internal func sendto(
    _ descriptor: CInt,
    _ buffer: UnsafeRawPointer?,
    _ size: Int,
    _ flags: CInt,
    _ address: UnsafePointer<sockaddr>?,
    _ length: socklen_t
) -> Int {
    let result = sendto(
        SOCKET(descriptor), buffer, numericCast(size), flags, address, length
    )
    guard result != SOCKET_ERROR else {
        setErrnoFromLastSocketError()
        return Int(result)
    }
    return Int(result)
}

@inline(__always)
private func setErrnoFromLastSocketError() {
    let error = WSAGetLastError()
    switch error {
    case WSAEINTR: system_errno = EINTR
    case WSAEACCES: system_errno = EACCES
    case WSAEFAULT: system_errno = EFAULT
    case WSAEINVAL: system_errno = EINVAL
    case WSAEMFILE: system_errno = EMFILE
    case WSAEWOULDBLOCK: system_errno = EWOULDBLOCK
    case WSAEINPROGRESS: system_errno = EINPROGRESS
    case WSAEALREADY: system_errno = EALREADY
    case WSAENOTSOCK: system_errno = ENOTSOCK
    case WSAEDESTADDRREQ: system_errno = EDESTADDRREQ
    case WSAEMSGSIZE: system_errno = EMSGSIZE
    case WSAEPROTOTYPE: system_errno = EPROTOTYPE
    case WSAENOPROTOOPT: system_errno = ENOPROTOOPT
    case WSAEPROTONOSUPPORT: system_errno = EPROTONOSUPPORT
    case WSAEOPNOTSUPP: system_errno = EOPNOTSUPP
    case WSAEAFNOSUPPORT: system_errno = EAFNOSUPPORT
    case WSAEADDRINUSE: system_errno = EADDRINUSE
    case WSAEADDRNOTAVAIL: system_errno = EADDRNOTAVAIL
    case WSAENETDOWN: system_errno = ENETDOWN
    case WSAENETUNREACH: system_errno = ENETUNREACH
    case WSAENETRESET: system_errno = ENETRESET
    case WSAECONNABORTED: system_errno = ECONNABORTED
    case WSAECONNRESET: system_errno = ECONNRESET
    case WSAENOBUFS: system_errno = ENOBUFS
    case WSAEISCONN: system_errno = EISCONN
    case WSAENOTCONN: system_errno = ENOTCONN
    case WSAETIMEDOUT: system_errno = ETIMEDOUT
    case WSAECONNREFUSED: system_errno = ECONNREFUSED
    case WSAEHOSTUNREACH: system_errno = EHOSTUNREACH
    default: system_errno = EIO
    }
}

#endif

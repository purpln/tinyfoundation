#if canImport(Darwin.C)
@_exported import Darwin.C

#elseif canImport(Android)
@_exported import Android

#elseif canImport(Glibc)
@_exported import Glibc

#elseif canImport(Musl)
@_exported import Musl

#elseif canImport(WinSDK)
@_exported import ucrt

#endif
@_exported import External

#if os(Linux)
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    struct OutputStream: TextOutputStream {
        mutating func write(_ string: String) {
            fputs(string, stdout)
        }
    }
    var stream = OutputStream()
    print(items, separator: separator, terminator: terminator, to: &stream)
}
#endif

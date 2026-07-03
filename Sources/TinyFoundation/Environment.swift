private import TinySystem

public func getenv(_ name: String) -> String? {
    name.withPlatformString({ name in
        system_getenv(name)
    }).map({ pointer in
        String(platformString: pointer)
    })
}
#if compiler(>=6.0)
public func setenv(
    _ name: String,
    _ value: String,
    _ overwrite: Bool = true
) throws(Errno) {
    try _setenv(name, value, overwrite).get()
}
#else
public func setenv(
    _ name: String,
    _ value: String,
    _ overwrite: Bool = true
) throws {
    try _setenv(name, value, overwrite).get()
}
#endif
@inline(__always)
private func _setenv(
    _ name: String,
    _ value: String,
    _ overwrite: Bool = true
) -> Result<Void, Errno> {
    nothingOrErrno(retryOnInterrupt: false, {
        name.withPlatformString({ name in
            value.withPlatformString({ value in
                system_setenv(name, value, overwrite ? 1 : 0)
            })
        })
    })
}

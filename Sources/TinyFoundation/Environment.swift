import TinySystem

public func getenv(_ name: String) -> String? {
    name.withPlatformString({ name in
        system_getenv(name)
    }).map({ pointer in
        String(platformString: pointer)
    })
}

public func setenv(_ name: String, _ value: String, _ overwrite: Bool = true) throws {
    try nothingOrErrno(retryOnInterrupt: false, {
        name.withPlatformString({ name in
            value.withPlatformString({ value in
                system_setenv(name, value, overwrite ? 1 : 0)
            })
        })
    }).get()
}

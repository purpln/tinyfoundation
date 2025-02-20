#if os(macOS) || os(iOS)
private func getSysCtlString(_ name: String) throws -> String {
    try withUnsafeTemporaryAllocation(byteCount: 256, alignment: 16) { buffer in
        
        var len = buffer.count
        
        try nothingOrErrno(retryOnInterrupt: false, {
            sysctlbyname(name, buffer.baseAddress, &len, nil, 0)
        }).get()
        
        return String(cString: buffer.baseAddress!.assumingMemoryBound(to: CChar.self))
    }
}

internal func readOSRelease() -> (platform: String, version: (major: Int, minor: Int, patch: Int, build: String?)) {
#if os(macOS)
    let platform = "macOS"
#elseif os(iOS)
    let platform = "iOS"
#elseif os(watchOS)
    let platform = "watchOS"
#elseif os(tvOS)
    let platform = "tvOS"
#elseif os(visionOS)
    let platform = "visionOS"
#endif
    
    let version = (try? getSysCtlString("kern.osproductversion"))?
        .split(separator: ".")
        .compactMap({ Int($0) }) ?? []
    let major = version.count >= 1 ? version[0] : -1
    let minor = version.count >= 2 ? version[1] : 0
    let patch = version.count >= 3 ? version[2] : 0
    
    let build = try? getSysCtlString("kern.osversion")
    
    return (platform, (major, minor, patch, build))
}
#endif

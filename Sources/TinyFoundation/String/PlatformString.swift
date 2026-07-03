public import TinySystem

extension String {
    @_disfavoredOverload
    public init(platformString: UnsafePointer<PlatformCharacter>) {
        self.init(_errorCorrectingPlatformString: platformString)
    }
    
    @inlinable
    @_alwaysEmitIntoClient
    public init(platformString: [PlatformCharacter]) {
        guard let _ = platformString.firstIndex(of: 0) else {
            fatalError(
                "input of String.init(platformString:) must be null-terminated"
            )
        }
        self = platformString.withUnsafeBufferPointer({
            String(platformString: $0.baseAddress!)
        })
    }
    
    @inlinable
    @_alwaysEmitIntoClient
    @available(*, deprecated, message: "Use String.init(_ scalar: Unicode.Scalar)")
    public init(platformString: inout PlatformCharacter) {
        guard platformString == 0 else {
            fatalError(
                "input of String.init(platformString:) must be null-terminated"
            )
        }
        self = ""
    }
    
    @inlinable
    @_alwaysEmitIntoClient
    @available(*, deprecated, message: "Use a copy of the String argument")
    public init(platformString: String) {
        if let nullLoc = platformString.firstIndex(of: "\0") {
            self = String(platformString[..<nullLoc])
        } else {
            self = platformString
        }
    }
    
    public init?(
        validatingPlatformString platformString: UnsafePointer<PlatformCharacter>
    ) {
        self.init(_platformString: platformString)
    }
    
    @inlinable
    @_alwaysEmitIntoClient
    public init?(
        validatingPlatformString platformString: [PlatformCharacter]
    ) {
        guard let _ = platformString.firstIndex(of: 0) else {
            fatalError(
                "input of String.init(validatingPlatformString:) must be null-terminated"
            )
        }
        guard let string = platformString.withUnsafeBufferPointer({
            String(validatingPlatformString: $0.baseAddress!)
        }) else {
            return nil
        }
        self = string
    }
    
    @inlinable
    @_alwaysEmitIntoClient
    @available(*, deprecated, message: "Use String(_ scalar: Unicode.Scalar)")
    public init?(
        validatingPlatformString platformString: inout PlatformCharacter
    ) {
        guard platformString == 0 else {
            fatalError(
                "input of String.init(validatingPlatformString:) must be null-terminated"
            )
        }
        self = ""
    }
    
    @inlinable
    @_alwaysEmitIntoClient
    @available(*, deprecated, message: "Use a copy of the String argument")
    public init?(
        validatingPlatformString platformString: String
    ) {
        if let nullLoc = platformString.firstIndex(of: "\0") {
            self = String(platformString[..<nullLoc])
        } else {
            self = platformString
        }
    }
    
    public func withPlatformString<T, E>(
        _ body: (UnsafePointer<PlatformCharacter>) throws(E) -> T
    ) throws(E) -> T {
        try _withPlatformString(body)
    }
}

extension PlatformCharacter {
    internal var platformCodeUnit: PlatformUnicodeEncoding.CodeUnit {
#if os(Windows)
        return self
#else
        return PlatformUnicodeEncoding.CodeUnit(bitPattern: self)
#endif
    }
}

extension PlatformUnicodeEncoding.CodeUnit {
    internal var platformChar: PlatformCharacter {
#if os(Windows)
        return self
#else
        return PlatformCharacter(bitPattern: self)
#endif
    }
}

internal protocol PlatformStringable {
    func _withPlatformString<T, E>(
        _ body: (UnsafePointer<PlatformCharacter>) throws(E) -> T
    ) throws(E) -> T
    
    init?(_platformString: UnsafePointer<PlatformCharacter>)
}
extension String: PlatformStringable {}

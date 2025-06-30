import TinySystem

// Interop between String and platfrom string
extension String {
    internal func _withPlatformString<Result>(
        _ body: (UnsafePointer<PlatformChar>) throws -> Result
    ) rethrows -> Result {
        // Need to #if because CChar may be signed
#if os(Windows)
        return try withCString(encodedAs: PlatformUnicodeEncoding.self, body)
#else
        return try withCString(body)
#endif
    }
    
    internal init?(_platformString platformString: UnsafePointer<PlatformChar>) {
        // Need to #if because CChar may be signed
#if os(Windows)
        guard let strRes = String.decodeCString(
            platformString,
            as: PlatformUnicodeEncoding.self,
            repairingInvalidCodeUnits: false
        ) else { return nil }
        assert(strRes.repairsMade == false)
        self = strRes.result
        return
        
#else
        self.init(validatingCString: platformString)
#endif
    }
    
    internal init(
        _errorCorrectingPlatformString platformString: UnsafePointer<PlatformChar>
    ) {
        // Need to #if because CChar may be signed
#if os(Windows)
        let strRes = String.decodeCString(
            platformString,
            as: PlatformUnicodeEncoding.self,
            repairingInvalidCodeUnits: true)
        self = strRes!.result
        return
#else
        self.init(cString: platformString)
#endif
    }
}

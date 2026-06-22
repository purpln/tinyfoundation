import TinySystem

// Interop between String and platfrom string
extension String {
    internal func _withPlatformString<T, E>(
        _ body: (UnsafePointer<PlatformCharacter>) throws(E) -> T
    ) throws(E) -> T {
        // Need to #if because CChar may be signed
#if os(Windows)
        return try withCString(encodedAs: PlatformUnicodeEncoding.self, { pointer -> Result<T, E> in
            do throws(E) {
                let result = try body(pointer)
                return .success(result)
            } catch {
                return .failure(error)
            }
        }).get()
#else
        return try withCString({ pointer -> Result<T, E> in
            do throws(E) {
                let result = try body(pointer)
                return .success(result)
            } catch {
                return .failure(error)
            }
        }).get()
#endif
    }
    
    internal init?(_platformString platformString: UnsafePointer<PlatformCharacter>) {
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
        
#elseif swift(>=6.0)
        self.init(validatingCString: platformString)
#else
        self.init(validatingUTF8: platformString)
#endif
    }
    
    internal init(
        _errorCorrectingPlatformString platformString: UnsafePointer<PlatformCharacter>
    ) {
        // Need to #if because CChar may be signed
#if os(Windows)
        let strRes = String.decodeCString(
            platformString,
            as: PlatformUnicodeEncoding.self,
            repairingInvalidCodeUnits: true
        )
        self = strRes!.result
        return
#else
        self.init(cString: platformString)
#endif
    }
}

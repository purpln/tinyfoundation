public extension UniqueID {
    @inlinable
    static func random() -> UniqueID {
        var rng = SystemRandomNumberGenerator()
        return random(using: &rng)
    }
    
    @inlinable
    static func random<RNG>(using rng: inout RNG) -> UniqueID where RNG: RandomNumberGenerator {
        var bytes = UniqueID.zero.bytes
        withUnsafeMutableBytes(of: &bytes) { dest in
            var random = rng.next()
            withUnsafePointer(to: &random) {
                dest.baseAddress!.copyMemory(from: UnsafeRawPointer($0), byteCount: 8)
            }
            random = rng.next()
            withUnsafePointer(to: &random) {
                dest.baseAddress!.advanced(by: 8).copyMemory(from: UnsafeRawPointer($0), byteCount: 8)
            }
        }
        // octet 6 = time_hi_and_version (high octet).
        // high 4 bits = version number.
        bytes.6 = (bytes.6 & 0xF) | 0x40
        // octet 8 = clock_seq_high_and_reserved.
        // high 2 bits = variant (10 = standard).
        bytes.8 = (bytes.8 & 0x3F) | 0x80
        return UniqueID(bytes: bytes)
    }
}

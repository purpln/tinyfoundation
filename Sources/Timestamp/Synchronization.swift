#if canImport(Synchronization)
import Synchronization
import LibC

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
extension Timestamp: AtomicRepresentable {
    public typealias AtomicRepresentation = WordPair.AtomicRepresentation
    
    public static func encodeAtomicRepresentation(_ value: consuming Timestamp) -> AtomicRepresentation {
        let wordPair = WordPair(
            first: UInt(bitPattern: Int(value.value.tv_sec)),
            second: UInt(bitPattern: Int(value.value.tv_sec))
        )
        
        return WordPair.encodeAtomicRepresentation(wordPair)
    }
    
    public static func decodeAtomicRepresentation(_ storage: consuming AtomicRepresentation) -> Timestamp {
        let wordPair = WordPair.decodeAtomicRepresentation(storage)
#if !os(Windows)
        return Timestamp(timespec: .init(
            tv_sec: time_t(Int(bitPattern: wordPair.first)),
            tv_nsec: Int(bitPattern: wordPair.second)
        ))
#else
        return Timestamp(timespec: .init(
            tv_sec: time_t(Int(bitPattern: wordPair.first)),
            tv_nsec: CInt(Int(bitPattern: wordPair.second))
        ))
#endif
    }
}
#endif

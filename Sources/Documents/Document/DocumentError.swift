public enum DocumentError: Error {
    case read
    case write
    case size
    case unableToAquireLock
}

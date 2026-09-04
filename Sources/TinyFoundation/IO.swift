public enum IO: Equatable, Hashable {
    case read
    case write
}

extension IO: Sendable {}

public protocol UniqueIDComponents {
    init?(_ uuid: UniqueID)
}

public extension UniqueID {
    typealias Components = UniqueIDComponents
    
    @inlinable
    func components<ViewType: Components>(_: @autoclosure () -> ViewType) -> ViewType? {
        ViewType(self)
    }
}

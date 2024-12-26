import LibC

public struct Flags: OptionSet {
    public let rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension Flags {
    static let noChildStop = Flags(rawValue: SA_NOCLDSTOP)
    static let noChildWait = Flags(rawValue: SA_NOCLDWAIT)
    static let onStack = Flags(rawValue: SA_ONSTACK)
    static let noDefer = Flags(rawValue: SA_NODEFER)
    static let resetHandler = Flags(rawValue: CInt(SA_RESETHAND))
    static let restart = Flags(rawValue: SA_RESTART)
    static let siginfo = Flags(rawValue: SA_SIGINFO)
}

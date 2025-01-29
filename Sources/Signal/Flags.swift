import LibC

public struct Flags: OptionSet {
    public let rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension Flags {
    static var noChildStop: Flags { Flags(rawValue: SA_NOCLDSTOP) }
    static var noChildWait: Flags { Flags(rawValue: SA_NOCLDWAIT) }
    static var onStack: Flags { Flags(rawValue: SA_ONSTACK) }
    static var noDefer: Flags { Flags(rawValue: SA_NODEFER) }
    static var resetHandler: Flags { Flags(rawValue: CInt(SA_RESETHAND)) }
    static var restart: Flags { Flags(rawValue: SA_RESTART) }
    static var siginfo: Flags { Flags(rawValue: SA_SIGINFO) }
}

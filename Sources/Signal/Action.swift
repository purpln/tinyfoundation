import LibC

public struct Action: RawRepresentable, Equatable {
    public var mask: Set<Signal> = []
    public var flags: Flags = []
    
    var handler: Handler
    
    public init(handler: Handler) {
        self.mask = []
        switch handler {
        case .posix:
            self.flags = [.siginfo]
        case .ignore, .default, .ansiC:
            self.flags = []
        }
        self.handler = handler
    }
    
    public init(signal: Signal) throws(Errno) {
        var action = sigaction()
        try nothingOrErrno(retryOnInterrupt: false, {
            sigaction(signal.rawValue, nil, &action)
        }).get()
        self.init(rawValue: action)
    }
    
    public init(rawValue: sigaction) {
        self.mask = Signal.set(from: rawValue.sa_mask)
        self.flags = Flags(rawValue: rawValue.sa_flags)
#if canImport(Darwin.C)
        switch OpaquePointer(bitPattern: unsafeBitCast(rawValue.__sigaction_u.__sa_handler, to: Int.self)) {
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_DFL, to: Int.self)): self.handler = .default
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_IGN, to: Int.self)): self.handler = .ignore
        default:
            if flags.contains(.siginfo) {
                self.handler = .posix(rawValue.__sigaction_u.__sa_sigaction)
            } else {
                self.handler = .ansiC(rawValue.__sigaction_u.__sa_handler)
            }
        }
#elseif canImport(Glibc)
        switch OpaquePointer(bitPattern: unsafeBitCast(rawValue.__sigaction_handler.sa_handler, to: Int.self)) {
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_DFL, to: Int.self)): self.handler = .default
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_IGN, to: Int.self)): self.handler = .ignore
        default:
            if flags.contains(.siginfo) {
                self.handler = .posix(rawValue.__sigaction_handler.sa_sigaction)
            } else {
                self.handler = .ansiC(rawValue.__sigaction_handler.sa_handler)
            }
        }
#elseif canImport(Musl)
        switch OpaquePointer(bitPattern: unsafeBitCast(rawValue.__sa_handler.sa_handler, to: Int.self)) {
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_DFL, to: Int.self)): self.handler = .default
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_IGN, to: Int.self)): self.handler = .ignore
        default:
            if flags.contains(.siginfo) {
                self.handler = .posix(rawValue.__sa_handler.sa_sigaction)
            } else {
                self.handler = .ansiC(rawValue.__sa_handler.sa_handler)
            }
        }
#elseif canImport(Android) && _pointerBitWidth(_32)
        switch OpaquePointer(bitPattern: unsafeBitCast(rawValue.__Anonymous_field0.sa_handler, to: Int.self)) {
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_DFL, to: Int.self)): self.handler = .default
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_IGN, to: Int.self)): self.handler = .ignore
        default:
            if flags.contains(.siginfo) {
                self.handler = .posix(rawValue.__Anonymous_field0.sa_sigaction)
            } else {
                self.handler = .ansiC(rawValue.__Anonymous_field0.sa_handler)
            }
        }
#elseif canImport(Android)
        switch OpaquePointer(bitPattern: unsafeBitCast(rawValue.__Anonymous_field1.sa_handler, to: Int.self)) {
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_DFL, to: Int.self)): self.handler = .default
        case OpaquePointer(bitPattern: unsafeBitCast(SIG_IGN, to: Int.self)): self.handler = .ignore
        default:
            if flags.contains(.siginfo) {
                self.handler = .posix(rawValue.__Anonymous_field1.sa_sigaction)
            } else {
                self.handler = .ansiC(rawValue.__Anonymous_field1.sa_handler)
            }
        }
#endif
        if !isValid {
            print("Initialized an invalid Action.")
        }
    }
    
    public var rawValue: sigaction {
        if !isValid {
            print("Getting sigaction from an invalid Action.")
        }
        
        var ret = sigaction()
        ret.sa_mask = Signal.sigset(from: mask)
        ret.sa_flags = flags.rawValue
#if canImport(Darwin.C)
        switch handler {
        case .default: ret.__sigaction_u.__sa_handler = SIG_DFL
        case .ignore:  ret.__sigaction_u.__sa_handler = SIG_IGN
        case .ansiC(let handler): ret.__sigaction_u.__sa_handler = handler
        case .posix(let handler): ret.__sigaction_u.__sa_sigaction = handler
        }
#elseif canImport(Glibc)
        switch handler {
        case .default: ret.__sigaction_handler.sa_handler = SIG_DFL
        case .ignore: ret.__sigaction_handler.sa_handler = SIG_IGN
        case .ansiC(let handler): ret.__sigaction_handler.sa_handler = handler
        case .posix(let handler): ret.__sigaction_handler.sa_sigaction = handler
        }
#elseif canImport(Musl)
        switch handler {
        case .default: ret.__sa_handler.sa_handler = SIG_DFL
        case .ignore: ret.__sa_handler.sa_handler = SIG_IGN
        case .ansiC(let handler): ret.__sa_handler.sa_handler = handler
        case .posix(let handler): ret.__sa_handler.sa_sigaction = handler
        }
#elseif canImport(Android) && _pointerBitWidth(_32)
        switch handler {
        case .default: ret.__Anonymous_field0.sa_handler = SIG_DFL
        case .ignore: ret.__Anonymous_field0.sa_handler = SIG_IGN
        case .ansiC(let handler): ret.__Anonymous_field0.sa_handler = handler
        case .posix(let handler): ret.__Anonymous_field0.sa_sigaction = handler
        }
#elseif canImport(Android)
        switch handler {
        case .default: ret.__Anonymous_field1.sa_handler = SIG_DFL
        case .ignore: ret.__Anonymous_field1.sa_handler = SIG_IGN
        case .ansiC(let handler): ret.__Anonymous_field1.sa_handler = handler
        case .posix(let handler): ret.__Anonymous_field1.sa_sigaction = handler
        }
#endif
        return ret
    }
    
    public var isValid: Bool {
        !flags.contains(.siginfo) || (handler != .ignore && handler != .default)
    }
    
    @discardableResult
    public func install(on signal: Signal, revertIfIgnored: Bool = true) throws(Errno) -> Action? {
        var old = sigaction()
        var new = rawValue
        try nothingOrErrno(retryOnInterrupt: false, {
            sigaction(signal.rawValue, &new, &old)
        }).get()
        
        let oldSigaction = Action(rawValue: old)
        if revertIfIgnored && oldSigaction == .ignore {
            try nothingOrErrno(retryOnInterrupt: false, {
                sigaction(signal.rawValue, &old, nil)
            }).get()
            return nil
        }
        return (oldSigaction != self ? oldSigaction : nil)
    }
}

public extension Action {
    func install(on signals: Set<Signal>, revertIfIgnored: Bool = true) throws(Errno) {
        for signal in signals {
            try install(on: signal)
        }
    }
}

public extension Action {
    static var `default`: Action { Action(handler: .default) }
    static var ignore: Action { Action(handler: .ignore) }
}

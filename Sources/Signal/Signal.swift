import LibC

public struct Signal: RawRepresentable, Hashable, Codable, CustomStringConvertible {
    public var rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
}

public extension Signal {
    static let hangup = Signal(rawValue: SIGHUP)
    static let interrupt = Signal(rawValue: SIGINT)
    static let quit = Signal(rawValue: SIGQUIT)
    static let illegal = Signal(rawValue: SIGILL)
    static let trap = Signal(rawValue: SIGTRAP)
    static let abort = Signal(rawValue: SIGABRT)
    
    static let arithmetic = Signal(rawValue: SIGFPE)
    static let segmentation = Signal(rawValue: SIGSEGV)
    static let killed = Signal(rawValue: SIGKILL)
    static let bus = Signal(rawValue: SIGBUS)
    static let iot = Signal(rawValue: SIGIOT)
    static let sys = Signal(rawValue: SIGSYS)
    static let pipe = Signal(rawValue: SIGPIPE)
    static let alarm = Signal(rawValue: SIGALRM)
    static let terminated = Signal(rawValue: SIGTERM)
    static let urgent = Signal(rawValue: SIGURG)
    static let stop = Signal(rawValue: SIGSTOP)
    static let `continue` = Signal(rawValue: SIGCONT)
    static let child = Signal(rawValue: SIGCHLD)
    
    static let window = Signal(rawValue: SIGWINCH)
#if canImport(Darwin.C)
    static let info = Signal(rawValue: SIGINFO)
#elseif canImport(Glibc) || canImport(Musl) || canImport(Android)
    static let poll = Signal(rawValue: SIGPOLL)
#endif
    static let io = Signal(rawValue: SIGIO)
    
    static let usr1 = Signal(rawValue: SIGUSR1)
    static let usr2 = Signal(rawValue: SIGUSR2)
}

extension Signal {
    public var description: String {
        "\(name ?? "\(rawValue)") - \(about ?? "unknown")"
    }
}

public extension Signal {
#if canImport(Darwin.C)
    var name: String? {
        guard rawValue >= 0 && rawValue < NSIG else { return nil }
        
        return withUnsafePointer(to: sys_signame) { pointer in
            pointer.withMemoryRebound(to: UnsafePointer<UInt8>?.self, capacity: Int(NSIG)) { pointer in
                pointer.advanced(by: Int(rawValue)).pointee.flatMap { String(cString: $0) }
            }
        }
    }
    
    var about: String? {
        guard rawValue >= 0 && rawValue < NSIG else { return nil }
        
        return withUnsafePointer(to: sys_siglist) { pointer in
            pointer.withMemoryRebound(to: UnsafePointer<UInt8>?.self, capacity: Int(NSIG)) { pointer in
                pointer.advanced(by: Int(rawValue)).pointee.flatMap { String(cString: $0) }
            }
        }
    }
#elseif canImport(Glibc) || canImport(Musl)
    var name: String? {
        return nil
    }
    
    var about: String? {
        guard let cstr = strsignal(rawValue) else { return nil }
        return String(cString: cstr)
    }
#elseif canImport(Android)
    var name: String? {
        return nil
    }
    
    var about: String? {
        let cstr = strsignal(rawValue)
        return String(cString: cstr)
    }
#endif
}


extension Signal: CaseIterable {
    public static var allCases: [Signal] {
        (1..<NSIG).map { Signal(rawValue: $0) }
    }
}

public extension Signal {
    static func set(from sigset: sigset_t) -> Set<Signal> {
        var sigset = sigset
        return Set((1..<NSIG).filter { sigismember(&sigset, $0) != 0 }.map { Signal(rawValue: $0) })
    }
    
    static func sigset(from setOfSignals: Set<Signal>) -> sigset_t {
        var sigset = sigset_t()
        sigemptyset(&sigset)
        for s in setOfSignals {
            sigaddset(&sigset, s.rawValue)
        }
        return sigset
    }
    
    var sigset: sigset_t {
        var sigset = sigset_t()
        sigemptyset(&sigset)
        sigaddset(&sigset, rawValue)
        return sigset
    }
}

public extension Signal {
    static let killing: Set<Signal> = {
        [.terminated, .interrupt, .quit]
    }()
}

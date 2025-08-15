#if !os(Windows)
import LibC

public extension sigaction {
#if canImport(Darwin.C)
    typealias Union = __sigaction_u
#elseif canImport(Glibc)
    typealias Union = __Unnamed_union___sigaction_handler
#elseif canImport(Musl)
    typealias Union = __Unnamed_union___sa_handler
#elseif canImport(Android) && _pointerBitWidth(_32)
    typealias Union = __Unnamed_union___Anonymous_field0
#elseif canImport(Android)
    typealias Union = __Unnamed_union___Anonymous_field1
#endif
    
    init(_ handler: Union, sa_mask: sigset_t, sa_flags: CInt, sa_restorer: @convention(c) () -> Void) {
#if canImport(Darwin.C)
        self.init(__sigaction_u: handler, sa_mask: sa_mask, sa_flags: sa_flags)
#elseif canImport(Glibc)
        self.init(__sigaction_handler: handler, sa_mask: sa_mask, sa_flags: sa_flags, sa_restorer: sa_restorer)
#elseif canImport(Musl)
        self.init(__sa_handler: handler, sa_mask: sa_mask, sa_flags: sa_flags, sa_restorer: sa_restorer)
#elseif canImport(Android) && _pointerBitWidth(_32)
        self.init(handler, sa_mask: sa_mask, sa_flags: sa_flags, sa_restorer: sa_restorer)
#elseif canImport(Android)
        self.init(sa_flags: sa_flags, handler, sa_mask: sa_mask, sa_restorer: sa_restorer)
#endif
    }
    
    var handler: Union {
        get {
#if canImport(Darwin.C)
            __sigaction_u
#elseif canImport(Glibc)
            __sigaction_handler
#elseif canImport(Musl)
            __sa_handler
#elseif canImport(Android) && _pointerBitWidth(_32)
            __Anonymous_field0
#elseif canImport(Android)
            __Anonymous_field1
#endif
        }
        set {
#if canImport(Darwin.C)
            __sigaction_u = newValue
#elseif canImport(Glibc)
            __sigaction_handler = newValue
#elseif canImport(Musl)
            __sa_handler = newValue
#elseif canImport(Android) && _pointerBitWidth(_32)
            __Anonymous_field0 = newValue
#elseif canImport(Android)
            __Anonymous_field1 = newValue
#endif
        }
    }
}

public extension sigaction.Union {
    typealias Handler = @convention(c) (CInt) -> Void
    typealias Action = @convention(c) (CInt, UnsafeMutablePointer<siginfo_t>?, UnsafeMutableRawPointer?) -> Void
    
    init(handler: Handler) {
#if canImport(Darwin.C)
        self.init(__sa_handler: handler)
#elseif canImport(Glibc)
        self.init(sa_handler: handler)
#elseif canImport(Musl)
        self.init(sa_handler: handler)
#elseif canImport(Android)
        self.init(sa_handler: handler)
#endif
    }
    
    var handler: Handler? {
        get {
#if canImport(Darwin.C)
            __sa_handler
#elseif canImport(Glibc)
            sa_handler
#elseif canImport(Musl)
            sa_handler
#elseif canImport(Android)
            sa_handler
#endif
        }
        set {
#if canImport(Darwin.C)
            __sa_handler = newValue
#elseif canImport(Glibc)
            sa_handler = newValue
#elseif canImport(Musl)
            sa_handler = newValue
#elseif canImport(Android)
            sa_handler = newValue
#endif
        }
    }
    
    init(sigaction: Action) {
#if canImport(Darwin.C)
        self.init(__sa_sigaction: sigaction)
#elseif canImport(Glibc)
        self.init(sa_sigaction: sigaction)
#elseif canImport(Musl)
        self.init(sa_sigaction: sigaction)
#elseif canImport(Android)
        self.init(sa_sigaction: sigaction)
#endif
    }
    
    var sigaction: Action? {
        get {
#if canImport(Darwin.C)
            __sa_sigaction
#elseif canImport(Glibc)
            sa_sigaction
#elseif canImport(Musl)
            sa_sigaction
#elseif canImport(Android)
            sa_sigaction
#endif
        }
        set {
#if canImport(Darwin.C)
            __sa_sigaction = newValue
#elseif canImport(Glibc)
            sa_sigaction = newValue
#elseif canImport(Musl)
            sa_sigaction = newValue
#elseif canImport(Android)
            sa_sigaction = newValue
#endif
        }
    }
}
#endif

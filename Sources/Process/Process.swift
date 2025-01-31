import LibC

public struct Process {
    public let pid: pid_t
}

public extension Process {
    struct Status: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: CInt
        
        public init(rawValue: CInt) {
            self.rawValue = rawValue
        }
    }
}

public extension Process.Status {
    static var success: Self { .init(rawValue: EXIT_SUCCESS) }
    static var failure: Self { .init(rawValue: EXIT_FAILURE) }
}

private func WIFEXITED(_ status: CInt) -> Bool {
    WSTATUS(status) == 0
}

private func WSTATUS(_ status: CInt) -> CInt {
    status & 0x7f
}

private func WIFSIGNALED(_ status: CInt) -> Bool {
    (WSTATUS(status) != 0) && (WSTATUS(status) != 0x7f)
}

private func WEXITSTATUS(_ status: CInt) -> CInt {
    (status >> 8) & 0xff
}

private func WTERMSIG(_ status: CInt) -> CInt {
    status & 0x7f
}

public extension Process.Status {
    var exit: Int {
        Int(WEXITSTATUS(rawValue))
    }
    
    var exited: Bool {
        WIFEXITED(rawValue)
    }
    
    var signaled: Bool {
        WIFSIGNALED(rawValue)
    }
    
    var signal: CInt {
        WTERMSIG(rawValue)
    }
}

public extension Process {
    func wait() throws -> Status {
        var value: CInt = 0
        try nothingOrErrno(retryOnInterrupt: true, {
            waitpid(pid, &value, 0)
        }).get()
        return Status(rawValue: value)
    }
    
    func stop() {
        guard kill(pid, 0) == 0 else { return }
        kill(pid, SIGKILL)
        
        var status: CInt = 0
        waitpid(pid, &status, WUNTRACED)
    }
}

public extension Process {
    enum Action {
        case open(FileDescriptor, String, CInt, mode_t)
        case close(FileDescriptor)
        case connect(FileDescriptor, FileDescriptor)
    }
}

public struct ProcessError: Error, CustomStringConvertible {
    public let code: Int
    public let value: String
    
    public init(code: Int, description: String) {
        self.code = code
        self.value = description
    }
    
    public var description: String {
        value.isEmpty ? "process error \(code) empty" : "process error \(code): \(value)"
    }
}

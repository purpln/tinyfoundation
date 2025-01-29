private func valueOrErrno<I: FixedWidthInteger>(
    _ i: I
) -> Result<I, Errno> {
    i == -1 ? .failure(Errno.current) : .success(i)
}

private func nothingOrErrno<I: FixedWidthInteger>(
    _ i: I
) -> Result<(), Errno> {
    valueOrErrno(i).map { _ in () }
}

public func valueOrErrno<I: FixedWidthInteger>(
    retryOnInterrupt: Bool, _ f: () -> I
) -> Result<I, Errno> {
    repeat {
        switch valueOrErrno(f()) {
        case .success(let r): return .success(r)
        case .failure(let error):
            guard retryOnInterrupt && error == .interrupted else { return .failure(error) }
            break
        }
    } while true
}

public func nothingOrErrno<I: FixedWidthInteger>(
    retryOnInterrupt: Bool, _ f: () -> I
) -> Result<(), Errno> {
    valueOrErrno(retryOnInterrupt: retryOnInterrupt, f).map { _ in () }
}

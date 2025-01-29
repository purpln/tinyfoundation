import LibC

public func pow(_ lhs: Double, _ rhs: Double) -> Double {
    LibC.pow(lhs, rhs)
}

public func sqrt(_ x: Double) -> Double {
    LibC.sqrt(x)
}

public func log(_ x: Double) -> Double {
    LibC.log(x)
}

public func cos(_ x: Double) -> Double {
    LibC.cos(x)
}

public func acos(_ x: Double) -> Double {
    LibC.acos(x)
}

public func sin(_ x: Double) -> Double {
    LibC.sin(x)
}

public func tan(_ x: Double) -> Double {
    LibC.tan(x)
}

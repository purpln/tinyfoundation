public struct Vector2<Scalar: BinaryFloatingPoint & Sendable>: Vectorable, Hashable, Sendable {
    public var x: Scalar
    public var y: Scalar

    public static var zero: Vector2 {
        Vector2(0.0, 0.0)
    }

    public static var components: Int { 2 }
    
    public subscript(index: Int) -> Scalar {
        get {
            switch index {
            case 0: return self.x
            case 1: return self.y
            default:
                assertionFailure("Index out of range")
                break
            }
            return .zero
        }
        set (value) {
            switch index {
            case 0: self.x = value
            case 1: self.y = value
            default:
                assertionFailure("Index out of range")
                break
            }
        }
    }

    public init(_ vector: Self = .zero) {
        self = vector
    }
    
    public init<T: BinaryFloatingPoint>(_ x: T, _ y: T) {
        self.x = Scalar(x)
        self.y = Scalar(y)
    }

    public init<T: BinaryFloatingPoint>(x: T, y: T) {
        self.init(x, y)
    }

    public static func dot(_ v1: Vector2, _ v2: Vector2) -> Scalar {
        v1.x * v2.x + v1.y * v2.y
    }

    public static func cross(_ v1: Vector2, _ v2: Vector2) -> Scalar {
        v1.x * v2.y - v1.y * v2.x
    }

    public func rotated(by angle: some BinaryFloatingPoint) -> Self {
        // Rotate
        // | cos  sin|
        // |-sin  cos|
        let a = Double(angle)
        let cosR = Scalar(cos(a))
        let sinR = Scalar(sin(a))
        return Self(x * cosR - y * sinR, x * sinR + y * cosR)
    }

    public mutating func rotate(by angle: some BinaryFloatingPoint) {
        self = self.rotated(by: angle)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    public static prefix func - (lhs: Self) -> Self {
        Self(-lhs.x, -lhs.y)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    public static func * (lhs: Self, rhs: some BinaryFloatingPoint) -> Self {
        Self(lhs.x * Scalar(rhs), lhs.y * Scalar(rhs))
    }

    public static func * (lhs: some BinaryFloatingPoint, rhs: Self) -> Self {
        Self(Scalar(lhs) * rhs.x, Scalar(lhs) * rhs.y)
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        Self(lhs.x * rhs.x, lhs.y * rhs.y)
    }

    public static func / (lhs: Self, rhs: Self) -> Self {
        Self(lhs.x / rhs.x, lhs.y / rhs.y)
    }

    public static func / (lhs: some BinaryFloatingPoint, rhs: Self) -> Self {
        Self(Scalar(lhs) / rhs.x, Scalar(lhs) / rhs.y)
    }

    public static func minimum(_ lhs: Self, _ rhs: Self) -> Self {
        Self(min(lhs.x, rhs.x), min(lhs.y, rhs.y))
    }

    public static func maximum(_ lhs: Self, _ rhs: Self) -> Self {
        Self(max(lhs.x, rhs.x), max(lhs.y, rhs.y))
    }
}

public extension Vector2 {
    @available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
    var half2: Half2 {
        get { (Float16(self.x), Float16(self.y)) }
        set(v) {
            self.x = Scalar(v.0)
            self.y = Scalar(v.1)
        }
    }

    var float2: Float2 {
        get { (Float32(self.x), Float32(self.y)) }
        set(v) {
            self.x = Scalar(v.0)
            self.y = Scalar(v.1)
        }
    }

    var double2: Double2 {
        get { (Float64(self.x), Float64(self.y)) }
        set(v) {
            self.x = Scalar(v.0)
            self.y = Scalar(v.1)
        }
    }

    @available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
    init(_ v: Half2) {
        self.x = Scalar(v.0)
        self.y = Scalar(v.1)
    }

    init(_ v: Float2) {
        self.x = Scalar(v.0)
        self.y = Scalar(v.1)
    }
    
    init(_ v: Double2) {
        self.x = Scalar(v.0)
        self.y = Scalar(v.1)
    }
}

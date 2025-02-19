public struct Matrix4<Scalar: BinaryFloatingPoint & Sendable>: Matrixable, Hashable, Sendable {
    public typealias Vector = Vector4<Scalar>
    
    public var m11, m12, m13, m14: Scalar
    public var m21, m22, m23, m24: Scalar
    public var m31, m32, m33, m34: Scalar
    public var m41, m42, m43, m44: Scalar
    
    public var row1: Vector {
        get { Vector4(x: m11, y: m12, z: m13, w: m14) }
        set {
            m11 = newValue.x
            m12 = newValue.y
            m13 = newValue.z
            m14 = newValue.w
        }
    }
    
    public var row2: Vector {
        get { Vector4(x: m21, y: m22, z: m23, w: m24) }
        set {
            m21 = newValue.x
            m22 = newValue.y
            m23 = newValue.z
            m24 = newValue.w
        }
    }
    
    public var row3: Vector {
        get { Vector4(x: m31, y: m32, z: m33, w: m34) }
        set {
            m31 = newValue.x
            m32 = newValue.y
            m33 = newValue.z
            m34 = newValue.w
        }
    }
    
    public var row4: Vector {
        get { Vector4(x: m41, y: m42, z: m43, w: m44) }
        set {
            m41 = newValue.x
            m42 = newValue.y
            m43 = newValue.z
            m44 = newValue.w
        }
    }
    
    public var column1: Vector {
        get { Vector4(x: m11, y: m21, z: m31, w: m41) }
        set (vector) {
            m11 = vector.x
            m21 = vector.y
            m31 = vector.z
            m41 = vector.w
        }
    }
    
    public var column2: Vector {
        get { Vector4(x: m12, y: m22, z: m32, w: m42) }
        set {
            m12 = newValue.x
            m22 = newValue.y
            m32 = newValue.z
            m42 = newValue.w
        }
    }
    
    public var column3: Vector {
        get { Vector4(x: m13, y: m23, z: m33, w: m43) }
        set {
            m13 = newValue.x
            m23 = newValue.y
            m33 = newValue.z
            m43 = newValue.w
        }
    }
    
    public var column4: Vector {
        get { Vector4(x: m14, y: m24, z: m34, w: m44) }
        set {
            m14 = newValue.x
            m24 = newValue.y
            m34 = newValue.z
            m44 = newValue.w
        }
    }
    
    public static var numRows: Int { 4 }
    
    public subscript(row: Int) -> Vector {
        get {
            switch row {
            case 0: return self.row1
            case 1: return self.row2
            case 2: return self.row3
            case 3: return self.row4
            default:
                assertionFailure("Index out of range")
                break
            }
            return .zero
        }
        set {
            switch row {
            case 0: self.row1 = newValue
            case 1: self.row2 = newValue
            case 2: self.row3 = newValue
            case 3: self.row4 = newValue
            default:
                assertionFailure("Index out of range")
                break
            }
        }
    }
    
    public subscript(row: Int, column: Int) -> Scalar {
        get {
            switch (row, column) {
            case (0, 0): return m11
            case (0, 1): return m12
            case (0, 2): return m13
            case (0, 3): return m14
            case (1, 0): return m21
            case (1, 1): return m22
            case (1, 2): return m23
            case (1, 3): return m24
            case (2, 0): return m31
            case (2, 1): return m32
            case (2, 2): return m33
            case (2, 3): return m34
            case (3, 0): return m41
            case (3, 1): return m42
            case (3, 2): return m43
            case (3, 3): return m44
            default:
                assertionFailure("Index out of range")
                break
            }
            return 0.0
        }
        set {
            switch (row, column) {
            case (0, 0): m11 = newValue
            case (0, 1): m12 = newValue
            case (0, 2): m13 = newValue
            case (0, 3): m14 = newValue
            case (1, 0): m21 = newValue
            case (1, 1): m22 = newValue
            case (1, 2): m23 = newValue
            case (1, 3): m24 = newValue
            case (2, 0): m31 = newValue
            case (2, 1): m32 = newValue
            case (2, 2): m33 = newValue
            case (2, 3): m34 = newValue
            case (3, 0): m41 = newValue
            case (3, 1): m42 = newValue
            case (3, 2): m43 = newValue
            case (3, 3): m44 = newValue
            default:
                assertionFailure("Index out of range")
                break
            }
        }
    }
    
    public static var identity: Matrix4 {
        Matrix4(1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0)
    }
    
    public init(_ matrix: Self = .identity) {
        self = matrix
    }
    
    public init<T: BinaryFloatingPoint>(
        _ m11: T, _ m12: T, _ m13: T, _ m14: T,
        _ m21: T, _ m22: T, _ m23: T, _ m24: T,
        _ m31: T, _ m32: T, _ m33: T, _ m34: T,
        _ m41: T, _ m42: T, _ m43: T, _ m44: T) {
            self.m11 = Scalar(m11)
            self.m12 = Scalar(m12)
            self.m13 = Scalar(m13)
            self.m14 = Scalar(m14)
            self.m21 = Scalar(m21)
            self.m22 = Scalar(m22)
            self.m23 = Scalar(m23)
            self.m24 = Scalar(m24)
            self.m31 = Scalar(m31)
            self.m32 = Scalar(m32)
            self.m33 = Scalar(m33)
            self.m34 = Scalar(m34)
            self.m41 = Scalar(m41)
            self.m42 = Scalar(m42)
            self.m43 = Scalar(m43)
            self.m44 = Scalar(m44)
        }
    
    public init<T: BinaryFloatingPoint>(m11: T, m12: T, m13: T, m14: T,
                                        m21: T, m22: T, m23: T, m24: T,
                                        m31: T, m32: T, m33: T, m34: T,
                                        m41: T, m42: T, m43: T, m44: T) {
        self.init(m11, m12, m13, m14,
                  m21, m22, m23, m24,
                  m31, m32, m33, m34,
                  m41, m42, m43, m44)
    }
    
    public init(row1: Vector, row2: Vector, row3: Vector, row4: Vector) {
        self.init(row1.x, row1.y, row1.z, row1.w,
                  row2.x, row2.y, row2.z, row2.w,
                  row3.x, row3.y, row3.z, row3.w,
                  row4.x, row4.y, row4.z, row4.w)
    }
    
    public init(column1: Vector, column2: Vector, column3: Vector, column4: Vector) {
        self.init(column1.x, column2.x, column3.x, column4.x,
                  column1.y, column2.y, column3.y, column4.y,
                  column1.z, column2.z, column3.z, column4.z,
                  column1.w, column2.w, column3.w, column4.w)
    }
    
    public var determinant: Scalar {
        let a = m14 * m23 * m32 * m41
        let b = m13 * m24 * m32 * m41
        let c = m14 * m22 * m33 * m41
        let d = m12 * m24 * m33 * m41
        let e = m13 * m22 * m34 * m41
        let f = m12 * m23 * m34 * m41
        let g = m14 * m23 * m31 * m42
        let h = m13 * m24 * m31 * m42
        let i = m14 * m21 * m33 * m42
        let j = m11 * m24 * m33 * m42
        let k = m13 * m21 * m34 * m42
        let l = m11 * m23 * m34 * m42
        let m = m14 * m22 * m31 * m43
        let n = m12 * m24 * m31 * m43
        let o = m14 * m21 * m32 * m43
        let p = m11 * m24 * m32 * m43
        let q = m12 * m21 * m34 * m43
        let r = m11 * m22 * m34 * m43
        let s = m13 * m22 * m31 * m44
        let t = m12 * m23 * m31 * m44
        let u = m13 * m21 * m32 * m44
        let v = m11 * m23 * m32 * m44
        let w = m12 * m21 * m33 * m44
        let x = m11 * m22 * m33 * m44
        
        let ab = a - b
        let abc = ab - c
        let abcd = abc + d
        let abcde = abcd + e
        let abcdef = abcde - f
        let abcdefg = abcdef - g
        let abcdefgh = abcdefg + h
        let abcdefghi = abcdefgh + i
        let abcdefghij = abcdefghi - j
        let abcdefghijk = abcdefghij - k
        let abcdefghijkl = abcdefghijk + l
        let abcdefghijklm = abcdefghijkl + m
        let abcdefghijklmn = abcdefghijklm - n
        let abcdefghijklmno = abcdefghijklmn - o
        let abcdefghijklmnop = abcdefghijklmno + p
        let abcdefghijklmnopq = abcdefghijklmnop + q
        let abcdefghijklmnopqr = abcdefghijklmnopq - r
        let abcdefghijklmnopqrs = abcdefghijklmnopqr - s
        let abcdefghijklmnopqrst = abcdefghijklmnopqrs + t
        let abcdefghijklmnopqrstu = abcdefghijklmnopqrst + u
        let abcdefghijklmnopqrstuv = abcdefghijklmnopqrstu - v
        let abcdefghijklmnopqrstuvw = abcdefghijklmnopqrstuv - w
        let abcdefghijklmnopqrstuvwx = abcdefghijklmnopqrstuvw + x
        return abcdefghijklmnopqrstuvwx
    }
    
    public var isDiagonal: Bool {
        m12 == 0.0 && m13 == 0.0 && m14 == 0.0 &&
        m21 == 0.0 && m23 == 0.0 && m24 == 0.0 &&
        m31 == 0.0 && m32 == 0.0 && m34 == 0.0 &&
        m41 == 0.0 && m42 == 0.0 && m43 == 0.0
    }
    
    public func inverted() -> Self? {
        let d = self.determinant
        if d.isZero { return nil }
        let inv = 1.0 / d
        
        let m11a = self.m23 * self.m34 * self.m42
        let m11b = self.m24 * self.m33 * self.m42
        let m11c = self.m24 * self.m32 * self.m43
        let m11d = self.m22 * self.m34 * self.m43
        let m11e = self.m23 * self.m32 * self.m44
        let m11f = self.m22 * self.m33 * self.m44
        let m11 = (m11a - m11b + m11c - m11d - m11e + m11f) * inv
        let m12a = self.m14 * self.m33 * self.m42
        let m12b = self.m13 * self.m34 * self.m42
        let m12c = self.m14 * self.m32 * self.m43
        let m12d = self.m12 * self.m34 * self.m43
        let m12e = self.m13 * self.m32 * self.m44
        let m12f = self.m12 * self.m33 * self.m44
        let m12 = (m12a - m12b - m12c + m12d + m12e - m12f) * inv
        let m13a = self.m13 * self.m24 * self.m42
        let m13b = self.m14 * self.m23 * self.m42
        let m13c = self.m14 * self.m22 * self.m43
        let m13d = self.m12 * self.m24 * self.m43
        let m13e = self.m13 * self.m22 * self.m44
        let m13f = self.m12 * self.m23 * self.m44
        let m13 = (m13a - m13b + m13c - m13d - m13e + m13f) * inv
        let m14a = self.m14 * self.m23 * self.m32
        let m14b = self.m13 * self.m24 * self.m32
        let m14c = self.m14 * self.m22 * self.m33
        let m14d = self.m12 * self.m24 * self.m33
        let m14e = self.m13 * self.m22 * self.m34
        let m14f = self.m12 * self.m23 * self.m34
        let m14 = (m14a - m14b - m14c + m14d + m14e - m14f) * inv
        let m21a = self.m24 * self.m33 * self.m41
        let m21b = self.m23 * self.m34 * self.m41
        let m21c = self.m24 * self.m31 * self.m43
        let m21d = self.m21 * self.m34 * self.m43
        let m21e = self.m23 * self.m31 * self.m44
        let m21f = self.m21 * self.m33 * self.m44
        let m21 = (m21a - m21b - m21c + m21d + m21e - m21f) * inv
        let m22a = self.m13 * self.m34 * self.m41
        let m22b = self.m14 * self.m33 * self.m41
        let m22c = self.m14 * self.m31 * self.m43
        let m22d = self.m11 * self.m34 * self.m43
        let m22e = self.m13 * self.m31 * self.m44
        let m22f = self.m11 * self.m33 * self.m44
        let m22 = (m22a - m22b + m22c - m22d - m22e + m22f) * inv
        let m23a = self.m14 * self.m23 * self.m41
        let m23b = self.m13 * self.m24 * self.m41
        let m23c = self.m14 * self.m21 * self.m43
        let m23d = self.m11 * self.m24 * self.m43
        let m23e = self.m13 * self.m21 * self.m44
        let m23f = self.m11 * self.m23 * self.m44
        let m23 = (m23a - m23b - m23c + m23d + m23e - m23f) * inv
        let m24a = self.m13 * self.m24 * self.m31
        let m24b = self.m14 * self.m23 * self.m31
        let m24c = self.m14 * self.m21 * self.m33
        let m24d = self.m11 * self.m24 * self.m33
        let m24e = self.m13 * self.m21 * self.m34
        let m24f = self.m11 * self.m23 * self.m34
        let m24 = (m24a - m24b + m24c - m24d - m24e + m24f) * inv
        let m31a = self.m22 * self.m34 * self.m41
        let m31b = self.m24 * self.m32 * self.m41
        let m31c = self.m24 * self.m31 * self.m42
        let m31d = self.m21 * self.m34 * self.m42
        let m31e = self.m22 * self.m31 * self.m44
        let m31f = self.m21 * self.m32 * self.m44
        let m31 = (m31a - m31b + m31c - m31d - m31e + m31f) * inv
        let m32a = self.m14 * self.m32 * self.m41
        let m32b = self.m12 * self.m34 * self.m41
        let m32c = self.m14 * self.m31 * self.m42
        let m32d = self.m11 * self.m34 * self.m42
        let m32e = self.m12 * self.m31 * self.m44
        let m32f = self.m11 * self.m32 * self.m44
        let m32 = (m32a - m32b - m32c + m32d + m32e - m32f) * inv
        let m33a = self.m12 * self.m24 * self.m41
        let m33b = self.m14 * self.m22 * self.m41
        let m33c = self.m14 * self.m21 * self.m42
        let m33d = self.m11 * self.m24 * self.m42
        let m33e = self.m12 * self.m21 * self.m44
        let m33f = self.m11 * self.m22 * self.m44
        let m33 = (m33a - m33b + m33c - m33d - m33e + m33f) * inv
        let m34a = self.m14 * self.m22 * self.m31
        let m34b = self.m12 * self.m24 * self.m31
        let m34c = self.m14 * self.m21 * self.m32
        let m34d = self.m11 * self.m24 * self.m32
        let m34e = self.m12 * self.m21 * self.m34
        let m34f = self.m11 * self.m22 * self.m34
        let m34 = (m34a - m34b - m34c + m34d + m34e - m34f) * inv
        let m41a = self.m23 * self.m32 * self.m41
        let m41b = self.m22 * self.m33 * self.m41
        let m41c = self.m23 * self.m31 * self.m42
        let m41d = self.m21 * self.m33 * self.m42
        let m41e = self.m22 * self.m31 * self.m43
        let m41f = self.m21 * self.m32 * self.m43
        let m41 = (m41a - m41b - m41c + m41d + m41e - m41f) * inv
        let m42a = self.m12 * self.m33 * self.m41
        let m42b = self.m13 * self.m32 * self.m41
        let m42c = self.m13 * self.m31 * self.m42
        let m42d = self.m11 * self.m33 * self.m42
        let m42e = self.m12 * self.m31 * self.m43
        let m42f = self.m11 * self.m32 * self.m43
        let m42 = (m42a - m42b + m42c - m42d - m42e + m42f) * inv
        let m43a = self.m13 * self.m22 * self.m41
        let m43b = self.m12 * self.m23 * self.m41
        let m43c = self.m13 * self.m21 * self.m42
        let m43d = self.m11 * self.m23 * self.m42
        let m43e = self.m12 * self.m21 * self.m43
        let m43f = self.m11 * self.m22 * self.m43
        let m43 = (m43a - m43b - m43c + m43d + m43e - m43f) * inv
        let m44a = self.m12 * self.m23 * self.m31
        let m44b = self.m13 * self.m22 * self.m31
        let m44c = self.m13 * self.m21 * self.m32
        let m44d = self.m11 * self.m23 * self.m32
        let m44e = self.m12 * self.m21 * self.m33
        let m44f = self.m11 * self.m22 * self.m33
        let m44 = (m44a - m44b + m44c - m44d - m44e + m44f) * inv
        
        return Matrix4(m11, m12, m13, m14,
                       m21, m22, m23, m24,
                       m31, m32, m33, m34,
                       m41, m42, m43, m44)
    }
    
    public func transposed() -> Self {
        return Matrix4(row1: self.column1,
                       row2: self.column2,
                       row3: self.column3,
                       row4: self.column4)
    }
    
    public func concatenating(_ m: Self) -> Self {
        let (row1, row2, row3, row4) = (self.row1, self.row2, self.row3, self.row4)
        let (col1, col2, col3, col4) = (m.column1, m.column2, m.column3, m.column4)
        let dot = Vector4<Scalar>.dot
        return Matrix4(dot(row1, col1), dot(row1, col2), dot(row1, col3), dot(row1, col4),
                       dot(row2, col1), dot(row2, col2), dot(row2, col3), dot(row2, col4),
                       dot(row3, col1), dot(row3, col2), dot(row3, col3), dot(row3, col4),
                       dot(row4, col1), dot(row4, col2), dot(row4, col3), dot(row4, col4))
        
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        return Matrix4(row1: lhs.row1 + rhs.row1,
                       row2: lhs.row2 + rhs.row2,
                       row3: lhs.row3 + rhs.row3,
                       row4: lhs.row4 + rhs.row4)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        return Matrix4(row1: lhs.row1 - rhs.row1,
                       row2: lhs.row2 - rhs.row2,
                       row3: lhs.row3 - rhs.row3,
                       row4: lhs.row4 - rhs.row4)
    }
    
    public static func * (lhs: Self, rhs: some BinaryFloatingPoint) -> Self {
        return Matrix4(row1: lhs.row1 * rhs,
                       row2: lhs.row2 * rhs,
                       row3: lhs.row3 * rhs,
                       row4: lhs.row4 * rhs)
    }
    
    public static func / (lhs: some BinaryFloatingPoint, rhs: Self) -> Self {
        return Matrix4(row1: Scalar(lhs) / rhs.row1,
                       row2: Scalar(lhs) / rhs.row2,
                       row3: Scalar(lhs) / rhs.row3,
                       row4: Scalar(lhs) / rhs.row4)
    }
}

public extension Matrix4 {
    @available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
    var half4x4: Half4x4 {
        get { (self.row1.half4, self.row2.half4, self.row3.half4, self.row4.half4) }
        set(v) {
            self.row1.half4 = v.0
            self.row2.half4 = v.1
            self.row3.half4 = v.2
            self.row4.half4 = v.3
        }
    }
    
    var float4x4: Float4x4 {
        get { (self.row1.float4, self.row2.float4, self.row3.float4, self.row4.float4) }
        set(v) {
            self.row1.float4 = v.0
            self.row2.float4 = v.1
            self.row3.float4 = v.2
            self.row4.float4 = v.3
        }
    }
    
    var double4x4: Double4x4 {
        get { (self.row1.double4, self.row2.double4, self.row3.double4, self.row4.double4) }
        set(v) {
            self.row1.double4 = v.0
            self.row2.double4 = v.1
            self.row3.double4 = v.2
            self.row4.double4 = v.3
        }
    }
    
    @available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
    init(_ m: Half4x4) {
        self.init(row1: Vector4(m.0), row2: Vector4(m.1), row3: Vector4(m.2), row4: Vector4(m.3))
    }
    
    init(_ m: Float4x4) {
        self.init(row1: Vector4(m.0), row2: Vector4(m.1), row3: Vector4(m.2), row4: Vector4(m.3))
    }
    
    init(_ m: Double4x4) {
        self.init(row1: Vector4(m.0), row2: Vector4(m.1), row3: Vector4(m.2), row4: Vector4(m.3))
    }
}

public extension Vector3 {
    // homogeneous transform
    func applying(_ m: Matrix4<Scalar>, w: Scalar = 1.0) -> Self {
        let v = Vector4(self.x, self.y, self.z, w).applying(m)
        if w == .zero { return Self(v.x, v.y, v.z) }
        return Self(v.x, v.y, v.z) / v.w
    }
    
    mutating func apply(_ m: Matrix4<Scalar>, w: Scalar = 1.0) {
        self = self.applying(m, w: w)
    }
}

public extension Vector4 {
    func applying(_ m: Matrix4<Scalar>) -> Self {
        let x = Self.dot(self, m.column1)
        let y = Self.dot(self, m.column2)
        let z = Self.dot(self, m.column3)
        let w = Self.dot(self, m.column4)
        return Self(x, y, z, w)
    }
    
    mutating func apply(_ m: Matrix4<Scalar>) {
        self = self.applying(m)
    }
}

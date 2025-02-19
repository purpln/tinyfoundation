extension Comparable {
    public func clamp(min: Self, max: Self) -> Self {
        if self < min { return min }
        if self > max { return max }
        return self
    }
}

public func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
    value.clamp(min: min, max: max)
}

public func lerp<T>(_ a: T, _ b: T, _ t: T) -> T where T: FloatingPoint {
    a * (1 - t) + b * t
}

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
public typealias Half2 = (Float16, Float16)
public typealias Float2 = (Float32, Float32)
public typealias Double2 = (Float64, Float64)

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
public typealias Half3 = (Float16, Float16, Float16)
public typealias Float3 = (Float32, Float32, Float32)
public typealias Double3 = (Float64, Float64, Float64)

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
public typealias Half4 = (Float16, Float16, Float16, Float16)
public typealias Float4 = (Float32, Float32, Float32, Float32)
public typealias Double4 = (Float64, Float64, Float64, Float64)

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
public typealias Half2x2 = (Half2, Half2)
public typealias Float2x2 = (Float2, Float2)
public typealias Double2x2 = (Double2, Double2)

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
public typealias Half3x3 = (Half3, Half3, Half3)
public typealias Float3x3 = (Float3, Float3, Float3)
public typealias Double3x3 = (Double3, Double3, Double3)

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
public typealias Half4x4 = (Half4, Half4, Half4, Half4)
public typealias Float4x4 = (Float4, Float4, Float4, Float4)
public typealias Double4x4 = (Double4, Double4, Double4, Double4)

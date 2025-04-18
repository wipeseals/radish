const std = @import("std");

pub const inf = std.math.inf(f32);
pub const pi: f32 = std.math.pi;

pub fn dgrees_to_radians(degree: f32) f32 {
    return degree * (pi / 180.0);
}
pub fn radians_to_degrees(radian: f32) f32 {
    return radian * (180.0 / pi);
}

pub fn clamp(x: f32, min: f32, max: f32) f32 {
    if (x < min) {
        return min;
    } else if (x > max) {
        return max;
    }
    return x;
}

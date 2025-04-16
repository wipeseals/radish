const std = @import("std");
const vector = @import("vector.zig");

var prng = std.Random.DefaultPrng.init(0);
const rand = prng.random();
pub fn random_in_range(min: f32, max: f32) f32 {
    return rand.float(f32) * (max - min) + min;
}

pub fn random_f32() f32 {
    return random_in_range(0.0, 1.0);
}

pub fn random_vec3_in_range(min: f32, max: f32) vector.Vec3 {
    return vector.Vec3.new(random_in_range(min, max), random_in_range(min, max), random_in_range(min, max));
}
pub fn random_vec3() vector.Vec3 {
    return vector.Vec3.new(random_f32(), random_f32(), random_f32());
}

pub fn random_in_unit_sphere() vector.Vec3 {
    while (true) {
        const p = random_vec3_in_range(-1.0, 1.0);
        if (p.length_squared() >= 1.0) {
            continue;
        }
        return p;
    }
}

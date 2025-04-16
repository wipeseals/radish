const std = @import("std");
const vector = @import("vector.zig");

var prng = std.Random.DefaultPrng.init(0);
const rand = prng.random();
pub fn random_f32_in_range(min: f32, max: f32) f32 {
    return rand.float(f32) * (max - min) + min;
}

pub fn random_f32() f32 {
    return random_f32_in_range(0.0, 1.0);
}

pub fn random_vec3_in_range(min: f32, max: f32) vector.Vec3 {
    return vector.Vec3.new(random_f32_in_range(min, max), random_f32_in_range(min, max), random_f32_in_range(min, max));
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

pub fn random_unit_vector() vector.Vec3 {
    const a = random_f32_in_range(0.0, 2.0 * std.math.pi);
    const z = random_f32_in_range(-1.0, 1.0);
    const r = @sqrt(1.0 - z * z);
    return vector.Vec3.new(r * @cos(a), r * @sin(a), z);
}

pub fn random_in_hemisphere(normal: *const vector.Vec3) vector.Vec3 {
    const in_unit_sphere = random_in_unit_sphere();
    if (in_unit_sphere.dot(normal) > 0.0) {
        return in_unit_sphere;
    } else {
        return in_unit_sphere.mul(-1.0);
    }
}

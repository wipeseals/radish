const std = @import("std");

pub fn random_in_range(min: f32, max: f32) f32 {
    var prng = std.Random.DefaultPrng.init(0);
    const rand = prng.random();
    return rand.float(f32) * (max - min) + min;
}

pub fn random_f32() f32 {
    return random_in_range(0.0, 1.0);
}

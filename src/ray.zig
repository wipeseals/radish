const vector = @import("vector.zig");

pub const Ray = struct {
    origin: vector.Vec3,
    direction: vector.Vec3,

    pub fn new(origin: vector.Vec3, direction: vector.Vec3) Ray {
        return Ray{ .origin = origin, .direction = direction };
    }
    pub fn at(self: Ray, t: f32) vector.Vec3 {
        return self.origin.add(&self.direction.mul(t));
    }
};

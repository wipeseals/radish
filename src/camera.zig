const vector = @import("vector.zig");
const ray = @import("ray.zig");

pub const Camera = struct {
    aspect_ratio: f32,
    viewport_width: f32,
    viewport_height: f32,
    focal_length: f32,
    origin: vector.Vec3,
    horizontal: vector.Vec3,
    vertical: vector.Vec3,
    lower_left_corner: vector.Vec3,

    pub fn new(
        aspect_ratio: f32,
        viewport_height: f32,
        focal_length: f32,
    ) Camera {
        const viewport_width = aspect_ratio * viewport_height;
        const origin = vector.Vec3.new(0.0, 0.0, 0.0);
        const horizontal = vector.Vec3.new(viewport_width, 0.0, 0.0);
        const vertical = vector.Vec3.new(0.0, viewport_height, 0.0);
        const lower_left_corner = origin
            .sub(&horizontal.div(2))
            .sub(&vertical.div(2))
            .sub(&vector.Vec3.new(0.0, 0.0, focal_length));

        return Camera{
            .aspect_ratio = aspect_ratio,
            .viewport_width = viewport_width,
            .viewport_height = viewport_height,
            .focal_length = focal_length,
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lower_left_corner,
        };
    }

    pub fn get_ray(self: Camera, u: f32, v: f32) ray.Ray {
        const direction = self.lower_left_corner
            .add(&self.horizontal.mul(u))
            .add(&self.vertical.mul(v))
            .sub(&self.origin);
        return ray.Ray.new(self.origin, direction);
    }
};

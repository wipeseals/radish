const std = @import("std");
const math = @import("math.zig");

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }
    pub fn add(self: Vec3, other: *const Vec3) Vec3 {
        return Vec3{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
    }
    pub fn sub(self: Vec3, other: *const Vec3) Vec3 {
        return Vec3{ .x = self.x - other.x, .y = self.y - other.y, .z = self.z - other.z };
    }
    pub fn mul(self: Vec3, t: f32) Vec3 {
        return Vec3{ .x = self.x * t, .y = self.y * t, .z = self.z * t };
    }
    pub fn div(self: Vec3, t: f32) Vec3 {
        return Vec3{ .x = self.x / t, .y = self.y / t, .z = self.z / t };
    }
    pub fn length(self: Vec3) f32 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }
    pub fn length_squared(self: Vec3) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }
    pub fn dot(self: Vec3, other: *const Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
    pub fn cross(self: Vec3, other: *const Vec3) Vec3 {
        return Vec3{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }
    pub fn unit_vector(self: Vec3) Vec3 {
        return self.div(self.length());
    }
    pub fn to_string(self: Vec3, sample_per_pixel: u32, allocator: std.mem.Allocator) ![]const u8 {
        // normalize the color values to 0-255 range & gamma correction
        const scale = 1.0 / @as(f32, @floatFromInt(sample_per_pixel));
        const r = @sqrt(self.x * scale);
        const g = @sqrt(self.y * scale);
        const b = @sqrt(self.z * scale);

        return try std.fmt.allocPrint(allocator, "{d} {d} {d} ", .{
            @as(u8, @intFromFloat(256 * math.clamp(r, 0.0, 0.999))) & 0xff,
            @as(u8, @intFromFloat(256 * math.clamp(g, 0.0, 0.999))) & 0xff,
            @as(u8, @intFromFloat(256 * math.clamp(b, 0.0, 0.999))) & 0xff,
        });
    }
};
pub const Color = Vec3;
pub const Point3 = Vec3;

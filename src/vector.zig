const std = @import("std");

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
    pub fn to_string(self: Vec3, allocator: std.mem.Allocator) ![]const u8 {
        return try std.fmt.allocPrint(allocator, "{d} {d} {d} ", .{
            @as(u8, @intFromFloat(255.999 * self.x)) & 0xff,
            @as(u8, @intFromFloat(255.999 * self.y)) & 0xff,
            @as(u8, @intFromFloat(255.999 * self.z)) & 0xff,
        });
    }
};
pub const Color = Vec3;
pub const Point3 = Vec3;

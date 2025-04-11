const std = @import("std");
const allocator = std.heap.page_allocator;

const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    fn new(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }
    fn add(self: Vec3, other: *Vec3) Vec3 {
        return Vec3{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
    }
    fn sub(self: Vec3, other: *Vec3) Vec3 {
        return Vec3{ .x = self.x - other.x, .y = self.y - other.y, .z = self.z - other.z };
    }
    fn mul(self: Vec3, t: f32) Vec3 {
        return Vec3{ .x = self.x * t, .y = self.y * t, .z = self.z * t };
    }
    fn div(self: Vec3, t: f32) Vec3 {
        return Vec3{ .x = self.x / t, .y = self.y / t, .z = self.z / t };
    }
    fn length(self: Vec3) f32 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }
    fn length_squared(self: Vec3) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }
    fn dot(self: Vec3, other: *Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
    fn cross(self: Vec3, other: *Vec3) Vec3 {
        return Vec3{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }
    fn to_string(self: Vec3) ![]const u8 {
        return try std.fmt.allocPrint(allocator, "{d} {d} {d} ", .{
            @as(u8, @intFromFloat(255.999 * self.x)) & 0xff,
            @as(u8, @intFromFloat(255.999 * self.y)) & 0xff,
            @as(u8, @intFromFloat(255.999 * self.z)) & 0xff,
        });
    }
};
const Color = Vec3;

pub fn main() !void {
    const filename = "output.ppm";
    const file = try std.fs.cwd().createFile(filename, .{});
    const file_writer = file.writer();
    defer file.close();
    const width: u32 = 256;
    const height: u32 = 256;

    // print ppm format
    try file_writer.print("P3\n{d} {d}\n255\n", .{ width, height });
    for (0..width) |x| {
        for (0..height) |y| {
            const color = Color.new(
                @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(width - 1)),
                @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(height - 1)),
                0.25,
            );

            // print the color
            _ = try file_writer.write(try color.to_string());
        }
        std.debug.print("progress: {d} % ({d}/{d})\n", .{
            (x * 100) / width,
            x,
            width,
        });
    }
}

const std = @import("std");
const allocator = std.heap.page_allocator;

const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    fn new(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }
    fn add(self: Vec3, other: *const Vec3) Vec3 {
        return Vec3{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
    }
    fn sub(self: Vec3, other: *const Vec3) Vec3 {
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
    fn dot(self: Vec3, other: *const Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
    fn cross(self: Vec3, other: *const Vec3) Vec3 {
        return Vec3{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }
    fn unit_vector(self: Vec3) Vec3 {
        return self.div(self.length());
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

const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    fn new(origin: Vec3, direction: Vec3) Ray {
        return Ray{ .origin = origin, .direction = direction };
    }
    fn at(self: Ray, t: f32) Vec3 {
        return self.origin.add(&self.direction.mul(t));
    }
};

pub fn bg_color(ray: Ray) Color {
    const unit_vector = ray.direction.unit_vector();
    const t = 0.5 * (unit_vector.y + 1.0);
    return Color.new(1.0, 1.0, 1.0).mul(1.0 - t).add(&Color.new(0.5, 0.7, 1.0).mul(t));
}

pub fn main() !void {
    const filename = "output.ppm";
    const file = try std.fs.cwd().createFile(filename, .{});
    const file_writer = file.writer();
    defer file.close();

    const aspect_ratio: f32 = 16.0 / 9.0;
    const image_width: u32 = 384;
    const image_height: u32 = @as(u32, @intFromFloat(@as(f32, image_width) / @as(f32, aspect_ratio)));

    const viewport_height = 2.0;
    const viewport_width: f32 = aspect_ratio * viewport_height;
    const origin = Vec3.new(0.0, 0.0, 0.0);
    const horizontal = Vec3.new(viewport_width, 0.0, 0.0);
    const vertical = Vec3.new(0.0, viewport_height, 0.0);
    const lower_left_corner = origin.sub(&horizontal.div(2)).sub(&vertical.div(2)).sub(&Vec3.new(0.0, 1.0, 1.0));

    // print ppm format
    try file_writer.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| { // bottom to top
        const y = image_height - j - 1;
        for (0..image_width) |i| { // left to right
            const x = i;
            // calculate the ray for the pixel
            const u = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(image_width - 1));
            const v = @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(image_height - 1));
            const ray = Ray.new(
                origin,
                lower_left_corner.add(&horizontal.mul(u)).add(&vertical.mul(v)).sub(&origin),
            );
            const color = bg_color(ray);
            // print the color
            _ = try file_writer.write(try color.to_string());
        }
        std.debug.print("progress: {d}/{d}\n", .{
            j,
            image_height,
        });
    }
}

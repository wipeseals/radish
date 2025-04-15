const std = @import("std");
const math = @import("math.zig");
const Vec3 = @import("vector.zig").Vec3;
const Color = @import("vector.zig").Color;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hit.zig").HitRecord;
const Sphere = @import("sphere.zig").Sphere;
const Hittable = @import("hit.zig").Hittable;
const HittableList = @import("hit.zig").HittableList;

pub fn bg_color(ray: *const Ray) Color {
    const unit_vector = ray.direction.unit_vector();
    const t = 0.5 * (unit_vector.y + 1.0);
    return Color.new(1.0, 1.0, 1.0).mul(1.0 - t).add(&Color.new(0.5, 0.7, 1.0).mul(t));
}

pub fn calc_ray_color(ray: *const Ray, hittable_list: *const HittableList) Color {
    var record = HitRecord.new(0.0, Vec3.new(0.0, 0.0, 0.0), Vec3.new(0.0, 0.0, 0.0));
    if (hittable_list.hit(ray, 0.0, math.inf, &record)) {
        return Color.new(
            record.normal.x + 1.0,
            record.normal.y + 1.0,
            record.normal.z + 1.0,
        ).mul(0.5);
    }
    return bg_color(ray);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const filename = "output.ppm";
    const file = try std.fs.cwd().createFile(filename, .{});
    const file_writer = file.writer();
    defer file.close();

    const aspect_ratio: f32 = 16.0 / 9.0;
    const image_width: u32 = 384;
    const image_height: u32 = @as(u32, @intFromFloat(@as(f32, image_width) / @as(f32, aspect_ratio)));

    const viewport_height = 2.0;
    const viewport_width: f32 = aspect_ratio * viewport_height;
    const focal_length: f32 = 1.0;
    const origin = Vec3.new(0.0, 0.0, 0.0);
    const horizontal = Vec3.new(viewport_width, 0.0, 0.0);
    const vertical = Vec3.new(0.0, viewport_height, 0.0);
    const lower_left_corner = origin.sub(&horizontal.div(2)).sub(&vertical.div(2)).sub(&Vec3.new(0.0, 0.0, focal_length));

    // create a list of spheres
    const hittable = [_]Hittable{
        Hittable{ .sphere = Sphere.new(Vec3.new(0.0, 0.0, -1.0), 0.5) },
        Hittable{ .sphere = Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0) },
    };
    const hittable_list = HittableList.new(&hittable);

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
            const color = calc_ray_color(&ray, &hittable_list);
            // print the color
            {
                const color_text = try color.to_string(allocator);
                defer allocator.free(color_text);
                _ = try file_writer.write(color_text);
            }
        }
        std.debug.print("progress: {d}/{d}\n", .{
            j,
            image_height,
        });
    }
}

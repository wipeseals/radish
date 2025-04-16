const std = @import("std");
const math = @import("math.zig");
const random = @import("random.zig");
const vector = @import("vector.zig");
const ray = @import("ray.zig");
const hit = @import("hit.zig");
const sphere = @import("sphere.zig");
const camera = @import("camera.zig");

pub fn bg_color(ray_param: *const ray.Ray) vector.Color {
    const unit_vector = ray_param.direction.unit_vector();
    const t = 0.5 * (unit_vector.y + 1.0);
    return vector.Color.new(1.0, 1.0, 1.0).mul(1.0 - t).add(&vector.Color.new(0.5, 0.7, 1.0).mul(t));
}

pub fn calc_ray_color(ray_param: *const ray.Ray, hittable_list: *const hit.HittableList, depth: u32) vector.Color {
    if (depth <= 0) {
        return vector.Color.new(0.0, 0.0, 0.0);
    }
    var record = hit.HitRecord.new(0.0, vector.Vec3.new(0.0, 0.0, 0.0), vector.Vec3.new(0.0, 0.0, 0.0));
    if (hittable_list.hit(ray_param, 0.0, math.inf, &record)) {
        const target = record.p.add(&record.normal).add(&random.random_in_unit_sphere());
        const new_ray = ray.Ray.new(record.p, target.sub(&record.p));
        return calc_ray_color(&new_ray, hittable_list, depth - 1).mul(0.5);
    }
    return bg_color(ray_param);
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
    const focal_length: f32 = 1.0;
    const sample_per_pixel: u32 = 100;
    const max_depth: u32 = 50;

    // create a camera
    const cam = camera.Camera.new(aspect_ratio, viewport_height, focal_length);

    // create a list of spheres
    const hittable = [_]hit.Hittable{
        hit.Hittable{ .sphere = sphere.Sphere.new(vector.Vec3.new(0.0, 0.0, -1.0), 0.5) },
        hit.Hittable{ .sphere = sphere.Sphere.new(vector.Vec3.new(0.0, -100.5, -1.0), 100.0) },
    };
    const hittable_list = hit.HittableList.new(&hittable);

    // print ppm format
    try file_writer.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| { // bottom to top
        const y = image_height - j - 1;
        for (0..image_width) |i| { // left to right
            const x = i;

            // random samples
            var color = vector.Color.new(0.0, 0.0, 0.0);
            for (0..sample_per_pixel) |_| {
                const u = @as(f32, @floatFromInt(x)) + random.random_f32() / @as(f32, sample_per_pixel);
                const v = @as(f32, @floatFromInt(y)) + random.random_f32() / @as(f32, sample_per_pixel);
                const camera_ray = cam.get_ray(u / @as(f32, image_width - 1), v / @as(f32, image_height - 1));
                color = color.add(&calc_ray_color(&camera_ray, &hittable_list, max_depth));
            }
            // print the color
            {
                const color_text = try color.to_string(sample_per_pixel, allocator);
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

const std = @import("std");

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
    fn to_string(self: Vec3, allocator: std.mem.Allocator) ![]const u8 {
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

const Sphere = struct {
    center: Vec3,
    radius: f32,

    fn new(center: Vec3, radius: f32) Sphere {
        return Sphere{ .center = center, .radius = radius };
    }

    fn hit(self: Sphere, ray: *const Ray, t_min: f32, t_max: f32, record: *HitRecord) bool {
        const oc = ray.origin.sub(&self.center);
        const a = ray.direction.length_squared();
        const half_b = oc.dot(&ray.direction);
        const c = oc.length_squared() - self.radius * self.radius;
        const discriminant = half_b * half_b - a * c;

        if (discriminant > 0.0) {
            const root = (-half_b - @sqrt(discriminant)) / a;
            if (t_min < root and root < t_max) {
                const p = ray.at(root);
                const normal = p.sub(&self.center).div(self.radius);
                record.* = HitRecord.new(root, p, normal);
                return true;
            }
            const root2 = (-half_b + @sqrt(discriminant)) / a;
            if (t_min < root2 and root2 < t_max) {
                const p = ray.at(root2);
                const normal = p.sub(&self.center).div(self.radius);
                record.* = HitRecord.new(root2, p, normal);

                return true;
            }
        }
        return false;
    }
    fn to_string(self: Sphere, allocator: std.mem.Allocator) ![]const u8 {
        return try std.fmt.allocPrint(allocator, "Sphere(center: {d}, {d}, {d}, radius: {d})", .{
            self.center.x,
            self.center.y,
            self.center.z,
            self.radius,
        });
    }
};
const HitRecord = struct {
    p: Vec3,
    normal: Vec3,
    t: f32,

    fn new(t: f32, p: Vec3, normal: Vec3) HitRecord {
        return HitRecord{ .t = t, .p = p, .normal = normal };
    }
};
const Hittable = union(enum) {
    sphere: Sphere,

    pub fn hit(self: Hittable, ray: *const Ray, t_min: f32, t_max: f32, record: *HitRecord) bool {
        return switch (self) {
            inline else => |case| case.hit(ray, t_min, t_max, record),
        };
    }
};

const HittableList = struct {
    objects: []const Hittable,

    pub fn new(objects: []const Hittable) HittableList {
        return HittableList{ .objects = objects };
    }

    pub fn hit(self: HittableList, ray: *const Ray, t_min: f32, t_max: f32, record: *HitRecord) bool {
        var hit_anything = false;
        var closest_so_far = t_max;

        for (self.objects) |object| {
            var temp_record = HitRecord.new(0.0, Vec3.new(0.0, 0.0, 0.0), Vec3.new(0.0, 0.0, 0.0));
            if (object.hit(ray, t_min, closest_so_far, &temp_record)) {
                hit_anything = true;
                closest_so_far = temp_record.t;
                record.* = temp_record;
            }
        }
        return hit_anything;
    }
};

const inf = std.math.inf(f32);
const pi: f32 = std.math.pi;

fn dgrees_to_radians(degree: f32) f32 {
    return degree * (pi / 180.0);
}
fn radians_to_degrees(radian: f32) f32 {
    return radian * (180.0 / pi);
}

pub fn bg_color(ray: *const Ray) Color {
    const unit_vector = ray.direction.unit_vector();
    const t = 0.5 * (unit_vector.y + 1.0);
    return Color.new(1.0, 1.0, 1.0).mul(1.0 - t).add(&Color.new(0.5, 0.7, 1.0).mul(t));
}

pub fn calc_ray_color(ray: *const Ray, hittable_list: *const HittableList) Color {
    var record = HitRecord.new(0.0, Vec3.new(0.0, 0.0, 0.0), Vec3.new(0.0, 0.0, 0.0));
    if (hittable_list.hit(ray, 0.0, inf, &record)) {
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
            _ = try file_writer.write(try color.to_string(allocator));
        }
        std.debug.print("progress: {d}/{d}\n", .{
            j,
            image_height,
        });
    }
}

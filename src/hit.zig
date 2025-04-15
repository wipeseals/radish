const Vec3 = @import("vector.zig").Vec3;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;

pub const HitRecord = struct {
    p: Vec3,
    normal: Vec3,
    t: f32,

    pub fn new(t: f32, p: Vec3, normal: Vec3) HitRecord {
        return HitRecord{ .t = t, .p = p, .normal = normal };
    }
};
pub const Hittable = union(enum) {
    sphere: Sphere,

    pub fn hit(self: Hittable, ray: *const Ray, t_min: f32, t_max: f32, record: *HitRecord) bool {
        return switch (self) {
            inline else => |case| case.hit(ray, t_min, t_max, record),
        };
    }
};

pub const HittableList = struct {
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

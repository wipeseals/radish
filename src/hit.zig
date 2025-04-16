const vector = @import("vector.zig");
const ray = @import("ray.zig");
const sphere = @import("sphere.zig");

pub const HitRecord = struct {
    p: vector.Vec3,
    normal: vector.Vec3,
    t: f32,

    pub fn new(t: f32, p: vector.Vec3, normal: vector.Vec3) HitRecord {
        return HitRecord{ .t = t, .p = p, .normal = normal };
    }
};
pub const Hittable = union(enum) {
    sphere: sphere.Sphere,

    pub fn hit(self: Hittable, ray_param: *const ray.Ray, t_min: f32, t_max: f32, record: *HitRecord) bool {
        return switch (self) {
            .sphere => |case| case.is_hit(ray_param, t_min, t_max, record),
        };
    }
};

pub const HittableList = struct {
    objects: []const Hittable,

    pub fn new(objects: []const Hittable) HittableList {
        return HittableList{ .objects = objects };
    }

    pub fn hit(self: HittableList, ray_param: *const ray.Ray, t_min: f32, t_max: f32, record: *HitRecord) bool {
        var hit_anything = false;
        var closest_so_far = t_max;

        for (self.objects) |object| {
            var temp_record = HitRecord.new(0.0, vector.Vec3.new(0.0, 0.0, 0.0), vector.Vec3.new(0.0, 0.0, 0.0));
            if (object.hit(ray_param, t_min, closest_so_far, &temp_record)) {
                hit_anything = true;
                closest_so_far = temp_record.t;
                record.* = temp_record;
            }
        }
        return hit_anything;
    }
};

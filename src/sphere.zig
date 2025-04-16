const vector = @import("vector.zig");
const ray = @import("ray.zig");
const hit = @import("hit.zig");

pub const Sphere = struct {
    center: vector.Vec3,
    radius: f32,

    pub fn new(center: vector.Vec3, radius: f32) Sphere {
        return Sphere{ .center = center, .radius = radius };
    }

    pub fn is_hit(self: Sphere, ray_param: *const ray.Ray, t_min: f32, t_max: f32, record: *hit.HitRecord) bool {
        const oc = ray_param.origin.sub(&self.center);
        const a = ray_param.direction.length_squared();
        const half_b = oc.dot(&ray_param.direction);
        const c = oc.length_squared() - self.radius * self.radius;
        const discriminant = half_b * half_b - a * c;

        if (discriminant > 0.0) {
            const root = (-half_b - @sqrt(discriminant)) / a;
            if (t_min < root and root < t_max) {
                const p = ray_param.at(root);
                const normal = p.sub(&self.center).div(self.radius);
                record.* = hit.HitRecord.new(root, p, normal);
                return true;
            }
            const root2 = (-half_b + @sqrt(discriminant)) / a;
            if (t_min < root2 and root2 < t_max) {
                const p = ray_param.at(root2);
                const normal = p.sub(&self.center).div(self.radius);
                record.* = hit.HitRecord.new(root2, p, normal);

                return true;
            }
        }
        return false;
    }
};

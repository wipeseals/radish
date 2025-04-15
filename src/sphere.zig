const Vec3 = @import("vector.zig").Vec3;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hit.zig").HitRecord;

pub const Sphere = struct {
    center: Vec3,
    radius: f32,

    pub fn new(center: Vec3, radius: f32) Sphere {
        return Sphere{ .center = center, .radius = radius };
    }

    pub fn hit(self: Sphere, ray: *const Ray, t_min: f32, t_max: f32, record: *HitRecord) bool {
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
};

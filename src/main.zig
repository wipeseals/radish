const std = @import("std");

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
            // calculate the color
            const r = x * 255 / width;
            const g = y * 255 / height;
            const b = ((x + y) * 255) / (width + height);

            // print the color
            try file_writer.print("{d} {d} {d}\n", .{ r, g, b });
        }
    }
}

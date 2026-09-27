const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const skip = &[_][]const u8{ "zig-out", "zig-cache", ".zig-cache" };

    const io = b.graph.io;
    var root = std.Io.Dir.cwd().openDir(io, ".", .{ .iterate = true }) catch unreachable;
    defer root.close(io);

    var iter = root.iterate();
    while (iter.next(io) catch unreachable) |entry| {
        if (entry.kind != .directory) continue;

        var should_skip = false;
        for (skip) |s| {
            if (std.mem.eql(u8, entry.name, s)) { should_skip = true; break; }
        }
        if (should_skip) continue;

        const main_path = b.fmt("{s}/main.zig", .{entry.name});
        root.access(io, main_path, .{}) catch continue;

        const name = b.dupe(entry.name);

        const exe = b.addExecutable(.{
            .name = name,
            .root_module = b.createModule(.{
                .optimize = optimize,
                .target = target,
                .root_source_file = b.path(main_path),
            }),
        });

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step(name, b.fmt("Run {s}", .{name}));
        run_step.dependOn(&run_cmd.step);
    }
}

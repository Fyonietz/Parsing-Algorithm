const std = @import("std");

pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = log,
};

fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    const prefix = switch (level) {
        .debug => "[DEBUG]",
        .info => "[INFO]",
        .warn => "[WARN]",
        .err => "[ERROR]",
    };

    std.debug.print("{s} ", .{prefix});

    if (scope != .default) {
        std.debug.print("[{s}] ", .{@tagName(scope)});
    }

    std.debug.print(format ++ "\n", args);
}

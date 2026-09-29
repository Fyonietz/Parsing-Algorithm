const std = @import("std");

const BindPowerStructure = struct { key: u8, value: i32 };

const BindingPower = [_]BindPowerStructure{
    //10 Value
    .{ .key = '+', .value = 10 },
    .{ .key = '-', .value = 10 },

    //20 Value
    .{ .key = '*', .value = 20 },
    .{ .key = '/', .value = 20 },

    //30 Value
    .{ .key = ')', .value = 30 },
    .{ .key = '(', .value = 30 },
};

fn get_binding_value(entries: []const BindPowerStructure, key: u8) ?i32 {
    for (entries) |entry| {
        if (entry.key == key) {
            return entry.value;
        }
    }
    return null;
}
const Parser = struct {
    content: []const u8,
    cursor: u8,

    fn peek(self: *const @This()) ?u8 {
        if (self.cursor < self.content.len) return self.content[self.cursor];
        return null;
    }

    fn consume(self: *@This()) ?u8 {
        const char = self.peek();
        if (char != null) {
            self.cursor += 1;
        }
        return char;
    }

    fn parse_number(self: *@This()) ?i64 {
        var result: i32 = 0;
        while (self.peek()) |char| {
            if (char < '0' or char > '9') {
                break;
            }
            result = result * 10 + (char - '0');
            _ = self.consume();
        }

        return result;
    }

    fn parse_addition(self: *@This()) ?i64 {
        var result: i64 = self.parse_number().?;
        while (self.peek()) |char| {
            if (char == '+') {
                _ = self.consume();
                result += self.parse_number().?;
            } else {
                break;
            }
        }

        return result;
    }
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    //Open File
    var file_buffer: [1028]u8 = undefined;
    const dir = std.Io.Dir.cwd();
    const content = try dir.readFile(io, "math/source.txt", &file_buffer);

    var parser = Parser{ .cursor = 0, .content = content };
    // const result = parser.parse_addition();
    std.debug.print("Here The Result : {c}\n", .{parser.peek().?});
}

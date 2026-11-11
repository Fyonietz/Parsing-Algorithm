const custom_logger = @import("logger.zig");
pub const std_options = custom_logger.std_options;
const std = @import("std");
const print = std.log.debug;
const err = std.log.err;

pub const TokenType = enum { Number, Plus, eof, whitespace };

pub const Token = struct { type: TokenType, value: i32 };

pub const Lexer = struct {
    content: []const u8,
    cursor: usize,
    pub fn peek(self: *@This()) ?u8 {
        if (self.cursor >= self.content.len) {
            return null;
        }
        return self.content[self.cursor];
    }
    pub fn advance(self: *@This()) void {
        if (self.cursor < self.content.len) {
            self.cursor += 1;
        }
    }

    pub fn to_integer(self: *@This()) ?i32 {
        var number: i32 = 0;
        var found_digit: bool = false;

        while (self.peek()) |digit| {
            if (digit >= '0' and digit <= '9') {
                number = number * 10 + (digit - '0');
                self.advance();
                found_digit = true;
            } else {
                break;
            }
        }
        if (!found_digit) return null;
        return number;
    }

    pub fn next_token(self: *@This()) ?Token {
        while (self.peek()) |char| {
            if (char == ' ') {
                self.advance();
                continue;
            }
            if (char >= '0' and char <= '9') {
                const number = self.to_integer() orelse return null;
                self.advance();
                return .{ .type = .Number, .value = number };
            }
            if (char == '+') {
                self.advance();
                return .{ .type = .Plus, .value = 0 };
            }
            break;
        }

        return null;
    }
};

pub fn main() !void {
    const source: []const u8 = "12 + 4";
    const i: usize = 0;
    var lexer: Lexer = .{ .content = source, .cursor = i };
    while(lexer.next_token())|token|{
        print("{s} ({d})", .{ @tagName(token.type), token.value });
    }
}

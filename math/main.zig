const std = @import("std");

const BindPowerStructure = struct {
    key: u8,
    value: i32,
};

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
    return 0;
}

const TokenType = enum { Number, Operator, EOF };

const AST = struct {
    type: TokenType,
    value: ?u8,
};

const ASTNode = struct {
    type: TokenType,
    value: ?u8,
    operator: u8,

    left: *@This(),
    right: *@This(),
};

const Parser = struct {
    content: []const u8,
    cursor: u8,
    allocator: std.mem.Allocator,
    current_token: AST = undefined,

    fn get_next_token(self: *@This()) !AST {
        while (self.cursor < self.content.len and self.content[self.cursor] == ' ') {
            self.cursor += 1;
        }
        if (self.cursor >= self.content.len) {
            return .{
                .type = .EOF,
                .value = null,
            };
        }

        const char = self.content[self.cursor];
        if (char >= '0' and char <= '9') {
            self.cursor += 1;
            return .{ .value = char, .type = .Number };
        }

        if (char == '+' or char == '-' or char == '*' or char == '/') {
            self.cursor += 1;
            return .{ .type = .Operator, .value = char };
        }

        return error.InvalidCharacter;
    }

    fn consume(self: *@This()) !AST {
        const tokenToReturn: AST = self.current_token;

        self.current_token = try self.get_next_token();

        return tokenToReturn;
    }

    fn create_number_node(self: *@This(), value: ?u8) !*ASTNode {
        const node: *ASTNode = try self.allocator.create(ASTNode);
        defer _ = self.allocator.destroy(node);

        node.type = .Number;
        node.value = value;
        node.operator = 0;
        node.left = undefined;
        node.right = undefined;

        return node;
    }

    fn create_operation_node(self: *@This(), operator: u8, left_node: *ASTNode, right_node: *ASTNode) !*ASTNode {
        const node: *ASTNode = try self.allocator.create(ASTNode);
        defer _ = self.allocator.destroy(node);

        node.type = .Operator;
        node.operator = operator;
        node.left = left_node;
        node.right = right_node;

        return node;
    }

    fn peek_power(self:*@This())i32{
        const v = self.current_token.value orelse 0;
        return get_binding_value(&BindingPower, v) orelse 0;
    }

    fn parse_expression(self: *@This(), current_binding_power: i32) !*ASTNode {
        //NUD

        const left_token: AST = try self.consume();

        var left_node: *ASTNode = undefined;

        if (left_token.type == .Number) {
            left_node = try self.create_number_node(left_token.value);
        } else {
            return error.MustBeANumber;
        }

        var next_power = self.peek_power();

        while (next_power > current_binding_power) {
            const operator_token: AST = try self.consume();

            const right_node: *ASTNode = try self.parse_expression(next_power);

            left_node = try self.create_operation_node(operator_token.value.?, left_node, right_node);

            next_power = self.peek_power();
        }

        return left_node;
    }
};
fn print_ast(node: *const ASTNode, depth: usize) void {
    for (0..depth) |_| std.debug.print("  ", .{});

    switch (node.type) {
        .Number => std.debug.print("Number({c})\n", .{node.value.?}),
        .Operator => {
            std.debug.print("Op({c})\n", .{node.operator});
            print_ast(node.left, depth + 1);
            print_ast(node.right, depth + 1);
        },
        .EOF => {},
    }
}
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    //Open File
    var file_buffer: [1028]u8 = undefined;
    const dir = std.Io.Dir.cwd();
    const content = try dir.readFile(io, "math/source.txt", &file_buffer);

    const p = try gpa.create(Parser);
    defer _ = gpa.destroy(p);
    p.* = .{ .allocator = gpa, .content = content, .cursor = 0 };
    p.current_token = try p.get_next_token();
    const output = try p.parse_expression(0);
    print_ast(output,0);
}

const print = @import("std").debug.print;

pub const Lexer = struct {
    content:[]const u8,
    cursor:usize,


    pub fn peek(self:*@This()) ?u8{
        if(self.cursor < self.content.len) return self.content[self.cursor];
        return null;
    }

    pub fn power(self:*@This()) i32{
        if(self.peek() == '+' or self.peek() == '-') return 10;
        if(self.peek() == '*' or self.peek() == '/') return 20;
        return 0;
    }

};

pub fn main() !void{
    const content : []const u8 = "2 + 3 * 4";
    var lexer:Lexer = .{.cursor = 0,.content = content};
    const out = lexer.peek();
    print("Content : {c}\n",.{out.?});
}


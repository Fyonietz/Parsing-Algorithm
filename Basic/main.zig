const print = @import("std").debug.print;

pub const TokenType = enum{
    number,
    plus,
    eof,
    whitespace
};

pub const Token = struct{
    type:TokenType,
    value:i32
};


pub const Lexer = struct {
    content:[]const u8,
    cursor:usize,
    pub fn peek(self : *@This()) ?u8 {
        if(self.cursor >= self.content.len){
            return null;
        }
        return self.content[self.cursor];
    }
    pub fn advance(self : *@This()) void {
        if(self.cursor < self.content.len){
            self.cursor += 1;
        }
    }

}; 

pub fn main() !void {
    const source : []const u8 = "12 + 4";
    var lexer : Lexer = .{
        .content = source,
        .cursor = 0
    };
    const res = lexer.peek() orelse unreachable;
    _ = lexer.next_token();
    print("Peek : {c}",.{res});
}

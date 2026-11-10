const print = @import("std").log.debug;
const err = @import("std").log.err;


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

    pub fn to_integer(self: *@This()) ?i32{
        var number : i32 = 0;
        var found_digit : bool = false;

        while(self.peek()) |digit|{
            if(digit >= '0' and digit <= '9'){
                number = number * 10 + (digit - '0');
                self.advance();
                found_digit=true;
            }else{
                break;
            }
        }
        if(!found_digit) return null;
        return number;
    }

    pub fn next_token(self:*@This()) ?Token{
        const char = self.peek() orelse {
            err("Failed to read character at index : {d}",.{self.cursor});
            return null;
        };

        if(char == ' '){
            print("Found a whitespace",.{});
            self.advance();
            continue;
        }
        if(char >= '0' and char <= '9'){
            const number = self.to_integer() orelse return null;
            self.advance();
            return .{.type = .number,.value = number};
        }
        if(char == '+'){
            self.advance();
            return .{.type = .plus,.value = 0};
        }

        
        return null;
    }

}; 

pub fn main() !void {
    const source : []const u8 = "12 + 4";
    const i : usize = 0;
    var lexer : Lexer = .{
        .content = source,
        .cursor = i
    };
    const res = lexer.peek() orelse unreachable;
    const token = lexer.next_token();
    print("Peek : {c}\n",.{res});
    print("Type : {s}, Value : {d}\n",.{@tagName(token.?.type),token.?.value});
}

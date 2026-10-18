const print = @import("std").debug.print;

pub const Operator = struct {
    Power:i32,
    Value:u8
}; 


pub const Lexer = struct {
    content:[]const u8,
    cursor:usize,


    pub fn peek(self:*@This()) ?u8{
        if(self.cursor < self.content.len - 1){
            return self.content[self.cursor];
        }
        return null;
    }

    pub fn move(self:*@This()) void{
        if(self.cursor >= self.content.len - 1) return;
        self.cursor+=1;
    }
    pub fn find_operator(self:*@This()) Operator{
        var i : usize = 0;
        while (i < self.content.len) : (i += 1) {
            if (self.peek()) |char| {
                 print("Char: '{c}', ASCII: {d}\n", .{ char, char });
                if (char == '+' or char == '-') {
                    print(
                        "A Operator! On Iteration Number: {d}\n",
                        .{i},
                    );

                    return .{
                        .Value = 10,
                        .Power = char,
                    };
                }
                if (char >= '0' and char <= '9') {
                    print(
                        "A Number! On Iteration Number: {d}\n",
                        .{i},
                    );
                    self.move();
                    continue;
                }

                // Anything else
                print("Unknown character: {c}\n", .{char});
                break;
            } else {
                print("Null Value\n", .{});
                break;
            }
        }

        return .{
            .Power = 0,
            .Value = 0
    };
    }

};

pub fn main() !void{
    const content : []const u8 = "2+3*4";
    var lexer:Lexer = .{.cursor = 0,.content = content};
    const out = lexer.peek();
    _ = lexer.find_operator();
    print("Content : {c}\n",.{out.?});
}


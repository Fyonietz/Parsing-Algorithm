const print = @import("std").debug.print;

pub const Operator = struct {
    Power:i32,
    Value:u8
}; 


pub const Lexer = struct {
    content:[]const u8,
    cursor:usize,
    buffer:[]u8,


    pub fn peek(self: *@This()) ?u8 {
        if (self.cursor >= self.content.len) {
            return null;
        }

        return self.content[self.cursor];
    }

    pub fn move(self: *@This()) void {
        if (self.cursor < self.content.len) {
            self.cursor += 1;
        }
    }

    pub fn assign_buffer(self: *@This()) bool {
        var i: usize = 0;
        self.cursor = 0;
        while (i < self.content.len) {
            const char = self.peek() orelse {
                print("Failed to read character at index: {d}\n", .{i});
                return false;
            };

            self.buffer[i] = char;
            self.move();
            i += 1;
        }

        return true;
    }

    //TODO : Implement The Strongest Operator Arithmetics
    pub fn find_operator(self:*@This()) Operator{
        var i : usize = 0;
        while (i < self.content.len) : (i += 1) {
            if (self.peek()) |char| {
                if (char == '+' or char == '-') {
                    return .{
                        .Value = char,
                        .Power = 10,
                    };
                }
                if (char == '*' or char == '/') {
                    return .{
                        .Value = char,
                        .Power = 20,
                    };
                }
                if (char >= '0' and char <= '9') {
                    self.move();
                    continue;
                }

                print("Unknown character: {c}\n", .{char});
                break;
            } else {
                print("Null Value Behavior! Break!\n", .{});
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
    var buffer:[1024]u8 = undefined;
    const content : []const u8 = "2+3*4";
    var lexer:Lexer = .{.cursor = 0,.content = content,.buffer = &buffer};
    _ = lexer.find_operator();
    _ = lexer.assign_buffer();
    for(buffer)|char|{
        if(char != 170){
            print("Token : {c}\n",.{char});
        }
    }
}


const main = @import("main.zig");
const testing = @import("std").testing;
const Lexer = main.Lexer;
const Operator = main.Operator;

fn runLexerTest(
    cursor: usize, 
    comptime action: anytype, 
    expected: anytype
) !void {

    var buffer:[1024]u8 = undefined;
    const content : []const u8 = "2+3*4";
    var lexer = Lexer{ .cursor = cursor, .content = content,.buffer = &buffer };
    
    const out = action(&lexer); 
    
    try testing.expectEqual(expected, out);
}


test "peek" {
    try runLexerTest(
        0, 
        struct {
            fn call(l: *Lexer) u8 { 
                return l.peek().?; 
            }
        }.call, 
        @as(u8, '2')
    );
}

test "find operator" {
    try runLexerTest(
        1, 
        struct {
            fn call(l: *Lexer) Operator { 
                return l.find_operator(); 
                }
            }.call, 
        Operator{.Power = 10,.Value = '+'}
    );
}

test "assign buffer"{
    try runLexerTest(0,
        struct {
            fn call(l: *Lexer) bool { 
                return l.assign_buffer(); 
                }
            }.call,
        true);
}

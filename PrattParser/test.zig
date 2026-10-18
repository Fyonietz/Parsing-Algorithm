const main = @import("main.zig");
const testing = @import("std").testing;
const Lexer = main.Lexer;
const Operator = main.Operator;

fn runLexerTest(
    cursor: usize, 
    comptime action: anytype, 
    expected: anytype
) !void {
    const content: []const u8 = "2 + 3 * 4 + 5";
    var lexer = Lexer{ .cursor = cursor, .content = content };
    
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
        2, 
        struct {
            fn call(l: *Lexer) Operator { 
                return l.find_operator(); 
                }
            }.call, 
        Operator{.Power = 10,.Value = '+'}
    );
}

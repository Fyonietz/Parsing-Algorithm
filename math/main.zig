const std = @import("std");

// pub fn peek(content: []const u8,index : usize) ?u8{
//     if(index < content.len){
//         return content[index];
//     }else{
//         return null;
//     }
// }
//
// pub fn consume(current_position:u8,expression:[]const u8,index:*usize) void{
//     if (expression == current_position){
//         index+=1;
//     }
// }

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    //Open File
    var file_buffer: [1028]u8 = undefined;
    const dir = std.Io.Dir.cwd();
    const content = try dir.readFile(io, "math/source.txt", &file_buffer);

    //We Try Parsing 1st
    var index: usize = 0;
    var expression_found: bool = false;
    var left_text: []const u8 = undefined;
    var right_text: []const u8 = undefined;
    var left: i32 = 0;
    var right: i32 = 0;
    while (index < content.len) : (index += 1) {
        if (content[index] == '+') {
            expression_found = true;
            break;
        }
    }
    if (expression_found) {
        left_text = std.mem.trim(u8, content[0..index], " \t\n\r");
        right_text = std.mem.trim(u8, content[index + 1 ..], " \t\n\r");

        left = try std.fmt.parseInt(i32, left_text, 10);
        right = try std.fmt.parseInt(i32, right_text, 10);
        std.debug.print("The Result Is : {d}", .{left + right});
    } else {
        std.debug.print("Please Provide It", .{});
    }
}

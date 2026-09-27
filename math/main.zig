const std = @import("std");

pub fn main(init : std.process.Init) !void {
    const io = init.io;

    //Open File
    var file_buffer:[1028]u8 = undefined; 
    const dir = std.Io.Dir.cwd();
    const content = try dir.readFile(io,"math/source.txt",&file_buffer);

}



const std = @import("std");

const stdout = std.io.getStdOut().writer();
var buffered_writer = std.io.bufferedWriter(stdout);
const stdout_buf = buffered_writer.writer();

const esc = "\x1B";
const clear_str = esc ++ "[2J";
const reset_str = clear_str ++ get_move_str(1, 1); // console is 1-indexed

pub fn get_move_str(x: u8, y: u8) []const u8 {
    return esc ++ std.fmt.comptimePrint("[{d};{d}H", .{ x, y });
}

pub fn move_cursor_to(x: u8, y: u8) void {
    stdout.print(get_move_str(x, y), .{});
}

pub fn clear() void {
    stdout.print(clear_str, .{}) catch return;
}

// Buffered funcs are virtually useless if full terminal control (including "rendering")
// is not a part of this file 😭
// pub fn clear_buffered() void {
//     stdout_buf.print(clear_str, .{}) catch return;
// }

pub fn reset() void {
    stdout.print(reset_str, .{}) catch return;
}

// pub fn reset_buffered() void {
//     stdout_buf.print(reset_str, .{}) catch return;
// }

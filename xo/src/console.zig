// A simple stdout wrapper
const BUF_SIZE = 4; // Should be changed depending on use case (4096 is often used as a "gold" standard)

const std = @import("std");

pub const stdout = std.io.getStdOut().writer();
pub var buffered_writer = std.io.bufferedWriter(stdout);
pub const stdout_buf = buffered_writer.writer();

const stdin_file = std.io.getStdIn().reader();

const esc = "\x1B";
const clear_str = esc ++ "[2J";
const reset_str = clear_str ++ getMoveStr(1, 1); // console is 1-indexed

pub fn getMoveStr(x: u8, y: u8) []const u8 {
    return esc ++ std.fmt.comptimePrint("[{d};{d}H", .{ x, y });
}

pub fn moveCursorTo(x: u8, y: u8) void {
    stdout.print(getMoveStr(x, y), .{});
}

pub fn print(comptime format: []const u8, args: anytype) void {
    stdout_buf.print(format, args) catch return;
}

pub fn printUnbuf(comptime format: []const u8, args: anytype) void {
    stdout.print(format, args) catch return;
}

pub fn clearUnbuf() void {
    stdout.print(clear_str, .{}) catch return;
}

pub fn clear() void {
    stdout_buf.print(clear_str, .{}) catch return;
}

pub fn resetUnbuf() void {
    stdout.print(reset_str, .{}) catch return;
}

pub fn reset() void {
    stdout_buf.print(reset_str, .{}) catch return;
}

pub fn flush() void {
    buffered_writer.flush() catch return;
}

pub fn readUntilEoi() []u8 { // End of input: EOF or delimiter '\n'
    var buf: [4096]u8 = undefined;
    if (stdin_file.readUntilDelimiterOrEof(&buf, '\n') catch return &[0]u8{}) |val| {
        return val;
    }
    return &[0]u8{};
}

pub fn readChar() !u8 {
    const input = readUntilEoi();
    if (input.len != 1) {
        return error.WrongCharCount;
    }
    return input[0];
}

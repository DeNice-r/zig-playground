const std = @import("std");
const fmt = std.fmt.comptimePrint;

const console = @import("./console.zig");

const ESC = "\x1B[";

const FORE = 38;
const BACK: u8 = 48;

const resetRGB = ESC ++ "39;49m";

pub fn setFore(str: []const u8, color: *const [6]u8) []const u8 {
    const x = convertHexColorToRGB(color);
    return getRGB(FORE, x[0], x[1], x[2]) ++ str ++ getReset(FORE);
}

pub fn setBack(str: []const u8, color: *const [6]u8) []const u8 {
    const x = convertHexColorToRGB(color);
    return getRGB(BACK, x[0], x[1], x[2]) ++ str ++ getReset(BACK);
}

fn getReset(mode: u8) []const u8 {
    return fmt("{s}{d}m", .{ ESC, mode + 1 });
}

fn getRGB(mode: u8, r: u8, g: u8, b: u8) []const u8 {
    return fmt("{s}{d};2;{d};{d};{d}m", .{ ESC, mode, r, g, b });
}

pub fn convertHexColorToRGB(hex: *const [6]u8) []u8 { // TODO: validate the data
    var result: [3]u8 = undefined;

    for (0..3) |x| {
        result[x] = hexStrToDec(hex[x * 2]) * 16 + hexStrToDec(hex[x * 2 + 1]);
    }

    return &result;
}

// fn hexToDec () u8 {
//
// }

fn hexStrToDec(hex: u8) u8 {
    if (hex >= 'A' and hex <= 'F') {
        return hex - 'A' + 10;
    } else if (hex >= 'a' and hex <= 'f') {
        return hex - 'a' + 10;
    } else if (hex >= '0' and hex <= '9') {
        return hex - '0';
    }
    return 0;
}

const expect = std.testing.expect;

test "base16 to base10 single char" {
    try expect(hexStrToDec('0') == 0);
    try expect(hexStrToDec('1') == 1);
    try expect(hexStrToDec('2') == 2);
    try expect(hexStrToDec('3') == 3);
    try expect(hexStrToDec('4') == 4);
    try expect(hexStrToDec('5') == 5);
    try expect(hexStrToDec('6') == 6);
    try expect(hexStrToDec('7') == 7);
    try expect(hexStrToDec('8') == 8);
    try expect(hexStrToDec('9') == 9);
    try expect(hexStrToDec('A') == 10);
    try expect(hexStrToDec('a') == 10);
    try expect(hexStrToDec('B') == 11);
    try expect(hexStrToDec('b') == 11);
    try expect(hexStrToDec('C') == 12);
    try expect(hexStrToDec('c') == 12);
    try expect(hexStrToDec('D') == 13);
    try expect(hexStrToDec('d') == 13);
    try expect(hexStrToDec('E') == 14);
    try expect(hexStrToDec('e') == 14);
    try expect(hexStrToDec('F') == 15);
    try expect(hexStrToDec('f') == 15);
}

test "base16 to base10 single char malicious input" {
    // Letters, unused in base16
    try expect(hexStrToDec('g') == 0);
    try expect(hexStrToDec('h') == 0);
    try expect(hexStrToDec('y') == 0);
    try expect(hexStrToDec('z') == 0);
    try expect(hexStrToDec('G') == 0);
    try expect(hexStrToDec('H') == 0);
    try expect(hexStrToDec('Y') == 0);
    try expect(hexStrToDec('Z') == 0);
    // Values outside of letter ranges
    try expect(hexStrToDec('{') == 0);
    try expect(hexStrToDec('[') == 0);
    try expect(hexStrToDec('@') == 0);
}

// Unable to test it, but it works
// TODO: test it
// test "base16 to base10 6 char" {
//     try expect(std.mem.eql(u8, convertHexColorToRGB("000000"), &[_]u8{ 0, 0, 0 }));
//     try expect(std.mem.eql(u8, convertHexColorToRGB("000001"), &[_]u8{ 1, 0, 0 }));
//     // try expect(std.mem.eql(u8, convertHexColorToRGB("FFFFFF"), &[_]u8{ 255, 255, 255 }));
//     // try expect(std.mem.eql(u8, convertHexColorToRGB("3a4b5c"), &[_]u8{ 58, 75, 92 }));
// }

const std = @import("std");
const console = @import("./console.zig");

pub fn main() !void {
    const game = Game();
    game.loop();
    console.flush();
}

fn Game() type {
    return struct {
        const Field = enum {
            Free,
            X,
            O,

            fn to_string(self: Field) u8 {
                return switch (self) {
                    .Free => ' ',
                    .X => 'X',
                    .O => 'O',
                };
            }
        };
        const State = enum {
            Ongoing,
            XWon,
            OWon,
            Draw,

            fn to_string(self: State) u8 {
                return switch (self) {
                    .XWon => 'X',
                    .OWon => 'O',
                    else => 'E',
                };
            }
        };
        const MoveError = error{
            LessThanZero,
            MoreThanLen,
            CantUnset,
            AlreadySet,
        };

        var map = [_][3]Field{[_]Field{Field.Free} ** 3} ** 3;
        var move_count: u8 = 0;

        pub fn loop() void {
            var state = get_state();
            console.clear();

            while (state == State.Ongoing) {
                print();
                var choice: u8 = console.readChar();

                if (choice < '1' or choice > '9') {
                    continue;
                }
                choice -= '0' + 1; // input is 1-based
                move(choice / 3, choice % 3, if (move_count % 2 == 0) Field.X else Field.O) catch continue;
                print();

                state = get_state();
            }

            console.clear();
            if (state == State.Draw) {
                console.print("The power of friendship (or flawness of the game) won!", .{});
            } else {
                console.print("{c} won!", .{state.to_string()});
            }
        }

        fn get_winning_state(side: Field) State {
            return switch (side) {
                .X => State.XWon,
                .O => State.OWon,
                else => State.Ongoing, // Never gonna be executed, but is still required by the zig compiler
            };
        }

        fn is_free(field: Field) bool {
            return field == Field.Free;
        }

        fn is_ended(a: Field, b: Field, c: Field) bool {
            return a == b and b == c and !is_free(a);
        }

        fn get_state() State {
            if (move_count < 5) {
                return State.Ongoing;
            }

            for (0..map.len) |x_index| {
                if (is_ended(map[x_index][0], map[x_index][1], map[x_index][2])) {
                    return get_winning_state(map[x_index][0]);
                }
            }

            for (0..map[0].len) |y_index| {
                if (is_ended(map[0][y_index], map[1][y_index], map[2][y_index])) {
                    return get_winning_state(map[0][y_index]);
                }
            }

            if (is_ended(map[0][0], map[1][1], map[2][2])) {
                return get_winning_state(map[0][0]);
            }

            if (is_ended(map[2][0], map[1][1], map[0][2])) {
                return get_winning_state(map[2][0]);
            }

            if (move_count == 9) {
                return State.Draw;
            }
            return State.Ongoing;
        }

        fn move(x: u8, y: u8, side: Field) !void {
            if (x > map.len or y > map[x].len) {
                return MoveError.MoreThanLen;
            } else if (x < 0 or y < 0) {
                return MoveError.LessThanZero;
            } else if (side == Field.Free) {
                return MoveError.CantUnset;
            } else if (!is_free(map[x][y])) {
                return MoveError.AlreadySet;
            }
            map[x][y] = side;
            move_count += 1;
        }

        fn print() void {
            console.reset();
            for (map, 0..) |x, x_index| {
                for (x, 1..) |y, y_index| {
                    if (is_free(y)) {
                        console.print("{} ", .{x_index * 3 + y_index});
                    } else {
                        console.print("{c} ", .{y.to_string()});
                    }
                }
                console.print("\n", .{});
            }
            console.flush();
        }
    };
}

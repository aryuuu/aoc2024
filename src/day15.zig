const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day15.txt");
    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    var grid = std.ArrayList(std.ArrayList(Cell)).init(allocator);
    var movements = std.ArrayList(Direction).init(allocator);
    defer {
        for (grid.items) |row| {
            row.deinit();
        }
        grid.deinit();
        movements.deinit();
    }
    var robot_pos = Point{ .x = 0, .y = 0 };

    var buf: [1024]u8 = undefined;
    // parse the map
    var i: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            break;
        }

        var row = std.ArrayList(Cell).init(allocator);
        for (line[0 .. line.len], 0..) |char, j| {
            switch (char) {
                '#' => try row.append(Cell.wall),
                '@' => {
                    try row.append(Cell.bot);
                    robot_pos.x = j;
                    robot_pos.y = i;
                },
                'O' => try row.append(Cell.box),
                '.' => try row.append(Cell.empty),
                else => {
                    std.debug.print("got {c} wtf\n", .{char});
                    unreachable;
                },
            }
        }
        try grid.append(row);
        i += 1;
    }

    // parse bot movement
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |char| {
            switch (char) {
                '^' => try movements.append(Direction.up),
                '>' => try movements.append(Direction.right),
                'v' => try movements.append(Direction.down),
                '<' => try movements.append(Direction.left),
                '\n' => break,
                else => unreachable,
            }
        }
    }

    var result: usize = 0;
    outer: for (movements.items) |m| {
        switch (m) {
            // here's what we are going to do
            // move towards the direction until we found an empty space or a wall
            // if it is a wall do nothing
            // if it is an empty space do the following:
            // - put boxes starting from where the empty place is found up to 2 cells before the bot position
            // - put bot on the next cell in the direction of the movement
            // - remove bot from the original cell
            // - update the bot pos obj
            Direction.up => {
                var py = robot_pos.y;
                while (py > 0) {
                    py -= 1;
                    const cell = grid.items[py].items[robot_pos.x];
                    switch (cell) {
                        Cell.wall => continue :outer,
                        Cell.empty => break,
                        else => continue,
                    }
                }

                for (py..robot_pos.y) |y| {
                    grid.items[y].items[robot_pos.x] = Cell.box;
                }
                robot_pos.y -= 1;
                grid.items[robot_pos.y].items[robot_pos.x] = Cell.bot;
                grid.items[robot_pos.y+1].items[robot_pos.x] = Cell.empty;
            },
            Direction.down => {
                var py = robot_pos.y;
                while (py < grid.items.len - 1) {
                    py += 1;
                    const cell = grid.items[py].items[robot_pos.x];
                    switch (cell) {
                        Cell.wall => continue :outer,
                        Cell.empty => break,
                        else => continue,
                    }
                }

                for (robot_pos.y.. py) |y| {
                    grid.items[y+1].items[robot_pos.x] = Cell.box;
                }
                robot_pos.y += 1;
                grid.items[robot_pos.y].items[robot_pos.x] = Cell.bot;
                grid.items[robot_pos.y-1].items[robot_pos.x] = Cell.empty;
            },
            Direction.left => {
                var px = robot_pos.x;
                while (px > 0) {
                    px -= 1;
                    const cell = grid.items[robot_pos.y].items[px];
                    switch (cell) {
                        Cell.wall => continue :outer,
                        Cell.empty => break,
                        else => continue,
                    }
                }

                for (px..robot_pos.x) |x| {
                    grid.items[robot_pos.y].items[x] = Cell.box;
                }
                robot_pos.x -= 1;
                grid.items[robot_pos.y].items[robot_pos.x] = Cell.bot;
                grid.items[robot_pos.y].items[robot_pos.x+1] = Cell.empty;
            },
            Direction.right => {
                var px = robot_pos.x;
                while (px < grid.items[0].items.len - 1) {
                    px += 1;
                    const cell = grid.items[robot_pos.y].items[px];
                    switch (cell) {
                        Cell.wall => continue :outer,
                        Cell.empty => break,
                        else => continue,
                    }
                }

                for (robot_pos.x.. px) |x| {
                    grid.items[robot_pos.y].items[x+1] = Cell.box;
                }
                robot_pos.x += 1;
                grid.items[robot_pos.y].items[robot_pos.x] = Cell.bot;
                grid.items[robot_pos.y].items[robot_pos.x-1] = Cell.empty;
            },
        }

        // std.debug.print("{}\n", .{m});
        // for (0..grid.items.len) |fy| {
        //     for (0..grid.items[fy].items.len) |fx| {
        //         switch (grid.items[fy].items[fx]) {
        //             Cell.box => std.debug.print("O", .{}),
        //             Cell.wall => std.debug.print("#", .{}),
        //             Cell.bot => std.debug.print("@", .{}),
        //             Cell.empty => std.debug.print(".", .{}),
        //         }
        //     }
        //     std.debug.print("\n", .{});
        // }
        // std.debug.print("\n", .{});
    }

    // for (0..grid.items.len) |fy| {
    //     for (0..grid.items[fy].items.len) |fx| {
    //         switch (grid.items[fy].items[fx]) {
    //             Cell.box => std.debug.print("O", .{}),
    //             Cell.wall => std.debug.print("#", .{}),
    //             Cell.bot => std.debug.print("@", .{}),
    //             Cell.empty => std.debug.print(".", .{}),
    //         }
    //     }
    //     std.debug.print("\n", .{});
    // }
    // std.debug.print("\n", .{});

    for (0..grid.items.len) |y| {
        for (0..grid.items[y].items.len) |x| {
            switch (grid.items[y].items[x]) {
                Cell.box => result += x + 100 * y,
                else => {},
            }
        }
    }
    return result;
}

const Point = struct { x: usize, y: usize };

const Cell = enum { wall, bot, box, empty };
const Direction = enum { up, down, left, right };

test "part 1" {
    std.debug.print("test part 1\n", .{});
    const allocator = std.testing.allocator;

    const result = try part1(allocator, "./input/day15.test.txt");
    try std.testing.expectEqual(2028, result);
}

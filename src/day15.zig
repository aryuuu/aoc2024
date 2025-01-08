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
    var robot_pos = Point{.x=0, .y=0};

    var buf: [1024]u8 = undefined;
    // parse the map
    var i: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 1) {
            break;
        }

        var row = std.ArrayList(Cell).init(allocator);
        for (line[0..line.len-1], 0..) |char, j| {
            switch (char) {
                '#' => try row.append(Cell.wall),
                '@' => {
                    try row.append(Cell.bot); 
                    robot_pos.x = j;
                    robot_pos.y = i;
                },
                '0' => try row.append(Cell.box),
                '.' => try row.append(Cell.empty),
                else => unreachable,
            }
        }
        try grid.append(row);
        i += 1;
    }

    // parse ke bot movement
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
    for (movements.items) |m| {
        switch (m) {
            // robot can move if there's an empty space between it and the wall
            // start from the bot position, and move up until we met either an empty space or a wall
            // if it is a wall then do nothing
            // if it is a box then shift everything from the bot starting point into the empty space, boxes included
            Direction.up => {
                var y = robot_pos.y;
                var end_y: ?usize = null;
                while (y >= 0) {
                    const cell = grid.items[y].items[robot_pos.x];
                    switch (cell) {
                        Cell.wall => break,
                        Cell.empty => end_y = y,
                        else => y -= 1,
                    }

                    if (end_y) |val| {
                        // let's do a circular shift
                        // here's what i mean by that
                        // before the shift
                        // 1 2 3 4 5
                        // after the shift
                        // 5 1 2 3 4
                        const circ_size: usize = val - y;
                        const base_offset: usize = y;

                        for (y..val) |idx| {
                            const next_y: usize = ((idx - y + 1) % circ_size) + base_offset;
                            grid.items[next_y].items[robot_pos.x] = grid.items[idx].items[robot_pos.x];
                        }
                    }
                }
            },
            Direction.down => {
                var y = robot_pos.y;
                var end_y: ?usize = null;
                while (y < grid.items.len) {
                    const cell = grid.items[y].items[robot_pos.x];
                    switch (cell) {
                        Cell.wall => break,
                        Cell.empty => end_y = y,
                        else => y += 1,
                    }

                    if (end_y) |val| {
                        const circ_size: usize = y - val;
                        const base_offset: usize = val;

                        for (val..y) |idx| {
                            const next_y: usize = ((idx - y + 1) % circ_size) + base_offset;
                            grid.items[next_y].items[robot_pos.x] = grid.items[idx].items[robot_pos.x];
                        }
                    }
                }
            },
        }
    }

    for (0..grid.items.len) |y| {
        for (0..grid.items[y].items.len) |x| {
            switch (grid.items[i].items[x]) {
                Cell.box => result += x * y,
                else => {},
            }
        }
    }
    return result;
}

const Point = struct {x: usize, y: usize};

const Cell = enum {wall, bot, box, empty};
const Direction = enum {up, down, left, right};

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day15.test.txt");
    try std.testing.expectEqual(10092, result);
}

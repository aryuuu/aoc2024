const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day6.txt");
    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var grid = std.ArrayList(std.ArrayList(Cell)).init(allocator);
    defer {
        for (grid.items) |row| {
            row.deinit();
        }

        grid.deinit();
    }

    var guard = Guard{
        .row = 0,
        .col = 0,
        .direction = GuardDirection.up,
        .distinct_visited_count = 1,
    };
    var i: usize = 0;
    var buf: [140]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var row = std.ArrayList(Cell).init(allocator);
        var j: usize = 0;
        for (line) |char| {
            if (char == '.') {
                try row.append(Cell.path);
            } else if (char == '#') {
                try row.append(Cell.obstacle);
            } else if (char == '^') {
                try row.append(Cell.guard_start);
                guard.row = i;
                guard.col = j;
            }
            j += 1;
        }
        i += 1;
        try grid.append(row);
    }

    while (true) {
        switch (guard.direction) {
            GuardDirection.up => {
                if (guard.row == 0) {
                    break;
                }
                if (grid.items[guard.row - 1].items[guard.col] != Cell.obstacle) {
                    guard.row -= 1;
                } else {
                    guard.direction = GuardDirection.right;
                }
            },
            GuardDirection.down => {
                if (guard.row == grid.items.len - 1) {
                    break;
                }
                if (grid.items[guard.row + 1].items[guard.col] != Cell.obstacle) {
                    guard.row += 1;
                } else {
                    guard.direction = GuardDirection.left;
                }
            },
            GuardDirection.right => {
                if (guard.col == grid.items[0].items.len - 1) {
                    break;
                }
                if (grid.items[guard.row].items[guard.col + 1] != Cell.obstacle) {
                    guard.col += 1;
                } else {
                    guard.direction = GuardDirection.down;
                }
            },
            GuardDirection.left => {
                if (guard.col == 0) {
                    break;
                }
                if (grid.items[guard.row].items[guard.col - 1] != Cell.obstacle) {
                    guard.col -= 1;
                } else {
                    guard.direction = GuardDirection.up;
                }
            },
        }

        if (grid.items[guard.row].items[guard.col] == Cell.path) {
            guard.distinct_visited_count += 1;
        }
        grid.items[guard.row].items[guard.col] = Cell.visited;
    }

    return guard.distinct_visited_count;
}

const Cell = enum {
    obstacle,
    guard_start,
    path,
    visited,
};

const Guard = struct {
    row: usize,
    col: usize,
    direction: GuardDirection,
    distinct_visited_count: usize,
};

const GuardDirection = enum {
    up,
    down,
    right,
    left,
};

test "part1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day6.test.txt");
    try std.testing.expectEqual(41, result);
}

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const should_run_part_2 = for (args[1..]) |arg| {
        if (std.mem.eql(u8, arg, "part2")) break true;
    } else false;

    var result: usize = 0;
    if (should_run_part_2) {
        result = try part2(allocator, "./input/day8.txt");
    } else {
        result = try part1(allocator, "./input/day8.txt");
    }

    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    // map freq -> [positions]
    // set/map for antinode positions
    var pos_map = std.AutoHashMap(u8, std.ArrayList(Point)).init(allocator);
    var antinodes_map = std.AutoHashMap(Point, u1).init(allocator);
    defer {
        var iter = pos_map.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        pos_map.deinit();

        antinodes_map.deinit();
    }

    // grid bounds
    var grid_height: i8 = 0;
    var grid_width: i8 = 0;

    var buf: [60]u8 = undefined;
    // the input is only 50x50, so safe to assume there will be no overflow
    var i: i8 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var j: i8 = 0;
        for (line) |char| {
            switch (char) {
                'a'...'z', 'A'...'Z', '0'...'9' => {
                    if (pos_map.getPtr(char)) |pos_list| {
                        try pos_list.*.append(Point{ .x = j, .y = i });
                    } else {
                        var new_list = std.ArrayList(Point).init(allocator);
                        try new_list.append(Point{ .x = j, .y = i });
                        try pos_map.put(char, new_list);
                    }
                },
                else => {},
            }
            j += 1;
        }
        grid_width = j;
        i += 1;
    }
    grid_height = i;

    var pos_iter = pos_map.iterator();
    while (pos_iter.next()) |entry| {
        const pos_list = entry.value_ptr.items;
        for (pos_list, 0..) |val, idx| {
            for (idx + 1..pos_list.len) |jdx| {
                const other_antenna = pos_list[jdx];
                const x_diff = val.x - other_antenna.x;
                const y_diff = val.y - other_antenna.y;

                const an_1 = Point{
                    .x = val.x + x_diff,
                    .y = val.y + y_diff,
                };
                if (an_1.isInBound(grid_height, grid_width)) {
                    try antinodes_map.put(an_1, 1);
                }

                const an_2 = Point{
                    .x = other_antenna.x - x_diff,
                    .y = other_antenna.y - y_diff,
                };
                if (an_2.isInBound(grid_height, grid_width)) {
                    try antinodes_map.put(an_2, 1);
                }
            }
        }
    }

    return antinodes_map.count();
}

fn part2(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    // map freq -> [positions]
    // set/map for antinode positions
    var pos_map = std.AutoHashMap(u8, std.ArrayList(Point)).init(allocator);
    var antinodes_map = std.AutoHashMap(Point, u1).init(allocator);
    defer {
        var iter = pos_map.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        pos_map.deinit();

        antinodes_map.deinit();
    }

    // grid bounds
    var grid_height: i8 = 0;
    var grid_width: i8 = 0;

    var buf: [60]u8 = undefined;
    // the input is only 50x50, so safe to assume there will be no overflow
    var i: i8 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var j: i8 = 0;
        for (line) |char| {
            switch (char) {
                'a'...'z', 'A'...'Z', '0'...'9' => {
                    if (pos_map.getPtr(char)) |pos_list| {
                        try pos_list.*.append(Point{ .x = j, .y = i });
                    } else {
                        var new_list = std.ArrayList(Point).init(allocator);
                        try new_list.append(Point{ .x = j, .y = i });
                        try pos_map.put(char, new_list);
                    }
                },
                else => {},
            }
            j += 1;
        }
        grid_width = j;
        i += 1;
    }
    grid_height = i;

    var pos_iter = pos_map.iterator();
    while (pos_iter.next()) |entry| {
        const pos_list = entry.value_ptr.items;
        for (pos_list, 0..) |val, idx| {
            for (idx + 1..pos_list.len) |jdx| {
                const other_antenna = pos_list[jdx];
                try antinodes_map.put(val, 1);
                try antinodes_map.put(other_antenna, 1);
                const x_diff = val.x - other_antenna.x;
                const y_diff = val.y - other_antenna.y;

                var an_1 = Point{
                    .x = val.x + x_diff,
                    .y = val.y + y_diff,
                };
                while (an_1.isInBound(grid_height, grid_width)) {
                    try antinodes_map.put(an_1, 1);
                    an_1.x += x_diff;
                    an_1.y += y_diff;
                }

                var an_2 = Point{
                    .x = other_antenna.x - x_diff,
                    .y = other_antenna.y - y_diff,
                };
                while (an_2.isInBound(grid_height, grid_width)) {
                    try antinodes_map.put(an_2, 1);
                    an_2.x -= x_diff;
                    an_2.y -= y_diff;
                }
            }
        }
    }

    return antinodes_map.count();
}

const Point = struct {
    x: i8,
    y: i8,

    pub fn isInBound(self: Point, height: i8, width: i8) bool {
        return (self.x >= 0) and (self.y >= 0) and (self.x < width) and (self.y < height);
    }
};

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day8.test.txt");
    try std.testing.expectEqual(14, result);
}

test "part 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part2(allocator, "./input/day8.test.txt");
    try std.testing.expectEqual(34, result);
}

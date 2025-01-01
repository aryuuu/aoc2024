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
        result = try part2(allocator, "./input/day12.txt");
    } else {
        result = try part1(allocator, "./input/day12.txt");
    }

    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    var grid = std.ArrayList(std.ArrayList(Garden)).init(allocator);
    defer {
        for (grid.items) |row| {
            row.deinit();
        }

        grid.deinit();
    }

    var buff: [200]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buff, '\n')) |line| {
        var row = std.ArrayList(Garden).init(allocator);
        for (line) |char| {
            if (char == '\n') {
                break;
            }
            try row.append(Garden{ .crop = char, .is_visited = false });
        }
        try grid.append(row);
    }

    var total: usize = 0;
    for (grid.items, 0..) |row, i| {
        for (row.items, 0..) |garden, j| {
            if (garden.is_visited) {
                continue;
            }

            const curr_crop = garden.crop;
            var area: usize = 0;
            var perimeter: usize = 0;
            var queue = std.ArrayList(Point).init(allocator);
            defer queue.deinit();

            try queue.append(Point{ .x = j, .y = i });
            while (queue.items.len > 0) {
                const curr_point = queue.orderedRemove(0);
                const curr_x = curr_point.x;
                const curr_y = curr_point.y;
                grid.items[curr_y].items[curr_x].is_visited = true;
                area += 1;

                // up
                if (curr_y > 0) {
                    const next_garden = grid.items[curr_y - 1].items[curr_x];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y - 1].items[curr_x].is_visited = true;
                        try queue.append(Point{ .x = curr_x, .y = curr_y - 1 });
                    } else if (next_garden.crop != curr_crop) {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }

                // down
                if (curr_y < grid.items.len - 1) {
                    const next_garden = grid.items[curr_y + 1].items[curr_x];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y + 1].items[curr_x].is_visited = true;
                        try queue.append(Point{ .x = curr_x, .y = curr_y + 1 });
                    } else if (next_garden.crop != curr_crop) {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }

                // right
                if (curr_x < grid.items.len - 1) {
                    const next_garden = grid.items[curr_y].items[curr_x + 1];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y].items[curr_x + 1].is_visited = true;
                        try queue.append(Point{ .x = curr_x + 1, .y = curr_y });
                    } else if (next_garden.crop != curr_crop) {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }
                // left
                if (curr_x > 0) {
                    const next_garden = grid.items[curr_y].items[curr_x - 1];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y].items[curr_x - 1].is_visited = true;
                        try queue.append(Point{ .x = curr_x - 1, .y = curr_y });
                    } else if (next_garden.crop != curr_crop) {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }
            }
            total += area * perimeter;
        }
    }

    return total;
}

fn part2(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();

    var grid = std.ArrayList(std.ArrayList(Garden)).init(allocator);
    defer {
        for (grid.items) |row| {
            row.deinit();
        }

        grid.deinit();
    }

    var buff: [200]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buff, '\n')) |line| {
        var row = std.ArrayList(Garden).init(allocator);
        for (line) |char| {
            if (char == '\n') {
                break;
            }
            try row.append(Garden{ .crop = char, .is_visited = false });
        }
        try grid.append(row);
    }

    var total: usize = 0;
    for (grid.items, 0..) |row, i| {
        for (row.items, 0..) |garden, j| {
            if (garden.is_visited) {
                continue;
            }

            const curr_crop = garden.crop;
            var area: usize = 0;
            var queue = std.ArrayList(Point).init(allocator);
            defer queue.deinit();

            var left_sides = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
            var right_sides = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
            var up_sides = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
            var down_sides = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
            defer {
                var l_iter = left_sides.iterator();
                while (l_iter.next()) |entry| {
                    entry.value_ptr.*.deinit();
                }
                left_sides.deinit();
                var r_iter = right_sides.iterator();
                while (r_iter.next()) |entry| {
                    entry.value_ptr.*.deinit();
                }
                right_sides.deinit();
                var u_iter = up_sides.iterator();
                while (u_iter.next()) |entry| {
                    entry.value_ptr.*.deinit();
                }
                up_sides.deinit();
                var d_iter = down_sides.iterator();
                while (d_iter.next()) |entry| {
                    entry.value_ptr.*.deinit();
                }
                down_sides.deinit();
            }

            try queue.append(Point{ .x = j, .y = i });
            while (queue.items.len > 0) {
                const curr_point = queue.orderedRemove(0);
                const curr_x = curr_point.x;
                const curr_y = curr_point.y;
                grid.items[curr_y].items[curr_x].is_visited = true;
                area += 1;

                // up
                if (curr_y > 0) {
                    const next_garden = grid.items[curr_y - 1].items[curr_x];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y - 1].items[curr_x].is_visited = true;
                        try queue.append(Point{ .x = curr_x, .y = curr_y - 1 });
                    } else if (next_garden.crop != curr_crop) {
                        if (up_sides.getPtr(curr_y)) |val| {
                            try val.append(curr_x);
                        } else {
                            var new_arr = std.ArrayList(usize).init(allocator);
                            try new_arr.append(curr_x);
                            try up_sides.put(curr_y, new_arr);
                        }
                    }
                } else {
                    if (up_sides.getPtr(curr_y)) |val| {
                        try val.append(curr_x);
                    } else {
                        var new_arr = std.ArrayList(usize).init(allocator);
                        try new_arr.append(curr_x);
                        try up_sides.put(curr_y, new_arr);
                    }
                }

                // down
                if (curr_y < grid.items.len - 1) {
                    const next_garden = grid.items[curr_y + 1].items[curr_x];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y + 1].items[curr_x].is_visited = true;
                        try queue.append(Point{ .x = curr_x, .y = curr_y + 1 });
                    } else if (next_garden.crop != curr_crop) {
                        if (down_sides.getPtr(curr_y)) |val| {
                            try val.append(curr_x);
                        } else {
                            var new_arr = std.ArrayList(usize).init(allocator);
                            try new_arr.append(curr_x);
                            try down_sides.put(curr_y, new_arr);
                        }
                    }
                } else {
                    if (down_sides.getPtr(curr_y)) |val| {
                        try val.append(curr_x);
                    } else {
                        var new_arr = std.ArrayList(usize).init(allocator);
                        try new_arr.append(curr_x);
                        try down_sides.put(curr_y, new_arr);
                    }
                }

                // right
                if (curr_x < grid.items.len - 1) {
                    const next_garden = grid.items[curr_y].items[curr_x + 1];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y].items[curr_x + 1].is_visited = true;
                        try queue.append(Point{ .x = curr_x + 1, .y = curr_y });
                    } else if (next_garden.crop != curr_crop) {
                        if (right_sides.getPtr(curr_x)) |val| {
                            try val.append(curr_y);
                        } else {
                            var new_arr = std.ArrayList(usize).init(allocator);
                            try new_arr.append(curr_y);
                            try right_sides.put(curr_x, new_arr);
                        }
                    }
                } else {
                    if (right_sides.getPtr(curr_x)) |val| {
                        try val.append(curr_y);
                    } else {
                        var new_arr = std.ArrayList(usize).init(allocator);
                        try new_arr.append(curr_y);
                        try right_sides.put(curr_x, new_arr);
                    }
                }
                // left
                if (curr_x > 0) {
                    const next_garden = grid.items[curr_y].items[curr_x - 1];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y].items[curr_x - 1].is_visited = true;
                        try queue.append(Point{ .x = curr_x - 1, .y = curr_y });
                    } else if (next_garden.crop != curr_crop) {
                        if (left_sides.getPtr(curr_x)) |val| {
                            try val.append(curr_y);
                        } else {
                            var new_arr = std.ArrayList(usize).init(allocator);
                            try new_arr.append(curr_y);
                            try left_sides.put(curr_x, new_arr);
                        }
                    }
                } else {
                    if (left_sides.getPtr(curr_x)) |val| {
                        try val.append(curr_y);
                    } else {
                        var new_arr = std.ArrayList(usize).init(allocator);
                        try new_arr.append(curr_y);
                        try left_sides.put(curr_x, new_arr);
                    }
                }
            }

            var sides: usize = 0;
            // up
            {
                var iter = up_sides.iterator();
                while (iter.next()) |e| {
                    const arr = e.value_ptr.*;
                    std.mem.sort(usize, arr.items, {}, std.sort.asc(usize));
                    sides += 1;

                    for (0..arr.items.len-1) |idx| {
                        const curr = arr.items[idx];
                        const next = arr.items[idx+1];
                        if (next != curr+1) {
                            sides += 1;
                        }
                    }
                }
            }
            // bottom
            {
                var iter = down_sides.iterator();
                while (iter.next()) |e| {
                    const arr = e.value_ptr.*;
                    std.mem.sort(usize, arr.items, {}, std.sort.asc(usize));
                    sides += 1;
                    for (0..arr.items.len-1) |idx| {
                        const curr = arr.items[idx];
                        const next = arr.items[idx+1];
                        if (next != curr+1) {
                            sides += 1;
                        }
                    }
                }
            }
            // right
            {
                var iter = right_sides.iterator();
                while (iter.next()) |e| {
                    sides += 1;
                    const arr = e.value_ptr.*;
                    std.mem.sort(usize, arr.items, {}, std.sort.asc(usize));

                    for (0..arr.items.len-1) |idx| {
                        const curr = arr.items[idx];
                        const next = arr.items[idx+1];
                        if (next != curr+1) {
                            sides += 1;
                        }
                    }
                }
            }
            // left
            {
                var iter = left_sides.iterator();
                while (iter.next()) |e| {
                    sides += 1;
                    const arr = e.value_ptr.*;
                    std.mem.sort(usize, arr.items, {}, std.sort.asc(usize));

                    for (0..arr.items.len-1) |idx| {
                        const curr = arr.items[idx];
                        const next = arr.items[idx+1];
                        if (next != curr + 1) {
                            sides += 1;
                        }
                    }
                }
            }

            total += area * sides;
        }
    }

    return total;
}

fn compUsize(context: void, a: usize, b: usize) bool {
    _ = context;
    return a < b;
}

const Point = struct {
    x: usize,
    y: usize,
};

const Garden = struct {
    crop: u8,
    is_visited: bool,
};

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day12.test.txt");
    try std.testing.expectEqual(1930, result);
}

test "part 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part2(allocator, "./input/day12.test.txt");
    try std.testing.expectEqual(1206, result);
}

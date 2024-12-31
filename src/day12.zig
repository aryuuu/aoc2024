const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day12.txt");
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

            try queue.append(Point{.x=j, .y=i});
            while (queue.items.len > 0) {
                const curr_point = queue.orderedRemove(0);
                const curr_x = curr_point.x;
                const curr_y = curr_point.y;
                grid.items[curr_y].items[curr_x].is_visited = true;
                area += 1;

                // up
                if (curr_y > 0) {
                    const next_garden = grid.items[curr_y-1].items[curr_x];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y-1].items[curr_x].is_visited = true;
                        try queue.append(Point{.x=curr_x, .y=curr_y-1});
                    } else if (next_garden.crop != curr_crop) {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }

                // down
                if (curr_y < grid.items.len - 1) {
                    const next_garden = grid.items[curr_y+1].items[curr_x];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y+1].items[curr_x].is_visited = true;
                        try queue.append(Point{.x=curr_x, .y=curr_y+1});
                    } else if (next_garden.crop != curr_crop) {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }

                // right
                if (curr_x < grid.items.len - 1) {
                    const next_garden = grid.items[curr_y].items[curr_x+1];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y].items[curr_x+1].is_visited = true;
                        try queue.append(Point{.x=curr_x+1, .y=curr_y});
                    } else if (next_garden.crop != curr_crop) {
                        perimeter += 1;
                    }
                } else {
                    perimeter += 1;
                }
                // left
                if (curr_x > 0) {
                    const next_garden = grid.items[curr_y].items[curr_x-1];
                    if (next_garden.crop == curr_crop and !next_garden.is_visited) {
                        grid.items[curr_y].items[curr_x-1].is_visited = true;
                        try queue.append(Point{.x=curr_x-1, .y=curr_y});
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

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    
    const result = try part1(allocator, "./input/day10.txt");
    std.debug.print("result: {d}\n", .{result});
}


fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var reader_buffer = std.io.bufferedReader(file.reader());
    var reader = reader_buffer.reader();

    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer {
        for (grid.items) |row| {
            row.deinit();
        }

        grid.deinit();
    }

    var buf: [50]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var row = std.ArrayList(u8).init(allocator);
        for (line) |char| {
            if (char < '0' or char > '9') {
                break;
            }

            const num = char - '0';
            try row.append(num);
        }
        try grid.append(row);
    }

    // set of trails, key is start-end point, val is bool
    var trailMap = std.AutoHashMap(Trail, bool).init(allocator);
    defer trailMap.deinit();

    for (grid.items, 0..) |row, i| {
        for (row.items, 0..) |val, j| {
            if (val == 0) {
                var points = std.ArrayList(Point).init(allocator);
                defer points.deinit();
                const initial_point = Point{.x=j, .y=i};
                try points.append(Point{.x=j, .y=i});
                // start the search here?
                while (points.items.len != 0) {
                    // the length is > 0, so we can safely use .orderedRemove
                    const curr_point = points.orderedRemove(0);
                    const curr_val = grid.items[curr_point.y].items[curr_point.x];
                    const curr_x = curr_point.x;
                    const curr_y = curr_point.y;

                    if (curr_val == 9) {
                        try trailMap.put(Trail{.start=initial_point, .finish=curr_point}, true);
                    }

                    // up
                    if (curr_point.y > 0 and grid.items[curr_y - 1].items[curr_x] == curr_val + 1) {
                        try points.append(Point{.x=curr_x, .y=curr_y-1});
                    }

                    // down
                    if (curr_point.y < grid.items.len - 1 and grid.items[curr_y + 1].items[curr_x] == curr_val + 1) {
                        try points.append(Point{.x=curr_x, .y=curr_y+1});
                    }

                    // right
                    if (curr_point.x < grid.items[0].items.len - 1 and grid.items[curr_y].items[curr_x + 1] == curr_val + 1) {
                        try points.append(Point{.x=curr_x+1, .y=curr_y});
                    }

                    // left
                    if (curr_point.x > 0 and grid.items[curr_y].items[curr_x - 1] == curr_val + 1) {
                        try points.append(Point{.x=curr_x - 1, .y=curr_y});
                    }

                }
            }
        }

    }

    return trailMap.count();

}

const Point = struct {
    x: usize,
    y: usize,
};

const Trail = struct {
    start: Point,
    finish: Point,
};

test "part 1" { 
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day10.test.txt");
    try std.testing.expectEqual(36, result);
}

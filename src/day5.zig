const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day5.txt");
    std.debug.print("result: {}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var order_map = std.AutoHashMap(u8, std.AutoHashMap(u8, RelativePos)).init(allocator);
    defer {
        var iter = order_map.iterator();
        while (iter.next()) |val| {
            val.value_ptr.*.deinit();
        }

        order_map.deinit();
    }

    var buf: [150]u8 = undefined;
    // build the map
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            break;
        }

        var iter = std.mem.splitScalar(u8, line, '|');
        var first: u8 = undefined;
        var second: u8 = undefined;
        if (iter.next()) |val| {
            const num = try std.fmt.parseUnsigned(u8, val, 10);
            first = num;
        }
        if (iter.next()) |val| {
            const num = try std.fmt.parseUnsigned(u8, val, 10);
            second = num;
        }

        if (order_map.getPtr(first)) |val| {
            try val.*.put(second, RelativePos.after);
        } else {
            var new_map = std.AutoHashMap(u8, RelativePos).init(allocator);
            try new_map.put(second, RelativePos.after);
            try order_map.put(first, new_map);
        }

        if (order_map.getPtr(second)) |val| {
            try val.*.put(first, RelativePos.before);
        } else {
            var new_map = std.AutoHashMap(u8, RelativePos).init(allocator);
            try new_map.put(first, RelativePos.before);
            try order_map.put(second, new_map);
        }
    }

    var total: usize = 0;
    // check the actual ordering
    var line_num: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        line_num += 1;
        const pages = try parseLine(allocator, line);
        defer allocator.free(pages);
        var is_good = true;

        outer_loop: for (0..pages.len) |i| {
            // afters
            if (i < pages.len - 1) {
                for (i..pages.len - 1) |j| {
                    if (order_map.get(pages[i])) |outer| {
                        if (outer.get(pages[j + 1])) |inner| {
                            if (inner != RelativePos.after) {
                                is_good = false;
                                break :outer_loop;
                            }
                        }
                    }
                }
            }
            // befores
            if (i > 0) {
                for (0..i) |j| {
                    if (order_map.get(pages[i])) |outer| {
                        if (outer.get(pages[i - j - 1])) |inner| {
                            if (inner != RelativePos.before) {
                                is_good = false;
                                break :outer_loop;
                            }
                        }
                    }
                }
            }
        }

        if (is_good) {
            const mid_idx = pages.len / 2;
            total += pages[mid_idx];
        }
    }

    return total;
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();

    var iterator = std.mem.splitScalar(u8, line, ',');

    while (iterator.next()) |val| {
        const num = try std.fmt.parseUnsigned(u8, val, 10);
        try result.append(num);
    }

    return result.toOwnedSlice();
}

const RelativePos = enum {
    before,
    after,
};

test "part1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const result = try part1(allocator, "./input/day5.test.txt");
    try std.testing.expectEqual(@as(i32, 143), result);
}

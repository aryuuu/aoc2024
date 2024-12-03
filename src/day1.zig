const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("./input/day1.txt", .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var arr_1 = std.ArrayList(i32).init(allocator);
    defer arr_1.deinit();
    var arr_2 = std.ArrayList(i32).init(allocator);
    defer arr_2.deinit();
    var buf: [20]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iterator = std.mem.splitScalar(u8, line, ' ');

        if (iterator.next()) |first| {
            const num = try std.fmt.parseInt(i32, first, 10);
            try arr_1.append(num);
        }

        while (iterator.next()) |second| {
            if (second.len == 0) {
                continue;
            }
            const num = try std.fmt.parseInt(i32, second, 10);
            try arr_2.append(num);
        }
    }

    std.mem.sort(i32, arr_1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, arr_2.items, {}, comptime std.sort.asc(i32));

    var total: u64 = 0;
    for (arr_1.items, arr_2.items) |val_1, val_2| {
        total += @abs(val_1 - val_2);
    }

    std.debug.print("total {d}\n", .{total});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

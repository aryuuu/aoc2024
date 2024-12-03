const std = @import("std");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();
    // defer gpa.deinit();

    const file = try std.fs.cwd().openFile("./input/day2.txt", .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    try part1(&reader);
}

fn part1(reader: anytype) !void {
    var buf: [40]u8 = undefined;
    var total: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iterator = std.mem.splitScalar(u8, line, ' ');

        var is_asc: ?bool = null;
        var is_safe = true;
        while (iterator.next()) |val| {
            if (iterator.peek()) |next_val| {
                const num = try std.fmt.parseInt(i32, val, 10);
                const next_num = try std.fmt.parseInt(i32, next_val, 10);

                if (is_asc == null) {
                    is_asc = next_num > num;
                }

                if (is_asc != (next_num > num)) {
                    is_safe = false;
                    break;
                }

                const diff = @abs(next_num - num);
                if (diff < 1 or diff > 3) {
                    is_safe = false;
                    break;
                }
            }
        }

        if (is_safe) {
            total += 1;
        }
    }

    std.debug.print("total: {d}\n", .{total});
}

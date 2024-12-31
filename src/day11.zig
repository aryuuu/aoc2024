const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day11.txt");
    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var reader_buffer = std.io.bufferedReader(file.reader());
    var reader = reader_buffer.reader();

    var stones = std.ArrayList(usize).init(allocator);
    defer stones.deinit();

    var buff: [100]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buff, '\n')) |line| {
        var iter = std.mem.splitScalar(u8, line, ' ');

        while (iter.next()) |c| {
            const num = try std.fmt.parseUnsigned(usize, c, 10);
            try stones.append(num);
        }
    }

    var container = try stones.clone();
    defer container.deinit();

    for (0..25) |_| {
        var temp_container = std.ArrayList(usize).init(allocator);
        defer temp_container.deinit();

        for (container.items) |stone| {
            if (stone == 0) {
                try temp_container.append(1);
            } else {
                var buf: [100]u8 = undefined;
                const num_txt = try std.fmt.bufPrint(&buf, "{d}", .{stone});
                const len = num_txt.len;
                if (len % 2 == 0) {
                    const left_stone = try std.fmt.parseUnsigned(usize, num_txt[0..len/2], 10);
                    try temp_container.append(left_stone);

                    const right_stone = try std.fmt.parseUnsigned(usize, num_txt[len/2..], 10);
                    try temp_container.append(right_stone);
                } else {
                    try temp_container.append(stone * 2024);
                }
            }

        }

        const new_container = try temp_container.clone();
        container.deinit();
        container = new_container;
    }

    return container.items.len;
}

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day11.test.txt");
    try std.testing.expectEqual(55312, result);
}

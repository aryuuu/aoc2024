const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const filename = "./input/day4.txt";
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var lines = std.ArrayList([]const u8).init(allocator);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var buf: [150]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const val = try allocator.dupe(u8, line);
        try lines.append(val);
    }

    const result = try part1(lines.items);
    std.debug.print("result: {d}\n", .{result});
}

fn part1(input: []const []const u8) !usize {
    var total: usize = 0;
    const line_len: usize = input[0].len;
    for (0..input.len) |i| {
        for (0..line_len) |j| {
            if (input[i][j] != 'X') {
                continue;
            }
            // >>>>>
            if (j < line_len - 3) {
                const str = input[i][j .. j + 4];
                if (std.mem.eql(u8, str, "XMAS")) {
                    total += 1;
                }
            }
            // <<<<<
            if (j >= 3) {
                var str: [4]u8 = undefined;
                str[0] = input[i][j];
                str[1] = input[i][j - 1];
                str[2] = input[i][j - 2];
                str[3] = input[i][j - 3];
                if (std.mem.eql(u8, &str, "XMAS")) {
                    total += 1;
                }
            }
            // down
            if (i < input.len - 3) {
                var str: [4]u8 = undefined;
                str[0] = input[i][j];
                str[1] = input[i + 1][j];
                str[2] = input[i + 2][j];
                str[3] = input[i + 3][j];
                if (std.mem.eql(u8, &str, "XMAS")) {
                    total += 1;
                }
            }
            // ^
            if (i >= 3) {
                var str: [4]u8 = undefined;
                str[0] = input[i][j];
                str[1] = input[i - 1][j];
                str[2] = input[i - 2][j];
                str[3] = input[i - 3][j];
                if (std.mem.eql(u8, &str, "XMAS")) {
                    total += 1;
                }
            }
            // up-left
            if (i >= 3 and j >= 3) {
                var str: [4]u8 = undefined;
                str[0] = input[i][j];
                str[1] = input[i - 1][j - 1];
                str[2] = input[i - 2][j - 2];
                str[3] = input[i - 3][j - 3];
                if (std.mem.eql(u8, &str, "XMAS")) {
                    total += 1;
                }
            }
            // up-right
            if (i >= 3 and j < line_len - 3) {
                var str: [4]u8 = undefined;
                str[0] = input[i][j];
                str[1] = input[i - 1][j + 1];
                str[2] = input[i - 2][j + 2];
                str[3] = input[i - 3][j + 3];
                if (std.mem.eql(u8, &str, "XMAS")) {
                    total += 1;
                }
            }
            // down-left
            if (i < input[i].len - 3 and j >= 3) {
                var str: [4]u8 = undefined;
                str[0] = input[i][j];
                str[1] = input[i + 1][j - 1];
                str[2] = input[i + 2][j - 2];
                str[3] = input[i + 3][j - 3];
                if (std.mem.eql(u8, &str, "XMAS")) {
                    total += 1;
                }
            }
            // down-right
            if (i < input.len - 3 and j < line_len - 3) {
                var str: [4]u8 = undefined;
                str[0] = input[i][j];
                str[1] = input[i + 1][j + 1];
                str[2] = input[i + 2][j + 2];
                str[3] = input[i + 3][j + 3];
                if (std.mem.eql(u8, &str, "XMAS")) {
                    total += 1;
                }
            }
        }
    }

    return total;
}

test "part1" {
    const input = [_][]const u8{
        "MMMSXXMASM",
        "MSAMXMSMSA",
        "AMXSXMAAMM",
        "MSAMASMSMX",
        "XMASAMXAMM",
        "XXAMMXXAMA",
        "SMSMSASXSS",
        "SAXAMASAAA",
        "MAMMMXMMMM",
        "MXMXAXMASX",
    };
    const result = try part1(&input);
    try std.testing.expectEqual(@as(usize, 18), result);
}

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const file = try std.fs.cwd().openFile("./input/day2.txt", .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const should_run_part_2 = for (args[1..]) |arg| {
        if (std.mem.eql(u8, arg, "part2")) break true;
    } else false;

    if (should_run_part_2) {
        try part2(allocator, &reader);
    } else {
        try part1(allocator, &reader);
    }
}

fn part1(allocator: std.mem.Allocator, reader: anytype) !void {
    var buf: [40]u8 = undefined;
    var total: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const numbers = try parseLine(allocator, line);
        defer allocator.free(numbers);

        if (isLineSafe(numbers)) {
            total += 1;
        }
    }

    std.debug.print("total: {d}\n", .{total});
}

fn part2(allocator: std.mem.Allocator, reader: anytype) !void {
    var buf: [40]u8 = undefined;
    var total: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const numbers = try parseLine(allocator, line);
        defer allocator.free(numbers);

        if (isLineSafe(numbers)) {
            total += 1;
            continue;
        } else {
            for (0..numbers.len) |i| {
                const new_arr = try std.mem.concat(allocator, i32, &[_][]const i32{numbers[0..i], numbers[i+1..]});
                defer allocator.free(new_arr);
                if (isLineSafe(new_arr)) {
                    total += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("total: {d}\n", .{total});
}

fn parseLine(allocator: std.mem.Allocator, line: []const u8) ![]i32 {
    var result = std.ArrayList(i32).init(allocator);
    defer result.deinit();

    var iterator = std.mem.splitScalar(u8, line, ' ');

    while (iterator.next()) |val| {
        const num = try std.fmt.parseInt(i32, val, 10);
        try result.append(num);
    }

    return result.toOwnedSlice();
}

fn isLineSafe(numbers: []i32) bool {
    var is_asc: ?bool = null;
    var i: usize = 0;
    var is_safe = true;
    while (i < numbers.len - 1) {
        const curr_num = numbers[i];
        const next_num = numbers[i + 1];
        i += 1;

        if (is_asc == null) {
            is_asc = next_num > curr_num;
        }

        if (is_asc != (next_num > curr_num)) {
            is_safe = false;
            break;
        }

        const diff = @abs(next_num - curr_num);
        if (diff < 1 or diff > 3) {
            is_safe = false;
            break;
        }
    }

    return is_safe;
}

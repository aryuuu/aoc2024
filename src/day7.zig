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

    const filename = "./input/day7.txt";
    var result: usize = undefined;
    if (should_run_part_2) {
        result = try part2(allocator, filename);
    } else {
        result = try part1(allocator, filename);
    }

    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var total: usize = 0;
    var buf: [60]u8 = undefined;
    const operators: [2]Operator = .{ Operator.add, Operator.multiply };
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iter = std.mem.splitScalar(u8, line, ':');
        const raw_total = iter.next().?;

        var equation = Equation.init(allocator);
        defer equation.deinit();

        const total_num = try std.fmt.parseUnsigned(u64, raw_total, 10);
        equation.total = total_num;

        const raw_numbers = iter.next().?;
        var raw_numbers_iter = std.mem.splitScalar(u8, raw_numbers, ' ');
        while (raw_numbers_iter.next()) |raw_num| {
            if (raw_num.len == 0) {
                continue;
            }

            const num = try std.fmt.parseUnsigned(u64, raw_num, 10);
            try equation.numbers.append(num);
        }

        if (permutationHelper(&operators, equation.total, equation.numbers.items[0], equation.numbers.items, 1)) |result| {
            total += result;
        }
    }

    return total;
}

fn permutationHelper(operators: []const Operator, target: usize, temp_tot: usize, numbers: []const usize, idx: usize) ?usize {
    if (idx == numbers.len) {
        if (target == temp_tot) {
            return target;
        } else {
            return null;
        }
    }

    if (temp_tot > target) {
        return null;
    }

    for (operators) |op| {
        var new_temp: usize = temp_tot;
        switch (op) {
            Operator.add => new_temp += numbers[idx],
            Operator.multiply => new_temp *= numbers[idx],
            Operator.concat => {
                const digitCount = getDigitCount(numbers[idx]);
                new_temp *= std.math.pow(usize, 10, digitCount);
                new_temp += numbers[idx];
            },
        }
        if (permutationHelper(operators, target, new_temp, numbers, idx + 1)) |res| {
            return res;
        }
    }

    return null;
}

fn part2(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var total: usize = 0;
    var buf: [60]u8 = undefined;
    const operators: [3]Operator = .{ Operator.add, Operator.multiply, Operator.concat };
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iter = std.mem.splitScalar(u8, line, ':');
        const raw_total = iter.next().?;

        var equation = Equation.init(allocator);
        defer equation.deinit();

        const total_num = try std.fmt.parseUnsigned(u64, raw_total, 10);
        equation.total = total_num;

        const raw_numbers = iter.next().?;
        var raw_numbers_iter = std.mem.splitScalar(u8, raw_numbers, ' ');
        while (raw_numbers_iter.next()) |raw_num| {
            if (raw_num.len == 0) {
                continue;
            }

            const num = try std.fmt.parseUnsigned(u64, raw_num, 10);
            try equation.numbers.append(num);
        }

        if (permutationHelper(&operators, equation.total, equation.numbers.items[0], equation.numbers.items, 1)) |result| {
            total += result;
        }
    }

    return total;
}

fn getDigitCount(n: usize) usize {
    if (n == 0) return 1;
    var temp: usize = n;
    var count: usize = 0;
    while (temp > 0) {
        temp /= 10;
        count += 1;
    }
    return count;
}

const Equation = struct {
    total: usize,
    numbers: std.ArrayList(usize),

    pub fn init(allocator: std.mem.Allocator) Equation {
        return Equation{
            .total = 0,
            .numbers = std.ArrayList(usize).init(allocator),
        };
    }

    pub fn deinit(self: *Equation) void {
        self.numbers.deinit();
    }
};

const Operator = enum {
    add,
    multiply,
    concat,
};

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day7.test.txt");
    try std.testing.expectEqual(3749, result);
}

test "digit count" {
    const result = getDigitCount(10);
    try std.testing.expectEqual(2, result);
    const result1 = getDigitCount(100);
    try std.testing.expectEqual(3, result1);
    const result2 = getDigitCount(101);
    try std.testing.expectEqual(3, result2);
    const result3 = getDigitCount(1);
    try std.testing.expectEqual(1, result3);
    const result4 = getDigitCount(0);
    try std.testing.expectEqual(1, result4);
}

test "part 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part2(allocator, "./input/day7.test.txt");
    try std.testing.expectEqual(11387, result);
}

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

    // const result = try part1(allocator, "./input/day7.txt");
    // std.debug.print("result: {d}\n", .{result});
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

        const operatorCombinations = try generateOperatorPermutations(allocator, &operators, equation.numbers.items.len - 1);
        defer {
            for (operatorCombinations.items) |comb| {
                comb.deinit();
            }
            operatorCombinations.deinit();
        }

        for (operatorCombinations.items) |comb| {
            // std.debug.print("======\n", .{});
            // std.debug.print("{d}: {d} ", .{ equation.total, equation.numbers.items[0] });
            var temp: usize = equation.numbers.items[0];
            for (comb.items, 0..) |op, i| {
                const a = equation.numbers.items[i + 1];
                switch (op) {
                    Operator.add => {
                        // std.debug.print("+ {d} ", .{a});
                        temp += a;
                    },
                    Operator.multiply => {
                        // std.debug.print("* {d} ", .{a});
                        temp *= a;
                    },
                    else => {},
                }
                if (temp > equation.total) {
                    break;
                }
            }

            // std.debug.print(" ==> {}\n", .{temp});
            if (temp == equation.total) {
                // std.debug.print("HIT temp: {d}, total: {d}\n", .{ temp, equation.total });
                total += temp;
                break;
            }
        }
    }

    return total;
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

        const operatorCombinations = try generateOperatorPermutations(allocator, &operators, equation.numbers.items.len - 1);
        defer {
            for (operatorCombinations.items) |comb| {
                comb.deinit();
            }
            operatorCombinations.deinit();
        }

        for (operatorCombinations.items) |comb| {
            // std.debug.print("======\n", .{});
            // std.debug.print("{d}: {d} ", .{ equation.total, equation.numbers.items[0] });
            var temp: usize = equation.numbers.items[0];
            for (comb.items, 0..) |op, i| {
                const a = equation.numbers.items[i + 1];
                switch (op) {
                    Operator.add => {
                        // std.debug.print("+ {d} ", .{a});
                        temp += a;
                    },
                    Operator.multiply => {
                        // std.debug.print("* {d} ", .{a});
                        temp *= a;
                    },
                    Operator.concat => {
                        // std.debug.print("|| {d} ", .{a});
                        const digitCount = getDigitCount(a);
                        temp *= std.math.pow(usize, 10, digitCount);
                        temp += a;
                    },
                }
            }

            // std.debug.print(" ==> {}\n", .{temp});
            if (temp == equation.total) {
                // std.debug.print("HIT temp: {d}, total: {d}\n", .{ temp, equation.total });
                total += temp;
                break;
            }
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

fn generateOperatorPermutations(allocator: std.mem.Allocator, operators: []const Operator, len: usize) !std.ArrayList(std.ArrayList(Operator)) {
    var result = std.ArrayList(std.ArrayList(Operator)).init(allocator);

    var curr_list = std.ArrayList(Operator).init(allocator);
    defer curr_list.deinit();
    try generatorHelper(allocator, operators, &curr_list, &result, len);

    return result;
}

fn generatorHelper(allocator: std.mem.Allocator, operators: []const Operator, curr_list: *std.ArrayList(Operator), comb_list: *std.ArrayList(std.ArrayList(Operator)), len: usize) !void {
    if (curr_list.items.len == len) {
        const curr_copy = try curr_list.clone();
        try comb_list.append(curr_copy);
        return;
    }

    for (operators) |op| {
        var curr_copy = try curr_list.clone();
        defer curr_copy.deinit();
        try curr_copy.append(op);
        try generatorHelper(allocator, operators, &curr_copy, comb_list, len);
    }
}

fn factorial(n: u64) u64 {
    var res = 1;
    for (1..(n + 1)) |i| {
        res *= i;
    }

    return res;
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

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

    var result: usize = 0;
    if (should_run_part_2) {
        result = try part2(allocator, "./input/day9.txt");
    } else {
        result = try part1(allocator, "./input/day9.txt");
    }

    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var blocks = std.ArrayList(Block).init(allocator);
    defer blocks.deinit();

    var curr_id: usize = 0;
    var is_free = false;
    var buf: [1024]u8 = undefined;
    while (true) {
        const read_len = try reader.read(&buf);
        if (read_len == 0) {
            break;
        }

        for (buf) |char| {
            if (char < '0') {
                break;
            }
            const num = char - '0';
            if (is_free) {
                for (0..num) |_| {
                    try blocks.append(Block.free);
                }
            } else {
                for (0..num) |_| {
                    try blocks.append(Block{ .file = curr_id });
                }
                curr_id += 1;
            }
            is_free = !is_free;
        }
    }

    var i: usize = 0;
    var j: usize = blocks.items.len - 1;

    while (i < j) {
        const head = blocks.items[i];
        const tail = blocks.items[j];

        switch (head) {
            Block.file => |_| {
                i += 1;

                switch (tail) {
                    Block.free => j -= 1,
                    else => {},
                }
            },
            Block.free => {
                switch (tail) {
                    Block.free => j -= 1,
                    Block.file => |id| {
                        blocks.items[i] = Block{ .file = id };
                        blocks.items[j] = Block.free;
                        i += 1;
                        j -= 1;
                    },
                }
            },
        }
    }

    var total: usize = 0;
    for (blocks.items, 0..) |item, idx| {
        switch (item) {
            Block.file => |id| {
                total += idx * id;
            },
            else => break,
        }
    }

    return total;
}

fn part2(allocator: std.mem.Allocator, filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var read_buffer = std.io.bufferedReader(file.reader());
    var reader = read_buffer.reader();

    var blocks = std.ArrayList(Block).init(allocator);
    defer blocks.deinit();

    var curr_id: usize = 0;
    var is_free = false;
    var buf: [1024]u8 = undefined;
    while (true) {
        const read_len = try reader.read(&buf);
        if (read_len == 0) {
            break;
        }

        for (buf) |char| {
            if (char < '0') {
                break;
            }
            const num = char - '0';
            if (is_free) {
                for (0..num) |_| {
                    try blocks.append(Block.free);
                }
            } else {
                for (0..num) |_| {
                    try blocks.append(Block{ .file = curr_id });
                }
                curr_id += 1;
            }
            is_free = !is_free;
        }
    }

    var i: usize = 0;
    var j: usize = blocks.items.len - 1;

    while (i < j) {
        const head = blocks.items[i];
        const tail = blocks.items[j];

        switch (head) {
            Block.free => {

                switch (tail) {
                    Block.free => j -= 1,
                    Block.file => |id| {
                        blocks.items[i] = Block{ .file = id };
                        blocks.items[j] = Block.free;
                        i += 1;
                        j -= 1;
                    },
                }
            },
            Block.file => |_| {
                i += 1;

                switch (tail) {
                    Block.free => j -= 1,
                    else => {},
                }
            },
        }
    }

    var total: usize = 0;
    for (blocks.items, 0..) |item, idx| {
        switch (item) {
            Block.file => |id| {
                total += idx * id;
            },
            else => break,
        }
    }

    return total;
}

const Block = union(enum) {
    free,
    file: usize,
};

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day9.test.txt");
    try std.testing.expectEqual(1928, result);
}

test "part 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part2(allocator, "./input/day9.test.txt");
    try std.testing.expectEqual(2858, result);
}

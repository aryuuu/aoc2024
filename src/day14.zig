const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day14.txt", 103, 101);
    std.debug.print("result: {d}\n", .{result});
}

fn part1(allocator: std.mem.Allocator, filename: [] const u8, row: i32, col: i32) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffered_reader = std.io.bufferedReader(file.reader());
    var reader = buffered_reader.reader();
    var buf: [30]u8 = undefined;

    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iter = std.mem.splitScalar(u8, line, ' ');
        const pos_str = iter.next().?;
        const pos_val = pos_str[2..];
        var pos_iter = std.mem.splitScalar(u8, pos_val, ',');
        const pos_x = try std.fmt.parseInt(i32, pos_iter.next().?, 10);
        const pos_y = try std.fmt.parseInt(i32, pos_iter.next().?, 10);

        var vec_str = iter.next().?;
        const vec_val = vec_str[2..];
        var vec_iter = std.mem.splitScalar(u8, vec_val, ',');
        const vec_x = try std.fmt.parseInt(i32, vec_iter.next().?, 10);
        const vec_y = try std.fmt.parseInt(i32, vec_iter.next().?, 10);

        try robots.append(Robot{
            .pos = Point{
                .x = pos_x,
                .y = pos_y,
            },
            .vec = Vector{
                .x = vec_x,
                .y = vec_y,
            }
        });
    }
    
    var q1: usize = 0;
    var q2: usize = 0;
    var q3: usize = 0;
    var q4: usize = 0;

    const mid_x = @divTrunc(col, 2);
    const mid_y = @divTrunc(row, 2);
    // let's try using 4 threads only? maybe later
    for (robots.items) |*robot| {
        for (0..100) |_| {
            robot.pos.x = @mod(robot.pos.x + robot.vec.x, col);
            robot.pos.y = @mod(robot.pos.y + robot.vec.y, row);
        }

        if (robot.pos.x < mid_x and robot.pos.y < mid_y) { // q1
            q1 += 1;
        } else if (robot.pos.x > mid_x and robot.pos.y < mid_y) { // q2
            q2 += 1;
        } else if (robot.pos.x < mid_x and robot.pos.y > mid_y) { // q3
            q3 += 1;
        } else if (robot.pos.x > mid_x and robot.pos.y > mid_y) { // q4
            q4 += 1;
        }
    }

    return q1 * q2 * q3 * q4;
}

const Robot = struct {pos: Point, vec: Vector};

const Point = struct {x: i32, y: i32};

const Vector = struct {x: i32, y: i32};

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const result = try part1(allocator, "./input/day14.test.txt", 7, 11);

    try std.testing.expectEqual(12, result);
}

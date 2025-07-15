const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    inline for ([_]struct { name: []const u8 }{
        .{ .name = "main" },
        .{ .name = "day1" },
        .{ .name = "day2" },
        .{ .name = "day3" },
        .{ .name = "day4" },
        .{ .name = "day5" },
        .{ .name = "day6" },
        .{ .name = "day7" },
        .{ .name = "day8" },
        .{ .name = "day9" },
        .{ .name = "day10" },
        .{ .name = "day11" },
        .{ .name = "day12" },
        .{ .name = "day14" },
        .{ .name = "day15" },
        .{ .name = "day16" },
    }) |e| {
        const test_step_name = try std.fmt.allocPrint(b.allocator, "test_{s}", .{e.name});
        const root_source_file = try std.fmt.allocPrint(b.allocator, "src/{s}.zig", .{e.name});

        const e_exe = b.addExecutable(.{
            .name = e.name,
            .root_source_file = b.path(root_source_file),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(e_exe);
        const e_run_cmd = b.addRunArtifact(e_exe);
        e_run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            e_run_cmd.addArgs(args);
        }
        const e_run_step = b.step(e.name, "Run solution");
        e_run_step.dependOn(&e_run_cmd.step);

        const e_unit_tests = b.addTest(.{
            .root_source_file = b.path(root_source_file),
            .target = target,
            .optimize = optimize,
        });
        const e_run_tests = b.addRunArtifact(e_unit_tests);
        const e_test_step = b.step(test_step_name, "Run test");
        e_test_step.dependOn(&e_run_tests.step);
    }
}

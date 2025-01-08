const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aoc2024",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    inline for ([_]struct { name: []const u8 }{
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
        // .{ .name = "day15" },
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

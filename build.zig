const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
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

    const day1_exe = b.addExecutable(.{
        .name = "aoc2024_day1",
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day1_exe);
    const run_day1_cmd = b.addRunArtifact(day1_exe);
    run_day1_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day1_cmd.addArgs(args);
    }
    const run_day1_step = b.step("day1", "Run the app");
    run_day1_step.dependOn(&run_day1_cmd.step);

    const day2_exe = b.addExecutable(.{
        .name = "aoc2024_day2",
        .root_source_file = b.path("src/day2.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day2_exe);
    const run_day2_cmd = b.addRunArtifact(day2_exe);
    run_day2_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day2_cmd.addArgs(args);
    }
    const run_day2_step = b.step("day2", "Run the app");
    run_day2_step.dependOn(&run_day2_cmd.step);

    const day3_exe = b.addExecutable(.{
        .name = "aoc2024_day3",
        .root_source_file = b.path("src/day3.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day3_exe);
    const run_day3_cmd = b.addRunArtifact(day3_exe);
    run_day3_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day3_cmd.addArgs(args);
    }
    const run_day3_step = b.step("day3", "Run the app");
    run_day3_step.dependOn(&run_day3_cmd.step);

    const day4_exe = b.addExecutable(.{
        .name = "aoc2024_day4",
        .root_source_file = b.path("src/day4.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day4_exe);
    const run_day4_cmd = b.addRunArtifact(day4_exe);
    run_day4_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day4_cmd.addArgs(args);
    }
    const run_day4_step = b.step("day4", "Run the app");
    run_day4_step.dependOn(&run_day4_cmd.step);

    const day5_exe = b.addExecutable(.{
        .name = "aoc2025_day5",
        .root_source_file = b.path("src/day5.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day5_exe);
    const run_day5_cmd = b.addRunArtifact(day5_exe);
    run_day5_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day5_cmd.addArgs(args);
    }
    const run_day5_step = b.step("day5", "Run the app");
    run_day5_step.dependOn(&run_day5_cmd.step);

    const day6_exe = b.addExecutable(.{
        .name = "aoc2026_day6",
        .root_source_file = b.path("src/day6.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day6_exe);
    const run_day6_cmd = b.addRunArtifact(day6_exe);
    run_day6_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day6_cmd.addArgs(args);
    }
    const run_day6_step = b.step("day6", "Run the app");
    run_day6_step.dependOn(&run_day6_cmd.step);

    const day7_exe = b.addExecutable(.{
        .name = "aoc2027_day7",
        .root_source_file = b.path("src/day7.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day7_exe);
    const run_day7_cmd = b.addRunArtifact(day7_exe);
    run_day7_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day7_cmd.addArgs(args);
    }
    const run_day7_step = b.step("day7", "Run the app");
    run_day7_step.dependOn(&run_day7_cmd.step);

    const day8_exe = b.addExecutable(.{
        .name = "aoc2028_day8",
        .root_source_file = b.path("src/day8.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day8_exe);
    const run_day8_cmd = b.addRunArtifact(day8_exe);
    run_day8_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day8_cmd.addArgs(args);
    }
    const run_day8_step = b.step("day8", "Run the app");
    run_day8_step.dependOn(&run_day8_cmd.step);

    const day9_exe = b.addExecutable(.{
        .name = "aoc2029_day9",
        .root_source_file = b.path("src/day9.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day9_exe);
    const run_day9_cmd = b.addRunArtifact(day9_exe);
    run_day9_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day9_cmd.addArgs(args);
    }
    const run_day9_step = b.step("day9", "Run the app");
    run_day9_step.dependOn(&run_day9_cmd.step);

    const day10_exe = b.addExecutable(.{
        .name = "aoc20210_day10",
        .root_source_file = b.path("src/day10.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day10_exe);
    const run_day10_cmd = b.addRunArtifact(day10_exe);
    run_day10_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day10_cmd.addArgs(args);
    }
    const run_day10_step = b.step("day10", "Run the app");
    run_day10_step.dependOn(&run_day10_cmd.step);

    const day11_exe = b.addExecutable(.{
        .name = "aoc20211_day11",
        .root_source_file = b.path("src/day11.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(day11_exe);
    const run_day11_cmd = b.addRunArtifact(day11_exe);
    run_day11_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_day11_cmd.addArgs(args);
    }
    const run_day11_step = b.step("day11", "Run the app");
    run_day11_step.dependOn(&run_day11_cmd.step);

    // TESTS
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const day1_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day1_unit_tests = b.addRunArtifact(day1_unit_tests);

    const day2_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day2.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day2_unit_tests = b.addRunArtifact(day2_unit_tests);

    const day3_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day3.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day3_unit_tests = b.addRunArtifact(day3_unit_tests);

    const day4_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day4.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day4_unit_tests = b.addRunArtifact(day4_unit_tests);

    const day5_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day5.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day5_unit_tests = b.addRunArtifact(day5_unit_tests);

    const day6_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day6.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day6_unit_tests = b.addRunArtifact(day6_unit_tests);

    const day7_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day7.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day7_unit_tests = b.addRunArtifact(day7_unit_tests);

    const day8_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day8.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day8_unit_tests = b.addRunArtifact(day8_unit_tests);

    const day9_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day9.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day9_unit_tests = b.addRunArtifact(day9_unit_tests);

    const day10_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day10.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day10_unit_tests = b.addRunArtifact(day10_unit_tests);

    const day11_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/day11.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day11_unit_tests = b.addRunArtifact(day11_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    const test_day1_step = b.step("test_day1", "Run unit tests for day1");
    const test_day2_step = b.step("test_day2", "Run unit tests for day2");
    const test_day3_step = b.step("test_day3", "Run unit tests for day3");
    const test_day4_step = b.step("test_day4", "Run unit tests for day4");
    const test_day5_step = b.step("test_day5", "Run unit tests for day5");
    const test_day6_step = b.step("test_day6", "Run unit tests for day6");
    const test_day7_step = b.step("test_day7", "Run unit tests for day7");
    const test_day8_step = b.step("test_day8", "Run unit tests for day8");
    const test_day9_step = b.step("test_day9", "Run unit tests for day9");
    const test_day10_step = b.step("test_day10", "Run unit tests for day10");
    const test_day11_step = b.step("test_day11", "Run unit tests for day11");
    test_step.dependOn(&run_exe_unit_tests.step);
    test_day1_step.dependOn(&run_day1_unit_tests.step);
    test_day2_step.dependOn(&run_day2_unit_tests.step);
    test_day3_step.dependOn(&run_day3_unit_tests.step);
    test_day4_step.dependOn(&run_day4_unit_tests.step);
    test_day5_step.dependOn(&run_day5_unit_tests.step);
    test_day6_step.dependOn(&run_day6_unit_tests.step);
    test_day7_step.dependOn(&run_day7_unit_tests.step);
    test_day8_step.dependOn(&run_day8_unit_tests.step);
    test_day9_step.dependOn(&run_day9_unit_tests.step);
    test_day10_step.dependOn(&run_day10_unit_tests.step);
    test_day11_step.dependOn(&run_day11_unit_tests.step);
}

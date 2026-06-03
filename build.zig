const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const shared = b.option(bool, "Shared", "Linking with libleanshared [default: true]") orelse true;

    _ = b.addModule("lean4", .{
        .root_source_file = b.path("src/lean.zig"),
    });
    lean4FFI(b);
    try runTest(b, target);
    try reverseFFI(b, .{
        .target = target,
        .optimize = optimize,
        .linkage = switch (shared) {
            true => .dynamic,
            false => .static,
        },
    });
}

fn lean4FFI(b: *std.Build) void {
    const lake = b.findProgram(&.{"lake"}, &.{}) catch @panic("lake not found!");
    const lakebuild = lakeBuild(b, "examples/ffi/app");
    const update = b.addSystemCommand(&.{
        lake,
        "--dir=examples/ffi/app",
        "update",
    });
    const run = b.addSystemCommand(&.{
        "examples/ffi/app/.lake/build/bin/app",
    });
    lakebuild.step.dependOn(&update.step);
    run.step.dependOn(&lakebuild.step);
    const run_cmd = b.step("zffi", "run zig-lib on lean4-app");
    run_cmd.dependOn(&run.step);
}

fn reverseFFI(b: *std.Build, info: BuildInfo) !void {
    const exe = b.addExecutable(.{
        .name = "reverse-ffi",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/reverse-ffi/app/app.zig"),
            .target = info.target,
            .optimize = info.optimize,
        }),
    });
    exe.root_module.addImport("lean4", b.modules.get("lean4").?);
    exe.root_module.addLibraryPath(b.path("examples/reverse-ffi/lib/.lake/build/lib"));
    const lean4_prefix = try lean4Prefix(b);
    const lib_dir = lean4LibDir(b, lean4_prefix);
    exe.root_module.addLibraryPath(.{ .cwd_relative = lib_dir });

    if (exe.rootModuleTarget().os.tag.isDarwin()) {
        addLibraryPathIfExists(exe.root_module, "/usr/local/lib");
    }
    exe.root_module.addIncludePath(.{ .cwd_relative = b.pathJoin(&.{ lean4_prefix, "include" }) });
    exe.step.dependOn(&lakeBuild(b, "examples/reverse-ffi/lib").step);

    // static obj
    exe.root_module.addCSourceFile(.{ .file = b.path("examples/reverse-ffi/lib/.lake/build/ir/RFFI.c"), .flags = &.{} });

    if (exe.rootModuleTarget().os.tag == .linux and info.linkage == .static) {
        exe.root_module.linkSystemLibrary("leancpp", .{});
        exe.root_module.linkSystemLibrary("leanrt", .{});
        exe.root_module.linkSystemLibrary("Init", .{});
        exe.root_module.linkSystemLibrary("Lean", .{});
        exe.root_module.linkSystemLibrary("gmp", .{});
        exe.root_module.link_libcpp = true; // libc++ + libunwind + libc
    } else {
        if (exe.rootModuleTarget().os.tag == .windows) {
            // search library name - no pkg-config
            exe.root_module.linkSystemLibrary("leanshared.dll", .{ .use_pkg_config = .no });
        } else {
            // detect library w/ pkg-config
            exe.root_module.linkSystemLibrary("leanshared", .{});
        }
        exe.root_module.link_libc = true;
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    if (exe.rootModuleTarget().os.tag == .windows)
        run_cmd.addPathDir(lib_dir);
    const run_step = b.step("rffi", b.fmt("Run the {s} app", .{exe.name}));
    run_step.dependOn(&run_cmd.step);
}

fn lakeBuild(b: *std.Build, path: []const u8) *std.Build.Step.Run {
    const lake = b.findProgram(&.{"lake"}, &.{}) catch @panic("lake not found!");
    const run = b.addSystemCommand(&.{
        lake,
        b.fmt("--dir={s}", .{path}),
        "build",
    });
    return run;
}

// skip nonexistent system dirs (e.g. /usr/local/lib on arm64 macOS) so the
// compiler doesn't warn, which the build runner treats as a step failure
fn addLibraryPathIfExists(m: *std.Build.Module, dir: []const u8) void {
    std.Io.Dir.accessAbsolute(m.owner.graph.io, dir, .{}) catch return;
    m.addLibraryPath(.{ .cwd_relative = dir });
}

fn lean4LibDir(b: *std.Build, lean4_prefix: []const u8) []const u8 {
    // for windows/mingw need "lib.dll.a" linking
    return b.pathJoin(&.{ lean4_prefix, "lib", "lean" });
}
fn lean4Prefix(b: *std.Build) ![]const u8 {
    const lean = try b.findProgram(&.{"lean"}, &.{});
    const stdout = b.run(&.{ lean, "--print-prefix" });
    var out = std.mem.splitSequence(u8, stdout, "\n"); // remove newline
    return out.first();
}

fn runTest(b: *std.Build, target: std.Build.ResolvedTarget) !void {
    const libTests = b.addTest(.{
        .name = "lean_test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lean.zig"),
            .target = target,
            .optimize = .Debug,
        }),
    });
    const lib_dir = lean4LibDir(b, try lean4Prefix(b));
    libTests.root_module.addLibraryPath(.{ .cwd_relative = lib_dir });

    if (libTests.rootModuleTarget().os.tag.isDarwin()) {
        addLibraryPathIfExists(libTests.root_module, "/usr/local/lib");
    }
    if (libTests.rootModuleTarget().os.tag == .windows) {
        libTests.root_module.linkSystemLibrary("leanshared.dll", .{ .use_pkg_config = .no });
    } else {
        libTests.root_module.linkSystemLibrary("leanshared", .{});
    }
    libTests.root_module.link_libc = true;
    const run_libTests = b.addRunArtifact(libTests);
    if (libTests.rootModuleTarget().os.tag == .windows)
        run_libTests.addPathDir(lib_dir);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_libTests.step);
}

const BuildInfo = struct {
    linkage: std.builtin.LinkMode,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

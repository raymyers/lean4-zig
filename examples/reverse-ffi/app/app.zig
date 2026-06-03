const std = @import("std");
const lean4 = @import("lean4");

// Symbols exported by the RFFI Lean library (see ../lib).
// `my_length`/`my_double` come from `@[export]` (unmangled names); the
// module initializer is generated, package-prefixed, and - since Lean 4.30 -
// no longer takes a world argument.
extern fn my_length(lean4.lean_obj_arg) u64;
extern fn my_double(n: u64) u64;
extern fn initialize_rffi_RFFI(builtin: u8) lean4.lean_obj_res;

fn lengthFromOtherThread(out: *u64) void {
    // Threads not started by Lean must wrap calls into the runtime.
    lean4.lean_initialize_thread();
    defer lean4.lean_finalize_thread();
    const s = lean4.lean_mk_string("seven&7");
    out.* = my_length(s);
}

pub fn main() !void {
    // Initialization protocol (see the FFI reference, "Initialization"):
    // lean_setup_args(argc, argv) first if libuv process functionality is
    // used, then lean_initialize_runtime_module (runtime only; use
    // lean_initialize when accessing the Lean package), then the module
    // initializers, then lean_io_mark_end_initialization.
    lean4.lean_initialize_runtime_module();
    // use same default as for Lean executables
    const builtin: u8 = 1;
    const res = initialize_rffi_RFFI(builtin);
    if (lean4.lean_io_result_is_ok(res)) {
        lean4.lean_dec_ref(res);
    } else {
        lean4.lean_io_result_show_error(res);
        lean4.lean_dec(res);
        // do not access Lean declarations if initialization failed
        @panic("lean: initialization failed!");
    }
    lean4.lean_io_mark_end_initialization();

    // actual program
    const s: lean4.LeanPtr = lean4.lean_mk_string("hello!");
    const l: u64 = my_length(s);
    std.debug.print("output: {}\n", .{l});

    // @[export]ed pure function on unboxed scalars
    std.debug.print("double: {}\n", .{my_double(42)});

    // calling into Lean from a non-Lean thread
    var from_thread: u64 = 0;
    const t = try std.Thread.spawn(.{}, lengthFromOtherThread, .{&from_thread});
    t.join();
    std.debug.print("thread: {}\n", .{from_thread});
}

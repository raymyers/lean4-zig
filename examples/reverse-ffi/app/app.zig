const std = @import("std");
const lean4 = @import("lean4");

// Symbols exported by the RFFI Lean library (see ../lib).
// Since Lean 4.30 the generated initializer is prefixed with the package name
// and no longer takes a world argument.
extern fn my_length(lean4.lean_obj_arg) u64;
extern fn initialize_rffi_RFFI(builtin: u8) lean4.lean_obj_res;

pub fn main() !void {
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
}

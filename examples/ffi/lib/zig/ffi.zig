const lean = @import("lean4");

export fn my_add(a: u32, b: u32) u32 {
    //[0] = (a+b), [1] = error (u1)
    const sum = @addWithOverflow(a, b);
    return if (sum[1] != 0) @intCast(sum[1]) else sum[0];
}

export fn my_lean_fun() lean.lean_obj_res {
    return lean.lean_io_result_mk_ok(lean.lean_box(0));
}

// Enum-like inductive (Color): arrives as a uint8 constructor index.
export fn my_color_code(c: u8) u32 {
    return switch (c) {
        0 => 0xFF0000, // .red
        1 => 0x00FF00, // .green
        else => 0x0000FF, // .blue
    };
}

// `@&String` parameter: borrowed, so we must NOT consume it - only read.
export fn my_string_len(s: lean.b_lean_obj_arg) lean.lean_obj_res {
    return lean.lean_usize_to_nat(lean.lean_string_len(s));
}

// `Option Nat` parameter: owned boxed inductive. `none` is lean_box(0),
// `some x` is a ctor object whose field 0 is the Nat. We consume `o`.
export fn my_option_or_zero(o: lean.lean_obj_arg) lean.lean_obj_res {
    if (lean.lean_is_scalar(o)) return lean.lean_box(0); // Option.none
    const v = lean.lean_ctor_get(o, 0); // borrowed field of Option.some
    lean.lean_inc(v); // take ownership of the field...
    lean.lean_dec(o); // ...before consuming the ctor
    return v;
}

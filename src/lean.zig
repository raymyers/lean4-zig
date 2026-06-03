const std = @import("std");

const FlexibleArrayType = std.zig.c_translation.helpers.FlexibleArrayType;
pub const __builtin_expect = std.zig.c_translation.builtins.expect;

pub const LEAN_VERSION_MAJOR = 4;
pub const LEAN_VERSION_MINOR = 0;
pub const LEAN_VERSION_PATCH = 0;
pub const LEAN_VERSION_IS_RELEASE = 0;
pub const LEAN_SPECIAL_VERSION_DESC = "nightly-2023-08-26";
pub const LEAN_IS_STAGE0 = 0;

pub const LEAN_CLOSURE_MAX_ARGS = 16;
pub const LEAN_OBJECT_SIZE_DELTA = 8;
pub const LEAN_MAX_SMALL_OBJECT_SIZE = 4096;

pub inline fn LEAN_UNLIKELY(x: bool) bool {
    return __builtin_expect(@intFromBool(x), 0) != 0;
}
pub inline fn LEAN_LIKELY(x: bool) bool {
    return __builtin_expect(@intFromBool(x), 1) != 0;
}

pub extern fn lean_notify_assert(fileName: [*:0]const u8, line: c_int, condition: [*:0]const u8) void;
inline fn assert(src: std.builtin.SourceLocation, cond: bool, msg: [*:0]const u8) void {
    if (!cond) lean_notify_assert(src.file, @intCast(src.line), msg);
}

pub inline fn LEAN_BYTE(Var: anytype, Index: anytype) @TypeOf((std.zig.c_translation.helpers.cast([*]u8, &Var) + Index).*) {
    return (std.zig.c_translation.helpers.cast([*]u8, &Var) + Index).*;
}

pub const LeanMaxCtorTag = 243;
pub const LeanPromise = 244;
pub const LeanClosure = 245;
pub const LeanArray = 246;
pub const LeanStructArray = 247;
pub const LeanScalarArray = 248;
pub const LeanString = 249;
pub const LeanMPZ = 250;
pub const LeanThunk = 251;
pub const LeanTask = 252;
pub const LeanRef = 253;
pub const LeanExternal = 254;
pub const LeanReserved = 255;

pub const LEAN_MAX_CTOR_FIELDS = 256;
pub const LEAN_MAX_CTOR_SCALARS_SIZE = 1024;

pub fn lean_is_big_object_tag(tag: u8) callconv(.c) bool {
    return tag == 246 or tag == 247 or tag == 248 or tag == 249;
}

pub const lean_object = extern struct {
    m_rc: c_int,
    m_cs_sz: u16,
    m_other: u8,
    m_tag: u8,
};
pub const LeanPtr = *align(1) lean_object;
pub const lean_obj_arg = LeanPtr;
pub const b_lean_obj_arg = LeanPtr;
pub const u_lean_obj_arg = LeanPtr;
pub const lean_obj_res = LeanPtr;
pub const b_lean_obj_res = LeanPtr;
pub const lean_ctor_object = extern struct {
    m_header: lean_object align(8),
    pub fn m_objs(self: anytype) FlexibleArrayType(@TypeOf(self), LeanPtr) {
        const Intermediate = FlexibleArrayType(@TypeOf(self), u8);
        const ReturnType = FlexibleArrayType(@TypeOf(self), LeanPtr);
        return @as(ReturnType, @ptrCast(@alignCast(@as(Intermediate, @ptrCast(self)) + 8)));
    }
};
pub const lean_array_object = extern struct {
    m_header: lean_object align(8),
    m_size: usize,
    m_capacity: usize,
    pub fn m_data(self: anytype) FlexibleArrayType(@TypeOf(self), LeanPtr) {
        const Intermediate = FlexibleArrayType(@TypeOf(self), u8);
        const ReturnType = FlexibleArrayType(@TypeOf(self), LeanPtr);
        return @as(ReturnType, @ptrCast(@alignCast(@as(Intermediate, @ptrCast(self)) + 24)));
    }
};
pub const lean_sarray_object = extern struct {
    m_header: lean_object align(8),
    m_size: usize,
    m_capacity: usize,
    pub fn m_data(self: anytype) FlexibleArrayType(@TypeOf(self), u8) {
        const Intermediate = FlexibleArrayType(@TypeOf(self), u8);
        const ReturnType = FlexibleArrayType(@TypeOf(self), u8);
        return @as(ReturnType, @ptrCast(@alignCast(@as(Intermediate, @ptrCast(self)) + 24)));
    }
};
pub const lean_string_object = extern struct {
    m_header: lean_object align(8),
    m_size: usize,
    m_capacity: usize,
    m_length: usize,
    pub fn m_data(self: anytype) FlexibleArrayType(@TypeOf(self), u8) {
        const Intermediate = FlexibleArrayType(@TypeOf(self), u8);
        const ReturnType = FlexibleArrayType(@TypeOf(self), u8);
        return @as(ReturnType, @ptrCast(@alignCast(@as(Intermediate, @ptrCast(self)) + 32)));
    }
};
pub const lean_closure_object = extern struct {
    m_header: lean_object align(8),
    m_fun: ?*anyopaque,
    m_arity: u16,
    m_num_fixed: u16,
    pub fn m_objs(self: anytype) FlexibleArrayType(@TypeOf(self), LeanPtr) {
        const Intermediate = FlexibleArrayType(@TypeOf(self), u8);
        const ReturnType = FlexibleArrayType(@TypeOf(self), LeanPtr);
        return @as(ReturnType, @ptrCast(@alignCast(@as(Intermediate, @ptrCast(self)) + 24)));
    }
};
pub const lean_ref_object = extern struct {
    m_header: lean_object,
    m_value: LeanPtr,
};
pub const lean_thunk_object = extern struct {
    m_header: lean_object,
    m_value: ?LeanPtr, // atomic
    m_closure: ?LeanPtr, // atomic
};
pub const lean_task_object = extern struct {
    m_header: lean_object,
    m_value: LeanPtr, // atomic
    m_imp: *lean_task_imp,
};
pub const lean_task_imp = extern struct {
    m_closure: LeanPtr,
    m_head_dep: ?*lean_task_object,
    m_next_dep: ?*lean_task_object,
    m_prio: c_uint,
    m_canceled: u8,
    m_keep_alive: u8,
    m_deleted: u8,
};
pub const lean_external_finalize_proc = *const fn (?*anyopaque) callconv(.c) void;
pub const lean_external_foreach_proc = *const fn (?*anyopaque, b_lean_obj_arg) callconv(.c) void;
pub const lean_external_class = extern struct {
    m_finalize: lean_external_finalize_proc,
    m_foreach: lean_external_foreach_proc,
};
pub extern fn lean_register_external_class(lean_external_finalize_proc, lean_external_foreach_proc) *lean_external_class;
pub const lean_external_object = extern struct {
    m_header: lean_object,
    m_class: *lean_external_class,
    m_data: ?*anyopaque,
};
pub fn lean_is_scalar(o: LeanPtr) callconv(.c) bool {
    return @intFromPtr(o) & 1 == 1;
}
pub fn lean_box(n: usize) callconv(.c) LeanPtr {
    return @ptrFromInt((n << 1) | 1);
}
pub fn lean_unbox(o: LeanPtr) callconv(.c) usize {
    return @intFromPtr(o) >> 1;
}
pub extern fn lean_set_exit_on_panic(flag: bool) void;
pub extern fn lean_set_panic_messages(flag: bool) void;
pub extern fn lean_panic_fn(default_val: LeanPtr, msg: LeanPtr) LeanPtr;
pub extern fn lean_internal_panic(msg: [*:0]const u8) noreturn;
pub extern fn lean_internal_panic_out_of_memory() noreturn;
pub extern fn lean_internal_panic_unreachable() noreturn;
pub extern fn lean_internal_panic_rc_overflow() noreturn;
pub extern fn lean_internal_panic_overflow() noreturn;
pub fn lean_usize_mul_checked(a: usize, b: usize) callconv(.c) usize {
    const r = @mulWithOverflow(a, b);
    if (LEAN_UNLIKELY(r[1] != 0)) lean_internal_panic_overflow();
    return r[0];
}
pub fn lean_usize_add_checked(a: usize, b: usize) callconv(.c) usize {
    const r = @addWithOverflow(a, b);
    if (LEAN_UNLIKELY(r[1] != 0)) lean_internal_panic_overflow();
    return r[0];
}
pub fn lean_align(v: usize, a: usize) callconv(.c) usize {
    return ((v / a) * a) + (a * @intFromBool((v % a) != 0));
}
pub fn lean_get_slot_idx(sz: c_uint) callconv(.c) c_uint {
    assert(@src(), sz > 0, "sz > 0");
    assert(@src(), lean_align(sz, LEAN_OBJECT_SIZE_DELTA) == sz, "lean_align(sz, LEAN_OBJECT_SIZE_DELTA) == sz");
    return sz / LEAN_OBJECT_SIZE_DELTA - 1;
}
pub extern fn lean_inc_heartbeat() void;
// Official Lean releases bundle mimalloc into the runtime (LEAN_MIMALLOC);
// lean_alloc_small/lean_free_small/lean_small_mem_size are no longer exported.
extern fn mi_malloc_small(sz: usize) ?*anyopaque;
extern fn mi_free(p: ?*anyopaque) void;
pub fn lean_alloc_small_object(sz: c_uint) callconv(.c) LeanPtr {
    lean_inc_heartbeat();
    // HACK(upstream): emulate behavior of small allocator to avoid `leangz` breakage
    const sz1: c_uint = @truncate(lean_align(sz, LEAN_OBJECT_SIZE_DELTA));
    const mem = mi_malloc_small(sz1) orelse lean_internal_panic_out_of_memory();
    const o: *lean_object = @ptrCast(@alignCast(mem));
    o.m_cs_sz = @intCast(sz1);
    return @ptrCast(o);
}
pub fn lean_alloc_ctor_memory(sz: c_uint) callconv(.c) LeanPtr {
    const sz1: c_uint = @truncate(lean_align(sz, LEAN_OBJECT_SIZE_DELTA));
    const r = lean_alloc_small_object(sz);
    if (sz1 > sz) {
        const end: [*]usize = @ptrCast(@alignCast(@as([*]u8, @ptrCast(r)) + sz1));
        (end - 1)[0] = 0;
    }
    return r;
}
pub fn lean_small_object_size(o: LeanPtr) callconv(.c) c_uint {
    return @as(*lean_object, @alignCast(o)).m_cs_sz;
}
pub fn lean_free_small_object(o: LeanPtr) callconv(.c) void {
    // must NOT use m_cs_sz here: it is repurposed for the deletion list
    mi_free(@ptrCast(o));
}
pub extern fn lean_alloc_object(sz: usize) LeanPtr;
pub extern fn lean_free_object(o: LeanPtr) void;
pub fn lean_ptr_tag(o: LeanPtr) callconv(.c) u8 {
    return @as(*lean_object, @alignCast(o)).m_tag;
}
pub fn lean_ptr_other(o: LeanPtr) callconv(.c) c_uint {
    return @as(*lean_object, @alignCast(o)).m_other;
}
pub extern fn lean_object_byte_size(o: LeanPtr) usize;
pub fn lean_is_mt(o: LeanPtr) callconv(.c) bool {
    return @as(*lean_object, @alignCast(o)).m_rc < 0;
}
pub fn lean_is_st(o: LeanPtr) callconv(.c) bool {
    return @as(*lean_object, @alignCast(o)).m_rc > 0;
}
pub fn lean_is_persistent(o: LeanPtr) callconv(.c) bool {
    return @as(*lean_object, @alignCast(o)).m_rc == 0;
}
pub fn lean_has_rc(o: LeanPtr) callconv(.c) bool {
    return @as(*lean_object, @alignCast(o)).m_rc != 0;
}
pub fn lean_get_rc_mt_addr(o: LeanPtr) callconv(.c) *c_int { // atomic
    return &@as(*lean_object, @alignCast(o)).m_rc;
}
pub fn lean_inc_ref_n(o: LeanPtr, n: usize) callconv(.c) void {
    if (LEAN_LIKELY(lean_is_st(o))) {
        o.m_rc += @intCast(n);
    } else if (o.m_rc != 0) {
        // MT refcounts are negative, so incrementing means an atomic subtract
        _ = @atomicRmw(c_int, lean_get_rc_mt_addr(o), .Sub, @intCast(n), .monotonic);
    }
}
pub fn lean_inc_ref(o: LeanPtr) callconv(.c) void {
    lean_inc_ref_n(o, 1);
}
pub extern fn lean_dec_ref_cold(o: LeanPtr) void;
pub fn lean_dec_ref(o: LeanPtr) callconv(.c) void {
    if (LEAN_LIKELY(o.m_rc > 1)) {
        o.m_rc -= 1;
    } else if (o.m_rc != 0) {
        lean_dec_ref_cold(o);
    }
}
pub fn lean_inc(o: LeanPtr) callconv(.c) void {
    if (!lean_is_scalar(o)) lean_inc_ref(o);
}
pub fn lean_inc_n(o: LeanPtr, n: usize) callconv(.c) void {
    if (!lean_is_scalar(o)) lean_inc_ref_n(o, n);
}
pub fn lean_dec(o: LeanPtr) callconv(.c) void {
    if (!lean_is_scalar(o)) lean_dec_ref(o);
}
pub extern fn lean_dealloc(o: LeanPtr) void;
pub fn lean_is_ctor(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) <= LeanMaxCtorTag;
}
pub fn lean_is_closure(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanClosure;
}
pub fn lean_is_array(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanArray;
}
pub fn lean_is_sarray(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanScalarArray;
}
pub fn lean_is_string(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanString;
}
pub fn lean_is_mpz(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanMPZ;
}
pub fn lean_is_thunk(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanThunk;
}
pub fn lean_is_task(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanTask;
}
pub fn lean_is_external(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanExternal;
}
pub fn lean_is_ref(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanRef;
}
pub fn lean_obj_tag(o: LeanPtr) callconv(.c) c_uint {
    if (lean_is_scalar(o)) return @truncate(lean_unbox(o)) else return lean_ptr_tag(o);
}
pub fn lean_to_ctor(o: LeanPtr) callconv(.c) *lean_ctor_object {
    assert(@src(), lean_is_ctor(o), "lean_is_ctor(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_closure(o: LeanPtr) callconv(.c) *lean_closure_object {
    assert(@src(), lean_is_closure(o), "lean_is_closure(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_array(o: LeanPtr) callconv(.c) *lean_array_object {
    assert(@src(), lean_is_array(o), "lean_is_array(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_sarray(o: LeanPtr) callconv(.c) *lean_sarray_object {
    assert(@src(), lean_is_sarray(o), "lean_is_sarray(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_string(o: LeanPtr) callconv(.c) *lean_string_object {
    assert(@src(), lean_is_string(o), "lean_is_string(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_thunk(o: LeanPtr) callconv(.c) *lean_thunk_object {
    assert(@src(), lean_is_thunk(o), "lean_is_thunk(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_task(o: LeanPtr) callconv(.c) *lean_task_object {
    assert(@src(), lean_is_task(o), "lean_is_task(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_ref(o: LeanPtr) callconv(.c) *lean_ref_object {
    assert(@src(), lean_is_ref(o), "lean_is_ref(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_to_external(o: LeanPtr) callconv(.c) *lean_external_object {
    assert(@src(), lean_is_external(o), "lean_is_external(o)");
    return @ptrCast(@alignCast(o));
}
pub fn lean_is_exclusive(o: LeanPtr) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_st(o))) {
        return o.m_rc == 1;
    } else {
        return false;
    }
}
pub fn lean_is_shared(o: LeanPtr) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_st(o))) {
        return o.m_rc > 1;
    } else {
        return false;
    }
}
pub extern fn lean_mark_mt(o: LeanPtr) void;
pub extern fn lean_mark_persistent(o: LeanPtr) void;
pub fn lean_set_st_header(o: LeanPtr, tag: c_uint, other: c_uint) callconv(.c) void {
    o.m_rc = 1;
    o.m_tag = @intCast(tag);
    o.m_other = @intCast(other);
    // do NOT zero m_cs_sz: with the mimalloc runtime it carries the
    // allocation size stored by lean_alloc_small_object
}
pub fn lean_set_non_heap_header(o: LeanPtr, sz: usize, tag: c_uint, other: c_uint) callconv(.c) void {
    assert(@src(), sz > 0, "sz > 0");
    assert(@src(), sz < (1 << 16), "sz < (1ull << 16)");
    assert(@src(), sz == 1 or !lean_is_big_object_tag(@intCast(tag)), "sz == 1 || !lean_is_big_object_tag(tag)");
    o.m_rc = 0;
    o.m_tag = @intCast(tag);
    o.m_other = @intCast(other);
    o.m_cs_sz = @intCast(sz);
}
pub fn lean_set_non_heap_header_for_big(o: LeanPtr, tag: c_uint, other: c_uint) callconv(.c) void {
    lean_set_non_heap_header(o, 1, tag, other);
}
pub fn lean_ctor_num_objs(o: LeanPtr) callconv(.c) c_uint {
    assert(@src(), lean_is_ctor(o), "lean_is_ctor(o)");
    return lean_ptr_other(o);
}
pub fn lean_ctor_obj_cptr(o: LeanPtr) callconv(.c) [*]LeanPtr {
    assert(@src(), lean_is_ctor(o), "lean_is_ctor(o)");
    return lean_to_ctor(o).m_objs();
}
pub fn lean_ctor_scalar_cptr(o: LeanPtr) callconv(.c) [*]u8 {
    assert(@src(), lean_is_ctor(o), "lean_is_ctor(o)");
    return @ptrCast(lean_ctor_obj_cptr(o) + lean_ctor_num_objs(o));
}
pub fn lean_alloc_ctor(tag: c_uint, num_objs: c_uint, scalar_sz: c_uint) callconv(.c) LeanPtr {
    assert(@src(), tag <= LeanMaxCtorTag and num_objs < LEAN_MAX_CTOR_FIELDS and scalar_sz < LEAN_MAX_CTOR_SCALARS_SIZE, "tag <= LeanMaxCtorTag && num_objs < LEAN_MAX_CTOR_FIELDS && scalar_sz < LEAN_MAX_CTOR_SCALARS_SIZE");
    const o = lean_alloc_ctor_memory(@intCast(lean_usize_add_checked(lean_usize_add_checked(@sizeOf(lean_ctor_object), lean_usize_mul_checked(@sizeOf(*anyopaque), num_objs)), scalar_sz)));
    lean_set_st_header(o, tag, num_objs);
    return o;
}
pub fn lean_ctor_get(o: b_lean_obj_arg, i: c_uint) callconv(.c) b_lean_obj_res {
    assert(@src(), i < lean_ctor_num_objs(o), "i < lean_ctor_num_objs(o)");
    return lean_ctor_obj_cptr(o)[i];
}
pub fn lean_ctor_set(o: b_lean_obj_arg, i: c_uint, v: lean_obj_arg) callconv(.c) void {
    assert(@src(), i < lean_ctor_num_objs(o), "i < lean_ctor_num_objs(o)");
    lean_ctor_obj_cptr(o)[i] = v;
}
pub fn lean_ctor_set_tag(o: b_lean_obj_arg, new_tag: u8) callconv(.c) void {
    assert(@src(), new_tag <= LeanMaxCtorTag, "new_tag <= LeanMaxCtorTag");
    o.m_tag = new_tag;
}
pub fn lean_ctor_release(o: b_lean_obj_arg, i: c_uint) callconv(.c) void {
    assert(@src(), i < lean_ctor_num_objs(o), "i < lean_ctor_num_objs(o)");
    const objs = lean_ctor_obj_cptr(o);
    lean_dec(objs[i]);
    objs[i] = lean_box(0);
}
pub fn lean_ctor_get_usize(o: b_lean_obj_arg, i: c_uint) callconv(.c) usize {
    assert(@src(), i >= lean_ctor_num_objs(o), "i >= lean_ctor_num_objs(o)");
    return @as(*usize, @ptrCast(lean_ctor_obj_cptr(o) + i)).*;
}
pub fn lean_ctor_get_uint8(o: b_lean_obj_arg, offset: c_uint) callconv(.c) u8 {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    return @as([*]u8, @ptrCast(lean_ctor_obj_cptr(o)))[offset];
}
pub fn lean_ctor_get_uint16(o: b_lean_obj_arg, offset: c_uint) callconv(.c) u16 {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    return @as(*u16, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).*;
}
pub fn lean_ctor_get_uint32(o: b_lean_obj_arg, offset: c_uint) callconv(.c) u32 {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    return @as(*u32, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).*;
}
pub fn lean_ctor_get_uint64(o: b_lean_obj_arg, offset: c_uint) callconv(.c) u64 {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    return @as(*u64, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).*;
}
pub fn lean_ctor_get_float(o: b_lean_obj_arg, offset: c_uint) callconv(.c) f64 {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    return @as(*f64, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).*;
}
pub fn lean_ctor_set_usize(o: b_lean_obj_arg, i: c_uint, v: usize) callconv(.c) void {
    assert(@src(), i >= lean_ctor_num_objs(o), "i >= lean_ctor_num_objs(o)");
    @as(*usize, @ptrCast(lean_ctor_obj_cptr(o) + i)).* = v;
}
pub fn lean_ctor_set_uint8(o: b_lean_obj_arg, offset: c_uint, v: u8) callconv(.c) void {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    @as([*]u8, @ptrCast(lean_ctor_obj_cptr(o)))[offset] = v;
}
pub fn lean_ctor_set_uint16(o: b_lean_obj_arg, offset: c_uint, v: u16) callconv(.c) void {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    @as(*u16, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).* = v;
}
pub fn lean_ctor_set_uint32(o: b_lean_obj_arg, offset: c_uint, v: u32) callconv(.c) void {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    @as(*u32, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).* = v;
}
pub fn lean_ctor_set_uint64(o: b_lean_obj_arg, offset: c_uint, v: u64) callconv(.c) void {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    @as(*u64, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).* = v;
}
pub fn lean_ctor_set_float(o: b_lean_obj_arg, offset: c_uint, v: f64) callconv(.c) void {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    @as(*f64, @ptrCast(@alignCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset))).* = v;
}
pub fn lean_closure_fun(o: LeanPtr) callconv(.c) ?*anyopaque {
    return lean_to_closure(o).m_fun;
}
pub fn lean_closure_arity(o: LeanPtr) callconv(.c) c_uint {
    return lean_to_closure(o).m_arity;
}
pub fn lean_closure_num_fixed(o: LeanPtr) callconv(.c) c_uint {
    return lean_to_closure(o).m_num_fixed;
}
pub fn lean_closure_cptr(o: LeanPtr) callconv(.c) [*]LeanPtr {
    return lean_to_closure(o).m_objs();
}
pub fn lean_alloc_closure(fun: ?*anyopaque, arity: c_uint, num_fixed: c_uint) callconv(.c) lean_obj_res {
    assert(@src(), arity > 0, "arity > 0");
    assert(@src(), num_fixed < arity, "num_fixed < arity");
    const o: *lean_closure_object = @ptrCast(@alignCast(lean_alloc_object(lean_usize_add_checked(@sizeOf(lean_closure_object), lean_usize_mul_checked(@sizeOf(*anyopaque), num_fixed)))));
    lean_set_st_header(@as(LeanPtr, @ptrCast(o)), LeanClosure, 0);
    o.m_fun = fun;
    o.m_arity = @truncate(arity);
    o.m_num_fixed = @truncate(num_fixed);
    return @as(LeanPtr, @ptrCast(o));
}
pub fn lean_closure_get(o: b_lean_obj_arg, i: c_uint) callconv(.c) b_lean_obj_res {
    assert(@src(), i < lean_closure_num_fixed(o), "i < lean_closure_num_fixed(o)");
    return lean_to_closure(o).m_objs()[i];
}
pub fn lean_closure_set(o: u_lean_obj_arg, i: c_uint, a: lean_obj_arg) callconv(.c) void {
    assert(@src(), i < lean_closure_num_fixed(o), "i < lean_closure_num_fixed(o)");
    lean_to_closure(o).m_objs()[i] = a;
}
pub extern fn lean_apply_1(f: LeanPtr, a1: LeanPtr) LeanPtr;
pub extern fn lean_apply_2(f: LeanPtr, a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_apply_3(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr) LeanPtr;
pub extern fn lean_apply_4(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr) LeanPtr;
pub extern fn lean_apply_5(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr) LeanPtr;
pub extern fn lean_apply_6(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr) LeanPtr;
pub extern fn lean_apply_7(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr) LeanPtr;
pub extern fn lean_apply_8(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr) LeanPtr;
pub extern fn lean_apply_9(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr) LeanPtr;
pub extern fn lean_apply_10(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr, a10: LeanPtr) LeanPtr;
pub extern fn lean_apply_11(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr, a10: LeanPtr, a11: LeanPtr) LeanPtr;
pub extern fn lean_apply_12(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr, a10: LeanPtr, a11: LeanPtr, a12: LeanPtr) LeanPtr;
pub extern fn lean_apply_13(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr, a10: LeanPtr, a11: LeanPtr, a12: LeanPtr, a13: LeanPtr) LeanPtr;
pub extern fn lean_apply_14(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr, a10: LeanPtr, a11: LeanPtr, a12: LeanPtr, a13: LeanPtr, a14: LeanPtr) LeanPtr;
pub extern fn lean_apply_15(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr, a10: LeanPtr, a11: LeanPtr, a12: LeanPtr, a13: LeanPtr, a14: LeanPtr, a15: LeanPtr) LeanPtr;
pub extern fn lean_apply_16(f: LeanPtr, a1: LeanPtr, a2: LeanPtr, a3: LeanPtr, a4: LeanPtr, a5: LeanPtr, a6: LeanPtr, a7: LeanPtr, a8: LeanPtr, a9: LeanPtr, a10: LeanPtr, a11: LeanPtr, a12: LeanPtr, a13: LeanPtr, a14: LeanPtr, a15: LeanPtr, a16: LeanPtr) LeanPtr;
pub extern fn lean_apply_n(f: LeanPtr, n: c_uint, args: [*]LeanPtr) LeanPtr;
pub extern fn lean_apply_m(f: LeanPtr, n: c_uint, args: [*]LeanPtr) LeanPtr;
pub fn lean_alloc_array(size: usize, capacity: usize) callconv(.c) lean_obj_res {
    const o: *lean_array_object = @ptrCast(@alignCast(lean_alloc_object(lean_usize_add_checked(@sizeOf(lean_array_object), lean_usize_mul_checked(@sizeOf(*anyopaque), capacity)))));
    lean_set_st_header(@as(LeanPtr, @ptrCast(o)), LeanArray, 0);
    o.m_size = size;
    o.m_capacity = capacity;
    return @as(LeanPtr, @ptrCast(o));
}
pub fn lean_array_size(o: b_lean_obj_arg) callconv(.c) usize {
    return lean_to_array(o).m_size;
}
pub fn lean_array_capacity(o: b_lean_obj_arg) callconv(.c) usize {
    return lean_to_array(o).m_capacity;
}
pub fn lean_array_byte_size(o: LeanPtr) callconv(.c) usize {
    return @sizeOf(lean_array_object) +% (@sizeOf(*anyopaque) *% lean_array_capacity(o));
}
pub fn lean_array_cptr(o: LeanPtr) callconv(.c) [*]LeanPtr {
    return lean_to_array(o).m_data();
}
pub fn lean_array_set_size(o: u_lean_obj_arg, sz: usize) callconv(.c) void {
    assert(@src(), lean_is_array(o), "lean_is_array(o)");
    assert(@src(), lean_is_exclusive(o), "lean_is_exclusive(o)");
    assert(@src(), sz <= lean_array_capacity(o), "sz <= lean_array_capacity(o)");
    lean_to_array(o).m_size = sz;
}
pub fn lean_array_get_core(o: b_lean_obj_arg, i: usize) callconv(.c) b_lean_obj_res {
    assert(@src(), i < lean_array_size(o), "i < lean_array_size(o)");
    return lean_to_array(o).m_data()[i];
}
pub fn lean_array_set_core(o: u_lean_obj_arg, i: usize, v: lean_obj_arg) callconv(.c) void {
    assert(@src(), !lean_has_rc(o) or lean_is_exclusive(o), "!lean_has_rc(o) || lean_is_exclusive(o)");
    assert(@src(), i < lean_array_size(o), "i < lean_array_size(o)");
    lean_to_array(o).m_data()[i] = v;
}
pub extern fn lean_array_mk(l: lean_obj_arg) LeanPtr;
pub extern fn lean_array_data(a: lean_obj_arg) LeanPtr;
pub fn lean_array_sz(a: lean_obj_arg) callconv(.c) LeanPtr {
    const r = lean_box(lean_array_size(a));
    lean_dec(a);
    return r;
}
pub fn lean_array_get_size(a: b_lean_obj_arg) callconv(.c) LeanPtr {
    return lean_box(lean_array_size(a));
}
pub fn lean_mk_empty_array() callconv(.c) LeanPtr {
    return lean_alloc_array(0, 0);
}
pub fn lean_mk_empty_array_with_capacity(capacity: b_lean_obj_arg) callconv(.c) LeanPtr {
    if (!lean_is_scalar(capacity)) {
        lean_internal_panic_out_of_memory();
    }
    return lean_alloc_array(0, lean_unbox(capacity));
}
pub fn lean_array_uget(a: b_lean_obj_arg, i: usize) callconv(.c) LeanPtr {
    const r = lean_array_get_core(a, i);
    lean_inc(r);
    return r;
}
pub fn lean_array_fget(a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_array_uget(a, lean_unbox(i));
}
pub extern fn lean_array_get_panic(def_val: lean_obj_arg) lean_obj_res;
pub fn lean_array_get(def_val: b_lean_obj_arg, a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) LeanPtr {
    if (lean_is_scalar(i)) {
        const idx = lean_unbox(i);
        if (idx < lean_array_size(a)) {
            return lean_array_uget(a, idx);
        }
    }
    lean_inc(def_val);
    return lean_array_get_panic(def_val);
}
pub extern fn lean_copy_expand_array(a: lean_obj_arg, expand: bool) lean_obj_res;
pub extern fn lean_copy_expand_array_nonlinear(a: lean_obj_arg, expand: bool) lean_obj_res;
pub fn lean_ensure_exclusive_array(a: lean_obj_arg) callconv(.c) lean_obj_res {
    if (lean_is_exclusive(a)) return a;
    return lean_copy_expand_array_nonlinear(a, false);
}
pub fn lean_array_uset(a: lean_obj_arg, i: usize, v: lean_obj_arg) callconv(.c) LeanPtr {
    const r = lean_ensure_exclusive_array(a);
    const it = lean_array_cptr(r);
    lean_dec(it[i]);
    it[i] = v;
    return r;
}
pub fn lean_array_fset(a: lean_obj_arg, i: b_lean_obj_arg, v: lean_obj_arg) callconv(.c) LeanPtr {
    return lean_array_uset(a, lean_unbox(i), v);
}
pub extern fn lean_array_set_panic(a: lean_obj_arg, v: lean_obj_arg) lean_obj_res;
pub fn lean_array_set(a: lean_obj_arg, i: b_lean_obj_arg, v: lean_obj_arg) callconv(.c) LeanPtr {
    if (lean_is_scalar(i)) {
        const idx = lean_unbox(i);
        if (idx < lean_array_size(a)) return lean_array_uset(a, idx, v);
    }
    return lean_array_set_panic(a, v);
}
pub fn lean_array_pop(a: lean_obj_arg) callconv(.c) LeanPtr {
    const r = lean_ensure_exclusive_array(a);
    var sz = lean_to_array(r).m_size;
    if (sz == 0) return r;
    sz -= 1;
    const last = lean_array_cptr(r) + sz;
    lean_to_array(r).m_size = sz;
    lean_dec(last[0]);
    return r;
}
pub fn lean_array_uswap(a: lean_obj_arg, i: usize, j: usize) callconv(.c) LeanPtr {
    const r = lean_ensure_exclusive_array(a);
    const it = lean_array_cptr(r);
    const v1 = it[i];
    it[i] = it[j];
    it[j] = v1;
    return r;
}
pub fn lean_array_fswap(a: lean_obj_arg, i: b_lean_obj_arg, j: b_lean_obj_arg) callconv(.c) LeanPtr {
    return lean_array_uswap(a, lean_unbox(i), lean_unbox(j));
}
pub fn lean_array_swap(a: lean_obj_arg, i: b_lean_obj_arg, j: b_lean_obj_arg) callconv(.c) LeanPtr {
    if (!lean_is_scalar(i) or !lean_is_scalar(j)) return a;
    const ui = lean_unbox(i);
    const uj = lean_unbox(j);
    const sz = lean_to_array(a).m_size;
    if ((ui >= sz) or (uj >= sz)) return a;
    return lean_array_uswap(a, ui, uj);
}
pub extern fn lean_array_push(a: lean_obj_arg, v: lean_obj_arg) LeanPtr;
pub extern fn lean_mk_array(n: lean_obj_arg, v: lean_obj_arg) LeanPtr;
pub fn lean_alloc_sarray(elem_size: c_uint, size: usize, capacity: usize) callconv(.c) lean_obj_res {
    const o: *lean_sarray_object = @ptrCast(@alignCast(lean_alloc_object(lean_usize_add_checked(@sizeOf(lean_sarray_object), lean_usize_mul_checked(elem_size, capacity)))));
    lean_set_st_header(@as(LeanPtr, @ptrCast(o)), LeanScalarArray, elem_size);
    o.m_size = size;
    o.m_capacity = capacity;
    return @as(LeanPtr, @ptrCast(o));
}
pub fn lean_sarray_elem_size(o: LeanPtr) callconv(.c) c_uint {
    assert(@src(), lean_is_sarray(o), "lean_is_sarray(o)");
    return lean_ptr_other(o);
}
pub fn lean_sarray_capacity(o: LeanPtr) callconv(.c) usize {
    return lean_to_sarray(o).m_capacity;
}
pub fn lean_sarray_byte_size(o: LeanPtr) callconv(.c) usize {
    return @sizeOf(lean_sarray_object) + lean_sarray_elem_size(o) * lean_sarray_capacity(o);
}
pub fn lean_sarray_size(o: b_lean_obj_arg) callconv(.c) usize {
    return lean_to_sarray(o).m_size;
}
pub fn lean_sarray_set_size(o: u_lean_obj_arg, sz: usize) callconv(.c) void {
    assert(@src(), lean_is_exclusive(o), "lean_is_exclusive(o)");
    assert(@src(), sz <= lean_sarray_capacity(o), "sz <= lean_sarray_capacity(o)");
    lean_to_sarray(o).m_size = sz;
}
pub fn lean_sarray_cptr(o: LeanPtr) callconv(.c) [*]u8 {
    return lean_to_sarray(o).m_data();
}
pub extern fn lean_byte_array_mk(a: lean_obj_arg) lean_obj_res;
pub extern fn lean_byte_array_data(a: lean_obj_arg) lean_obj_res;
pub extern fn lean_copy_byte_array(a: lean_obj_arg) lean_obj_res;
pub extern fn lean_byte_array_hash(a: b_lean_obj_arg) u64;
pub fn lean_mk_empty_byte_array(capacity: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (!lean_is_scalar(capacity)) {
        lean_internal_panic_out_of_memory();
    }
    return lean_alloc_sarray(1, 0, lean_unbox(capacity));
}
pub fn lean_byte_array_size(a: b_lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(lean_sarray_size(a));
}
pub fn lean_byte_array_uget(a: b_lean_obj_arg, i: usize) callconv(.c) u8 {
    assert(@src(), i < lean_sarray_size(a), "i < lean_sarray_size(a)");
    return lean_sarray_cptr(a)[i];
}
pub fn lean_byte_array_get(a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) u8 {
    if (lean_is_scalar(i)) {
        const idx = lean_unbox(i);
        if (idx < lean_sarray_size(a)) return lean_byte_array_uget(a, idx);
    }
    return 0;
}
pub fn lean_byte_array_fget(a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) u8 {
    return lean_byte_array_uget(a, lean_unbox(i));
}
pub extern fn lean_byte_array_push(a: lean_obj_arg, b: u8) lean_obj_res;
pub fn lean_byte_array_uset(a: lean_obj_arg, i: usize, v: u8) callconv(.c) LeanPtr {
    const r = if (lean_is_exclusive(a)) a else lean_copy_byte_array(a);
    lean_sarray_cptr(r)[i] = v;
    return r;
}
pub fn lean_byte_array_set(a: lean_obj_arg, i: b_lean_obj_arg, b: u8) callconv(.c) lean_obj_res {
    if (!lean_is_scalar(i)) {
        return a;
    } else {
        const idx = lean_unbox(i);
        if (idx >= lean_sarray_size(a)) {
            return a;
        } else {
            return lean_byte_array_uset(a, idx, b);
        }
    }
}
pub fn lean_byte_array_fset(a: lean_obj_arg, i: b_lean_obj_arg, b: u8) callconv(.c) lean_obj_res {
    return lean_byte_array_uset(a, lean_unbox(i), b);
}
pub extern fn lean_float_array_mk(a: lean_obj_arg) lean_obj_res;
pub extern fn lean_float_array_data(a: lean_obj_arg) lean_obj_res;
pub extern fn lean_copy_float_array(a: lean_obj_arg) lean_obj_res;
pub fn lean_mk_empty_float_array(capacity: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (!lean_is_scalar(capacity)) {
        lean_internal_panic_out_of_memory();
    }
    return lean_alloc_sarray(@sizeOf(f64), 0, lean_unbox(capacity));
}
pub fn lean_float_array_size(a: b_lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(lean_sarray_size(a));
}
pub fn lean_float_array_cptr(a: b_lean_obj_arg) callconv(.c) [*]f64 {
    return @ptrCast(@alignCast(lean_sarray_cptr(a)));
}
pub fn lean_float_array_uget(a: b_lean_obj_arg, i: usize) callconv(.c) f64 {
    return lean_float_array_cptr(a)[i];
}
pub fn lean_float_array_fget(a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) f64 {
    return lean_float_array_uget(a, lean_unbox(i));
}
pub fn lean_float_array_get(a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) f64 {
    if (lean_is_scalar(i)) {
        const idx = lean_unbox(i);
        if (idx < lean_sarray_size(a)) return lean_float_array_uget(a, idx);
    }
    return 0.0;
}
pub extern fn lean_float_array_push(a: lean_obj_arg, d: f64) lean_obj_res;
pub fn lean_float_array_uset(a: lean_obj_arg, i: usize, d: f64) callconv(.c) lean_obj_res {
    const r = if (lean_is_exclusive(a)) a else lean_copy_float_array(a);
    lean_float_array_cptr(r)[i] = d;
    return r;
}
pub fn lean_float_array_fset(a: lean_obj_arg, i: b_lean_obj_arg, d: f64) callconv(.c) lean_obj_res {
    return lean_float_array_uset(a, lean_unbox(i), d);
}
pub fn lean_float_array_set(a: lean_obj_arg, i: b_lean_obj_arg, d: f64) callconv(.c) lean_obj_res {
    if (!lean_is_scalar(i)) return a;
    const idx = lean_unbox(i);
    if (idx >= lean_sarray_size(a)) {
        return a;
    } else {
        return lean_float_array_uset(a, idx, d);
    }
}
pub fn lean_alloc_string(size: usize, capacity: usize, len: usize) callconv(.c) lean_obj_res {
    const o: *lean_string_object = @ptrCast(@alignCast(lean_alloc_object(lean_usize_add_checked(@sizeOf(lean_string_object), capacity))));
    lean_set_st_header(@as(LeanPtr, @ptrCast(o)), LeanString, 0);
    o.m_size = size;
    o.m_capacity = capacity;
    o.m_length = len;
    return @as(LeanPtr, @ptrCast(o));
}
pub extern fn lean_utf8_strlen(str: [*:0]const u8) usize;
pub extern fn lean_utf8_n_strlen(str: [*:0]const u8, n: usize) usize;
pub fn lean_string_capacity(o: LeanPtr) callconv(.c) usize {
    return lean_to_string(o).m_capacity;
}
pub fn lean_string_byte_size(o: LeanPtr) callconv(.c) usize {
    return @sizeOf(lean_string_object) +% lean_string_capacity(o);
}
pub fn lean_char_default_value() callconv(.c) u32 {
    return 'A';
}
pub extern fn lean_mk_string_from_bytes(s: [*:0]const u8, sz: usize) lean_obj_res;
pub extern fn lean_mk_string(s: [*:0]const u8) lean_obj_res;
pub fn lean_string_cstr(o: b_lean_obj_arg) callconv(.c) [*:0]const u8 {
    assert(@src(), lean_is_string(o), "lean_is_string(o)");
    return lean_to_string(o).m_data();
}
pub fn lean_string_size(o: b_lean_obj_arg) callconv(.c) usize {
    return lean_to_string(o).m_size;
}
pub fn lean_string_len(o: b_lean_obj_arg) callconv(.c) usize {
    return lean_to_string(o).m_length;
}
pub extern fn lean_string_push(s: lean_obj_arg, c: u32) lean_obj_res;
pub extern fn lean_string_append(s1: lean_obj_arg, s2: b_lean_obj_arg) lean_obj_res;
pub fn lean_string_length(s: b_lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(lean_string_len(s));
}
pub extern fn lean_string_mk(cs: lean_obj_arg) lean_obj_res;
pub extern fn lean_string_data(s: lean_obj_arg) lean_obj_res;
pub extern fn lean_string_utf8_get(s: b_lean_obj_arg, i: b_lean_obj_arg) u32;
pub extern fn lean_string_utf8_get_fast_cold(str: [*:0]const u8, i: usize, size: usize, c: u8) u32;
pub fn lean_string_utf8_get_fast(s: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) u32 {
    const str = lean_string_cstr(s);
    const idx = lean_unbox(i);
    const c = str[idx];
    if (c & 0x80 == 0) return c;
    return lean_string_utf8_get_fast_cold(str, idx, lean_string_size(s), c);
}
pub extern fn lean_string_utf8_next(s: b_lean_obj_arg, i: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_string_utf8_next_fast_cold(i: usize, c: u8) lean_obj_res;
pub fn lean_string_utf8_next_fast(s: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) lean_obj_res {
    const str = lean_string_cstr(s);
    const idx = lean_unbox(i);
    const c = str[idx];
    if (c & 0x80 == 0) return lean_box(idx + 1);
    return lean_string_utf8_next_fast_cold(idx, c);
}
pub extern fn lean_string_utf8_prev(s: b_lean_obj_arg, i: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_string_utf8_set(s: lean_obj_arg, i: b_lean_obj_arg, c: u32) lean_obj_res;
pub fn lean_string_utf8_at_end(s: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(!lean_is_scalar(i) or (lean_unbox(i) >= lean_string_size(s) - 1));
}
pub extern fn lean_string_utf8_extract(s: b_lean_obj_arg, b: b_lean_obj_arg, e: b_lean_obj_arg) lean_obj_res;
pub fn lean_string_utf8_byte_size(s: b_lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(lean_string_size(s) - 1);
}
pub extern fn lean_string_eq_cold(s1: b_lean_obj_arg, s2: b_lean_obj_arg) bool;
pub fn lean_string_eq(s1: b_lean_obj_arg, s2: b_lean_obj_arg) callconv(.c) bool {
    return s1 == s2 or (lean_string_size(s1) == lean_string_size(s2) and lean_string_eq_cold(s1, s2));
}
pub fn lean_string_ne(s1: b_lean_obj_arg, s2: b_lean_obj_arg) callconv(.c) bool {
    return !lean_string_eq(s1, s2);
}
pub extern fn lean_string_lt(s1: b_lean_obj_arg, s2: b_lean_obj_arg) bool;
pub fn lean_string_dec_eq(s1: b_lean_obj_arg, s2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_string_eq(s1, s2));
}
pub fn lean_string_dec_lt(s1: b_lean_obj_arg, s2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_string_lt(s1, s2));
}
pub extern fn lean_string_hash(b_lean_obj_arg) u64;
pub fn lean_mk_thunk(c: lean_obj_arg) callconv(.c) lean_obj_res {
    const o: *lean_thunk_object = @ptrCast(@alignCast(lean_alloc_small_object(@sizeOf(lean_thunk_object))));
    lean_set_st_header(@as(LeanPtr, @ptrCast(o)), LeanThunk, 0);
    o.m_value = null;
    o.m_closure = c;
    return @as(LeanPtr, @ptrCast(o));
}
pub fn lean_thunk_pure(v: lean_obj_arg) callconv(.c) lean_obj_res {
    const o: *lean_thunk_object = @ptrCast(@alignCast(lean_alloc_small_object(@sizeOf(lean_thunk_object))));
    lean_set_st_header(@as(LeanPtr, @ptrCast(o)), LeanThunk, 0);
    o.m_value = v;
    o.m_closure = null;
    return @as(LeanPtr, @ptrCast(o));
}
pub extern fn lean_thunk_get_core(t: LeanPtr) LeanPtr;
pub fn lean_thunk_get(t: b_lean_obj_arg) callconv(.c) b_lean_obj_res {
    const r = @atomicLoad(?LeanPtr, &lean_to_thunk(t).m_value, std.builtin.AtomicOrder.seq_cst);
    return r orelse lean_thunk_get_core(t);
}
pub fn lean_thunk_get_own(t: b_lean_obj_arg) callconv(.c) lean_obj_res {
    const r = lean_thunk_get(t);
    lean_inc(r);
    return r;
}
pub extern fn lean_init_task_manager() void;
pub extern fn lean_init_task_manager_using(num_workers: c_uint) void;
pub extern fn lean_finalize_task_manager() void;
pub extern fn lean_task_spawn_core(c: lean_obj_arg, prio: c_uint, keep_alive: bool) lean_obj_res;
pub fn lean_task_spawn(c: lean_obj_arg, prio: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_task_spawn_core(c, @intCast(lean_unbox(prio)), false);
}
pub extern fn lean_task_pure(a: lean_obj_arg) lean_obj_res;
pub extern fn lean_task_bind_core(x: lean_obj_arg, f: lean_obj_arg, prio: c_uint, sync: bool, keep_alive: bool) lean_obj_res;
pub fn lean_task_bind(x: lean_obj_arg, f: lean_obj_arg, prio: lean_obj_arg, sync: u8) callconv(.c) lean_obj_res {
    return lean_task_bind_core(x, f, @intCast(lean_unbox(prio)), sync != 0, false);
}
pub extern fn lean_task_map_core(f: lean_obj_arg, t: lean_obj_arg, prio: c_uint, sync: bool, keep_alive: bool) lean_obj_res;
pub fn lean_task_map(f: lean_obj_arg, t: lean_obj_arg, prio: lean_obj_arg, sync: u8) callconv(.c) lean_obj_res {
    return lean_task_map_core(f, t, @intCast(lean_unbox(prio)), sync != 0, false);
}
pub extern fn lean_task_get(t: b_lean_obj_arg) b_lean_obj_res;
pub fn lean_task_get_own(t: lean_obj_arg) callconv(.c) lean_obj_res {
    const r = lean_task_get(t);
    lean_inc(r);
    lean_dec(t);
    return r;
}
pub extern fn lean_io_check_canceled_core() bool;
pub extern fn lean_io_cancel_core(t: b_lean_obj_arg) void;
pub extern fn lean_io_has_finished_core(t: b_lean_obj_arg) bool;
pub extern fn lean_io_wait_any_core(task_list: b_lean_obj_arg) b_lean_obj_res;
pub fn lean_alloc_external(cls: [*c]lean_external_class, data: ?*anyopaque) callconv(.c) LeanPtr {
    const o: *lean_external_object = @ptrCast(@alignCast(lean_alloc_small_object(@sizeOf(lean_external_object))));
    lean_set_st_header(@as(LeanPtr, @ptrCast(o)), LeanExternal, 0);
    o.m_class = cls;
    o.m_data = data;
    return @as(LeanPtr, @ptrCast(o));
}
pub fn lean_get_external_class(o: LeanPtr) callconv(.c) *lean_external_class {
    return lean_to_external(o).m_class;
}
pub fn lean_get_external_data(o: LeanPtr) callconv(.c) ?*anyopaque {
    return lean_to_external(o).m_data;
}

pub const LEAN_MAX_SMALL_NAT = std.math.maxInt(c_int) >> 1;

pub extern fn lean_nat_big_succ(a: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_add(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_sub(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_mul(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_overflow_mul(a1: usize, a2: usize) LeanPtr;
pub extern fn lean_nat_big_div(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_mod(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_eq(a1: LeanPtr, a2: LeanPtr) bool;
pub extern fn lean_nat_big_le(a1: LeanPtr, a2: LeanPtr) bool;
pub extern fn lean_nat_big_lt(a1: LeanPtr, a2: LeanPtr) bool;
pub extern fn lean_nat_big_land(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_lor(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_xor(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_cstr_to_nat(n: [*:0]const u8) lean_obj_res;
pub extern fn lean_big_usize_to_nat(n: usize) lean_obj_res;
pub extern fn lean_big_uint64_to_nat(n: u64) lean_obj_res;
pub fn lean_usize_to_nat(n: usize) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(n <= LEAN_MAX_SMALL_NAT))
        return lean_box(n)
    else
        return lean_big_usize_to_nat(n);
}
pub fn lean_unsigned_to_nat(n: c_uint) callconv(.c) lean_obj_res {
    return lean_usize_to_nat(@intCast(n));
}
pub fn lean_uint64_to_nat(n: u64) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(n <= LEAN_MAX_SMALL_NAT))
        return lean_box(n)
    else
        return lean_big_uint64_to_nat(n);
}
pub fn lean_nat_succ(a: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a)))
        return lean_usize_to_nat(lean_unbox(a) + 1)
    else
        return lean_nat_big_succ(a);
}
pub fn lean_nat_add(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2)))
        return lean_usize_to_nat(lean_unbox(a1) + lean_unbox(a2))
    else
        return lean_nat_big_add(a1, a2);
}
pub fn lean_nat_sub(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const n1 = lean_unbox(a1);
        const n2 = lean_unbox(a2);
        if (n1 < n2)
            return lean_box(0)
        else
            return lean_box(n1 - n2);
    } else {
        return lean_nat_big_sub(a1, a2);
    }
}
pub fn lean_nat_mul(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const n1 = lean_unbox(a1);
        if (n1 == 0) return a1;
        const n2 = lean_unbox(a2);
        const r = n1 *% n2;
        if (r <= LEAN_MAX_SMALL_NAT and r / n1 == n2)
            return lean_box(r)
        else
            return lean_nat_overflow_mul(n1, n2);
    } else {
        return lean_nat_big_mul(a1, a2);
    }
}
pub fn lean_nat_div(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const n1 = lean_unbox(a1);
        const n2 = lean_unbox(a2);
        if (n2 == 0) return lean_box(0) else return lean_box(n1 / n2);
    } else {
        return lean_nat_big_div(a1, a2);
    }
}
pub fn lean_nat_mod(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const n1 = lean_unbox(a1);
        const n2 = lean_unbox(a2);
        if (n2 == 0) return lean_box(n1) else return lean_box(n1 % n2);
    } else {
        return lean_nat_big_mod(a1, a2);
    }
}
pub fn lean_nat_eq(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return a1 == a2;
    } else {
        return lean_nat_big_eq(a1, a2);
    }
    return false;
}
pub fn lean_nat_dec_eq(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_nat_eq(a1, a2));
}
pub fn lean_nat_ne(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    return !lean_nat_eq(a1, a2);
}
pub fn lean_nat_le(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return @intFromPtr(a1) <= @intFromPtr(a2);
    } else {
        return lean_nat_big_le(a1, a2);
    }
    return false;
}
pub fn lean_nat_dec_le(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_nat_le(a1, a2));
}
pub fn lean_nat_lt(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return @intFromPtr(a1) < @intFromPtr(a2);
    } else {
        return lean_nat_big_lt(a1, a2);
    }
    return false;
}
pub fn lean_nat_dec_lt(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_nat_lt(a1, a2));
}
pub fn lean_nat_land(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return @ptrFromInt(@intFromPtr(a1) & @intFromPtr(a2));
    } else {
        return lean_nat_big_land(a1, a2);
    }
}
pub fn lean_nat_lor(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return @ptrFromInt(@intFromPtr(a1) | @intFromPtr(a2));
    } else {
        return lean_nat_big_lor(a1, a2);
    }
}
pub fn lean_nat_lxor(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return lean_box(lean_unbox(a1) ^ lean_unbox(a2));
    } else {
        return lean_nat_big_xor(a1, a2);
    }
}
pub extern fn lean_nat_shiftl(a1: b_lean_obj_arg, a2: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_nat_shiftr(a1: b_lean_obj_arg, a2: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_nat_pow(a1: b_lean_obj_arg, a2: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_nat_gcd(a1: b_lean_obj_arg, a2: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_nat_log2(a: b_lean_obj_arg) lean_obj_res;

pub const LEAN_MAX_SMALL_INT = if (@sizeOf(*anyopaque) == 8) std.math.maxInt(c_int) else std.math.maxInt(c_int) >> 1;
pub const LEAN_MIN_SMALL_INT = if (@sizeOf(*anyopaque) == 8) std.math.minInt(c_int) else std.math.minInt(c_int) >> 1;
pub extern fn lean_int_big_neg(a: LeanPtr) LeanPtr;
pub extern fn lean_int_big_add(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int_big_sub(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int_big_mul(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int_big_div(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int_big_mod(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int_big_eq(a1: LeanPtr, a2: LeanPtr) bool;
pub extern fn lean_int_big_le(a1: LeanPtr, a2: LeanPtr) bool;
pub extern fn lean_int_big_lt(a1: LeanPtr, a2: LeanPtr) bool;
pub extern fn lean_int_big_nonneg(a: LeanPtr) bool;
pub extern fn lean_cstr_to_int(n: [*:0]const u8) LeanPtr;
pub extern fn lean_big_int_to_int(n: c_int) LeanPtr;
pub extern fn lean_big_size_t_to_int(n: usize) LeanPtr;
pub extern fn lean_big_int64_to_int(n: i64) LeanPtr;
pub fn lean_int_to_int(n: c_int) callconv(.c) lean_obj_res {
    if (@sizeOf(*anyopaque) == 8)
        return lean_box(@as(c_uint, @bitCast(n)))
    else if (LEAN_LIKELY(LEAN_MIN_SMALL_INT <= n and n <= LEAN_MAX_SMALL_INT))
        return lean_box(@as(c_uint, @bitCast(n)))
    else
        return lean_big_int_to_int(n);
}
pub fn lean_int64_to_int(n: i64) callconv(.c) lean_obj_res {
    // scalar Ints are stored as zero-extended 32-bit patterns: (unsigned)(int)n
    if (LEAN_LIKELY(LEAN_MIN_SMALL_INT <= n and n <= LEAN_MAX_SMALL_INT))
        return lean_box(@as(u32, @bitCast(@as(i32, @intCast(n)))))
    else
        return lean_big_int64_to_int(n);
}
pub fn lean_scalar_to_int64(a: b_lean_obj_arg) callconv(.c) i64 {
    assert(@src(), lean_is_scalar(a), "lean_is_scalar(a)");
    if (@sizeOf(*anyopaque) == 8)
        // (int)((unsigned)lean_unbox(a)): truncate to 32 bits, then sign-extend
        return @as(i32, @bitCast(@as(u32, @truncate(lean_unbox(a)))))
    else
        return @intCast(@as(isize, @bitCast(@intFromPtr(a))) >> 1);
}
pub fn lean_scalar_to_int(a: b_lean_obj_arg) callconv(.c) c_int {
    assert(@src(), lean_is_scalar(a), "lean_is_scalar(a)");
    if (@sizeOf(*anyopaque) == 8)
        return @as(i32, @bitCast(@as(u32, @truncate(lean_unbox(a)))))
    else
        return @intCast(@as(isize, @bitCast(@intFromPtr(a))) >> 1);
}
pub fn lean_nat_to_int(a: lean_obj_arg) callconv(.c) lean_obj_res {
    if (lean_is_scalar(a)) {
        const v = lean_unbox(a);
        if (v <= LEAN_MAX_SMALL_INT) return a else return lean_big_size_t_to_int(v);
    } else {
        return a;
    }
}
pub fn lean_int_neg(a: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a))) {
        return lean_int64_to_int(-lean_scalar_to_int64(a));
    } else {
        return lean_int_big_neg(a);
    }
}
pub fn lean_int_neg_succ_of_nat(a: lean_obj_arg) callconv(.c) lean_obj_res {
    const s = lean_nat_succ(a);
    lean_dec(a);
    const i = lean_nat_to_int(s);
    const r = lean_int_neg(i);
    lean_dec(i);
    return r;
}
pub fn lean_int_add(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return lean_int64_to_int(lean_scalar_to_int64(a1) + lean_scalar_to_int64(a2));
    } else {
        return lean_int_big_add(a1, a2);
    }
}
pub fn lean_int_sub(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return lean_int64_to_int(lean_scalar_to_int64(a1) - lean_scalar_to_int64(a2));
    } else {
        return lean_int_big_sub(a1, a2);
    }
}
pub fn lean_int_mul(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return lean_int64_to_int(lean_scalar_to_int64(a1) * lean_scalar_to_int64(a2));
    } else {
        return lean_int_big_mul(a1, a2);
    }
}
pub fn lean_int_div(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        if (@sizeOf(*anyopaque) == 8) {
            const v1: i64 = lean_scalar_to_int(a1);
            const v2: i64 = lean_scalar_to_int(a2);
            if (v2 == 0) return lean_box(0) else return lean_int64_to_int(@divTrunc(v1, v2));
        } else {
            const v1 = lean_scalar_to_int(a1);
            const v2 = lean_scalar_to_int(a2);
            if (v2 == 0) return lean_box(0) else return lean_int_to_int(@divTrunc(v1, v2));
        }
    } else {
        return lean_int_big_div(a1, a2);
    }
}
pub fn lean_int_mod(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        if (@sizeOf(*anyopaque) == 8) {
            const v1: i64 = lean_scalar_to_int64(a1);
            const v2: i64 = lean_scalar_to_int64(a2);
            if (v2 == 0) return a1 else return lean_int64_to_int(std.zig.c_translation.helpers.signedRemainder(v1, v2));
        } else {
            const v1 = lean_scalar_to_int(a1);
            const v2 = lean_scalar_to_int(a2);
            if (v2 == 0) return a1 else return lean_int_to_int(std.zig.c_translation.helpers.signedRemainder(v1, v2));
        }
    } else {
        return lean_int_big_mod(a1, a2);
    }
}
pub fn lean_int_eq(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return a1 == a2;
    } else {
        return lean_int_big_eq(a1, a2);
    }
    return false;
}
pub fn lean_int_ne(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    return !lean_int_eq(a1, a2);
}
pub fn lean_int_le(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return lean_scalar_to_int(a1) <= lean_scalar_to_int(a2);
    } else {
        return lean_int_big_le(a1, a2);
    }
    return false;
}
pub fn lean_int_lt(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) bool {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        return lean_scalar_to_int(a1) < lean_scalar_to_int(a2);
    } else {
        return lean_int_big_lt(a1, a2);
    }
    return false;
}
pub extern fn lean_big_int_to_nat(a: lean_obj_arg) lean_obj_res;
pub fn lean_int_to_nat(a: lean_obj_arg) callconv(.c) lean_obj_res {
    assert(@src(), !lean_int_lt(a, lean_box(0)), "!lean_int_lt(a, lean_box(0))");
    if (lean_is_scalar(a)) {
        return a;
    } else {
        return lean_big_int_to_nat(a);
    }
}
pub fn lean_nat_abs(i: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (lean_int_lt(i, lean_box(0))) {
        return lean_int_to_nat(lean_int_neg(i));
    } else {
        lean_inc(i);
        return lean_int_to_nat(i);
    }
}
pub fn lean_int_dec_eq(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_int_eq(a1, a2));
}
pub fn lean_int_dec_le(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_int_le(a1, a2));
}
pub fn lean_int_dec_lt(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) u8 {
    return @intFromBool(lean_int_lt(a1, a2));
}
pub fn lean_int_dec_nonneg(a: b_lean_obj_arg) callconv(.c) u8 {
    if (LEAN_LIKELY(lean_is_scalar(a)))
        return @intFromBool(lean_scalar_to_int(a) >= 0)
    else
        return @intFromBool(lean_int_big_nonneg(a));
}
pub fn lean_bool_to_uint64(a: u8) callconv(.c) u64 {
    return a;
}
pub extern fn lean_uint8_of_big_nat(a: b_lean_obj_arg) u8;
pub fn lean_uint8_of_nat(a: b_lean_obj_arg) callconv(.c) u8 {
    if (@as(c_int, @intFromBool(lean_is_scalar(a))) != 0)
        return @truncate(lean_unbox(a))
    else
        return lean_uint8_of_big_nat(a);
}
pub fn lean_uint8_of_nat_mk(a: lean_obj_arg) callconv(.c) u8 {
    const r = lean_uint8_of_nat(a);
    lean_dec(a);
    return r;
}
pub fn lean_uint8_to_nat(a: u8) callconv(.c) lean_obj_res {
    return lean_usize_to_nat(a);
}
pub fn lean_uint8_add(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 +% a2;
}
pub fn lean_uint8_sub(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 -% a2;
}
pub fn lean_uint8_mul(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 *% a2;
}
pub fn lean_uint8_div(a1: u8, a2: u8) callconv(.c) u8 {
    return if (a2 == 0) 0 else a1 / a2;
}
pub fn lean_uint8_mod(a1: u8, a2: u8) callconv(.c) u8 {
    return if (a2 == 0) a1 else a1 % a2;
}
pub fn lean_uint8_land(a: u8, b: u8) callconv(.c) u8 {
    return a & b;
}
pub fn lean_uint8_lor(a: u8, b: u8) callconv(.c) u8 {
    return a | b;
}
pub fn lean_uint8_xor(a: u8, b: u8) callconv(.c) u8 {
    return a ^ b;
}
pub fn lean_uint8_shift_left(a: u8, b: u8) callconv(.c) u8 {
    return a << @truncate(b);
}
pub fn lean_uint8_shift_right(a: u8, b: u8) callconv(.c) u8 {
    return a >> @truncate(b);
}
pub fn lean_uint8_complement(a: u8) callconv(.c) u8 {
    return ~a;
}
pub fn lean_uint8_log2(x: u8) callconv(.c) u8 {
    var res: u8 = 0;
    var a = x;
    while (a >= 2) {
        res += 1;
        a /= 2;
    }
    return res;
}
pub fn lean_uint8_dec_eq(a1: u8, a2: u8) callconv(.c) u8 {
    return @intFromBool(a1 == a2);
}
pub fn lean_uint8_dec_lt(a1: u8, a2: u8) callconv(.c) u8 {
    return @intFromBool(a1 < a2);
}
pub fn lean_uint8_dec_le(a1: u8, a2: u8) callconv(.c) u8 {
    return @intFromBool(a1 <= a2);
}
pub fn lean_uint8_to_uint16(a: u8) callconv(.c) u16 {
    return a;
}
pub fn lean_uint8_to_uint32(a: u8) callconv(.c) u32 {
    return a;
}
pub fn lean_uint8_to_uint64(a: u8) callconv(.c) u64 {
    return a;
}
pub extern fn lean_uint16_of_big_nat(a: b_lean_obj_arg) u16;
pub fn lean_uint16_of_nat(a: b_lean_obj_arg) callconv(.c) u16 {
    if (@as(c_int, @intFromBool(lean_is_scalar(a))) != 0)
        return @truncate(lean_unbox(a))
    else
        return lean_uint16_of_big_nat(a);
}
pub fn lean_uint16_of_nat_mk(a: lean_obj_arg) callconv(.c) u16 {
    const r = lean_uint16_of_nat(a);
    lean_dec(a);
    return r;
}
pub fn lean_uint16_to_nat(a: u16) callconv(.c) lean_obj_res {
    return lean_usize_to_nat(a);
}
pub fn lean_uint16_add(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 +% a2;
}
pub fn lean_uint16_sub(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 -% a2;
}
pub fn lean_uint16_mul(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 *% a2;
}
pub fn lean_uint16_div(a1: u16, a2: u16) callconv(.c) u16 {
    return if (a2 == 0) 0 else a1 / a2;
}
pub fn lean_uint16_mod(a1: u16, a2: u16) callconv(.c) u16 {
    return if (a2 == 0) a1 else a1 % a2;
}
pub fn lean_uint16_land(a: u16, b: u16) callconv(.c) u16 {
    return a & b;
}
pub fn lean_uint16_lor(a: u16, b: u16) callconv(.c) u16 {
    return a | b;
}
pub fn lean_uint16_xor(a: u16, b: u16) callconv(.c) u16 {
    return a ^ b;
}
pub fn lean_uint16_shift_left(a: u16, b: u16) callconv(.c) u16 {
    return a << @truncate(b);
}
pub fn lean_uint16_shift_right(a: u16, b: u16) callconv(.c) u16 {
    return a >> @truncate(b);
}
pub fn lean_uint16_complement(a: u16) callconv(.c) u16 {
    return ~a;
}
pub fn lean_uint16_log2(x: u16) callconv(.c) u16 {
    var res: u16 = 0;
    var a = x;
    while (a >= 2) {
        res += 1;
        a /= 2;
    }
    return res;
}
pub fn lean_uint16_dec_eq(a1: u16, a2: u16) callconv(.c) u8 {
    return @intFromBool(a1 == a2);
}
pub fn lean_uint16_dec_lt(a1: u16, a2: u16) callconv(.c) u8 {
    return @intFromBool(a1 < a2);
}
pub fn lean_uint16_dec_le(a1: u16, a2: u16) callconv(.c) u8 {
    return @intFromBool(a1 <= a2);
}
pub fn lean_uint16_to_uint8(a: u16) callconv(.c) u8 {
    return @truncate(a);
}
pub fn lean_uint16_to_uint32(a: u16) callconv(.c) u32 {
    return a;
}
pub fn lean_uint16_to_uint64(a: u16) callconv(.c) u64 {
    return a;
}
pub extern fn lean_uint32_of_big_nat(a: b_lean_obj_arg) u32;
pub fn lean_uint32_of_nat(a: b_lean_obj_arg) callconv(.c) u32 {
    if (lean_is_scalar(a))
        return @truncate(lean_unbox(a))
    else
        return lean_uint32_of_big_nat(a);
}
pub fn lean_uint32_of_nat_mk(a: lean_obj_arg) callconv(.c) u32 {
    const r = lean_uint32_of_nat(a);
    lean_dec(a);
    return r;
}
pub fn lean_uint32_to_nat(a: u32) callconv(.c) lean_obj_res {
    return lean_usize_to_nat(a);
}
pub fn lean_uint32_add(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 +% a2;
}
pub fn lean_uint32_sub(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 -% a2;
}
pub fn lean_uint32_mul(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 *% a2;
}
pub fn lean_uint32_div(a1: u32, a2: u32) callconv(.c) u32 {
    return if (a2 == 0) 0 else a1 / a2;
}
pub fn lean_uint32_mod(a1: u32, a2: u32) callconv(.c) u32 {
    return if (a2 == 0) a1 else a1 % a2;
}
pub fn lean_uint32_land(a: u32, b: u32) callconv(.c) u32 {
    return a & b;
}
pub fn lean_uint32_lor(a: u32, b: u32) callconv(.c) u32 {
    return a | b;
}
pub fn lean_uint32_xor(a: u32, b: u32) callconv(.c) u32 {
    return a ^ b;
}
pub fn lean_uint32_shift_left(a: u32, b: u32) callconv(.c) u32 {
    return a << @truncate(b);
}
pub fn lean_uint32_shift_right(a: u32, b: u32) callconv(.c) u32 {
    return a >> @truncate(b);
}
pub fn lean_uint32_complement(a: u32) callconv(.c) u32 {
    return ~a;
}
pub fn lean_uint32_log2(x: u32) callconv(.c) u32 {
    var res: u32 = 0;
    var a = x;
    while (a >= 2) {
        res += 1;
        a /= 2;
    }
    return res;
}
pub fn lean_uint32_dec_eq(a1: u32, a2: u32) callconv(.c) u8 {
    return @intFromBool(a1 == a2);
}
pub fn lean_uint32_dec_lt(a1: u32, a2: u32) callconv(.c) u8 {
    return @intFromBool(a1 < a2);
}
pub fn lean_uint32_dec_le(a1: u32, a2: u32) callconv(.c) u8 {
    return @intFromBool(a1 <= a2);
}
pub fn lean_uint32_to_uint8(a: u32) callconv(.c) u8 {
    return @truncate(a);
}
pub fn lean_uint32_to_uint16(a: u32) callconv(.c) u16 {
    return @truncate(a);
}
pub fn lean_uint32_to_uint64(a: u32) callconv(.c) u64 {
    return a;
}
pub fn lean_uint32_to_usize(a: u32) callconv(.c) usize {
    return a;
}
pub extern fn lean_uint64_of_big_nat(a: b_lean_obj_arg) u64;
pub fn lean_uint64_of_nat(a: b_lean_obj_arg) callconv(.c) u64 {
    if (lean_is_scalar(a))
        return lean_unbox(a)
    else
        return lean_uint64_of_big_nat(a);
}
pub fn lean_uint64_of_nat_mk(a: lean_obj_arg) callconv(.c) u64 {
    const r = lean_uint64_of_nat(a);
    lean_dec(a);
    return r;
}
pub fn lean_uint64_add(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 +% a2;
}
pub fn lean_uint64_sub(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 -% a2;
}
pub fn lean_uint64_mul(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 *% a2;
}
pub fn lean_uint64_div(a1: u64, a2: u64) callconv(.c) u64 {
    return if (a2 == 0) 0 else a1 / a2;
}
pub fn lean_uint64_mod(a1: u64, a2: u64) callconv(.c) u64 {
    return if (a2 == 0) a1 else a1 % a2;
}
pub fn lean_uint64_land(a: u64, b: u64) callconv(.c) u64 {
    return a & b;
}
pub fn lean_uint64_lor(a: u64, b: u64) callconv(.c) u64 {
    return a | b;
}
pub fn lean_uint64_xor(a: u64, b: u64) callconv(.c) u64 {
    return a ^ b;
}
pub fn lean_uint64_shift_left(a: u64, b: u64) callconv(.c) u64 {
    return a << @truncate(b);
}
pub fn lean_uint64_shift_right(a: u64, b: u64) callconv(.c) u64 {
    return a >> @truncate(b);
}
pub fn lean_uint64_complement(a: u64) callconv(.c) u64 {
    return ~a;
}
pub fn lean_uint64_log2(x: u64) callconv(.c) u64 {
    var res: u64 = 0;
    var a = x;
    while (a >= 2) {
        res += 1;
        a /= 2;
    }
    return res;
}
pub fn lean_uint64_dec_eq(a1: u64, a2: u64) callconv(.c) u8 {
    return @intFromBool(a1 == a2);
}
pub fn lean_uint64_dec_lt(a1: u64, a2: u64) callconv(.c) u8 {
    return @intFromBool(a1 < a2);
}
pub fn lean_uint64_dec_le(a1: u64, a2: u64) callconv(.c) u8 {
    return @intFromBool(a1 <= a2);
}
pub extern fn lean_uint64_mix_hash(a1: u64, a2: u64) u64;
pub fn lean_uint64_to_uint8(a: u64) callconv(.c) u8 {
    return @truncate(a);
}
pub fn lean_uint64_to_uint16(a: u64) callconv(.c) u16 {
    return @truncate(a);
}
pub fn lean_uint64_to_uint32(a: u64) callconv(.c) u32 {
    return @truncate(a);
}
pub fn lean_uint64_to_usize(a: u64) callconv(.c) usize {
    return @truncate(a);
}
pub extern fn lean_usize_of_big_nat(a: b_lean_obj_arg) usize;
pub fn lean_usize_of_nat(a: b_lean_obj_arg) callconv(.c) usize {
    if (lean_is_scalar(a))
        return @truncate(lean_unbox(a))
    else
        return lean_usize_of_big_nat(a);
}
pub fn lean_usize_of_nat_mk(a: lean_obj_arg) callconv(.c) usize {
    const r = lean_usize_of_nat(a);
    lean_dec(a);
    return r;
}
pub fn lean_usize_add(a1: usize, a2: usize) callconv(.c) usize {
    return a1 +% a2;
}
pub fn lean_usize_sub(a1: usize, a2: usize) callconv(.c) usize {
    return a1 -% a2;
}
pub fn lean_usize_mul(a1: usize, a2: usize) callconv(.c) usize {
    return a1 *% a2;
}
pub fn lean_usize_div(a1: usize, a2: usize) callconv(.c) usize {
    return if (a2 == 0) 0 else a1 / a2;
}
pub fn lean_usize_mod(a1: usize, a2: usize) callconv(.c) usize {
    return if (a2 == 0) a1 else a1 % a2;
}
pub fn lean_usize_land(a: usize, b: usize) callconv(.c) usize {
    return a & b;
}
pub fn lean_usize_lor(a: usize, b: usize) callconv(.c) usize {
    return a | b;
}
pub fn lean_usize_xor(a: usize, b: usize) callconv(.c) usize {
    return a ^ b;
}
pub fn lean_usize_shift_left(a: usize, b: usize) callconv(.c) usize {
    return a << @truncate(b);
}
pub fn lean_usize_shift_right(a: usize, b: usize) callconv(.c) usize {
    return a >> @truncate(b);
}
pub fn lean_usize_complement(a: usize) callconv(.c) usize {
    return ~a;
}
pub fn lean_usize_log2(x: usize) callconv(.c) usize {
    var res: usize = 0;
    var a = x;
    while (a >= 2) {
        res += 1;
        a /= 2;
    }
    return res;
}
pub fn lean_usize_dec_eq(a1: usize, a2: usize) callconv(.c) u8 {
    return @intFromBool(a1 == a2);
}
pub fn lean_usize_dec_lt(a1: usize, a2: usize) callconv(.c) u8 {
    return @intFromBool(a1 < a2);
}
pub fn lean_usize_dec_le(a1: usize, a2: usize) callconv(.c) u8 {
    return @intFromBool(a1 <= a2);
}
pub fn lean_usize_to_uint32(a: usize) callconv(.c) u32 {
    return @truncate(a);
}
pub fn lean_usize_to_uint64(a: usize) callconv(.c) u64 {
    return a;
}
pub extern fn lean_float_to_string(a: f64) lean_obj_res;
pub extern fn lean_float_scaleb(a: f64, b: b_lean_obj_arg) f64;
pub extern fn lean_float_isnan(a: f64) u8;
pub extern fn lean_float_isfinite(a: f64) u8;
pub extern fn lean_float_isinf(a: f64) u8;
pub extern fn lean_float_frexp(a: f64) lean_obj_res;
pub fn lean_box_uint32(v: u32) callconv(.c) lean_obj_res {
    if (@sizeOf(*anyopaque) == 4) {
        const r = lean_alloc_ctor(0, 0, @sizeOf(u32));
        lean_ctor_set_uint32(r, 0, v);
        return r;
    } else {
        return lean_box(v);
    }
}
pub fn lean_unbox_uint32(o: b_lean_obj_arg) callconv(.c) c_uint {
    if (@sizeOf(*anyopaque) == 4) {
        return lean_ctor_get_uint32(o, 0);
    } else {
        return @truncate(lean_unbox(o));
    }
}
pub fn lean_box_uint64(v: u64) callconv(.c) lean_obj_res {
    const r = lean_alloc_ctor(0, 0, @sizeOf(u64));
    lean_ctor_set_uint64(r, 0, v);
    return r;
}
pub fn lean_unbox_uint64(o: b_lean_obj_arg) callconv(.c) u64 {
    return lean_ctor_get_uint64(o, 0);
}
pub fn lean_box_usize(v: usize) callconv(.c) lean_obj_res {
    const r = lean_alloc_ctor(0, 0, @sizeOf(usize));
    lean_ctor_set_usize(r, 0, v);
    return r;
}
pub fn lean_unbox_usize(o: b_lean_obj_arg) callconv(.c) usize {
    return lean_ctor_get_usize(o, 0);
}
pub fn lean_box_float(v: f64) callconv(.c) lean_obj_res {
    const r = lean_alloc_ctor(0, 0, @sizeOf(f64));
    lean_ctor_set_float(r, 0, v);
    return r;
}
pub fn lean_unbox_float(o: b_lean_obj_arg) callconv(.c) f64 {
    return lean_ctor_get_float(o, 0);
}
pub extern fn lean_dbg_trace(s: lean_obj_arg, @"fn": lean_obj_arg) LeanPtr;
pub extern fn lean_dbg_sleep(ms: u32, @"fn": lean_obj_arg) LeanPtr;
pub extern fn lean_dbg_trace_if_shared(s: lean_obj_arg, a: lean_obj_arg) LeanPtr;
pub extern fn lean_decode_io_error(errnum: c_int, fname: b_lean_obj_arg) lean_obj_res;
pub fn lean_io_mk_world() callconv(.c) lean_obj_res {
    return lean_box(0);
}
pub fn lean_io_result_is_ok(r: b_lean_obj_arg) callconv(.c) bool {
    return lean_ptr_tag(r) == 0;
}
pub fn lean_io_result_is_error(r: b_lean_obj_arg) callconv(.c) bool {
    return lean_ptr_tag(r) == 1;
}
pub fn lean_io_result_get_value(r: b_lean_obj_arg) callconv(.c) b_lean_obj_res {
    assert(@src(), lean_io_result_is_ok(r), "lean_io_result_is_ok(r)");
    return lean_ctor_get(r, 0);
}
pub fn lean_io_result_get_error(r: b_lean_obj_arg) callconv(.c) b_lean_obj_res {
    assert(@src(), lean_io_result_is_error(r), "lean_io_result_is_error(r)");
    return lean_ctor_get(r, 0);
}
pub extern fn lean_io_result_show_error(r: b_lean_obj_arg) void;
pub extern fn lean_io_mark_end_initialization() void;
pub fn lean_io_result_mk_ok(a: lean_obj_arg) callconv(.c) lean_obj_res {
    const r = lean_alloc_ctor(0, 1, 0);
    lean_ctor_set(r, 0, a);
    return r;
}
pub fn lean_io_result_mk_error(e: lean_obj_arg) callconv(.c) lean_obj_res {
    const r = lean_alloc_ctor(1, 1, 0);
    lean_ctor_set(r, 0, e);
    return r;
}
pub extern fn lean_mk_io_error_already_exists(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_already_exists_file(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_eof(lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_hardware_fault(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_illegal_operation(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_inappropriate_type(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_inappropriate_type_file(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_interrupted(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_invalid_argument(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_invalid_argument_file(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_no_file_or_directory(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_no_such_thing(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_no_such_thing_file(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_other_error(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_permission_denied(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_permission_denied_file(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_protocol_error(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_resource_busy(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_resource_exhausted(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_resource_exhausted_file(lean_obj_arg, u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_resource_vanished(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_time_expired(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_unsatisfied_constraints(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_error_unsupported_operation(u32, lean_obj_arg) lean_obj_res;
pub extern fn lean_mk_io_user_error(str: lean_obj_arg) lean_obj_res;
pub extern fn lean_st_mk_ref(lean_obj_arg, lean_obj_arg) lean_obj_res;
pub extern fn lean_st_ref_get(b_lean_obj_arg, lean_obj_arg) lean_obj_res;
pub extern fn lean_st_ref_set(b_lean_obj_arg, lean_obj_arg, lean_obj_arg) lean_obj_res;
pub extern fn lean_st_ref_reset(b_lean_obj_arg, lean_obj_arg) lean_obj_res;
pub extern fn lean_st_ref_swap(b_lean_obj_arg, lean_obj_arg, lean_obj_arg) lean_obj_res;
pub fn lean_ptr_addr(a: b_lean_obj_arg) callconv(.c) usize {
    return @intFromPtr(a);
}
pub extern fn lean_name_eq(n1: b_lean_obj_arg, n2: b_lean_obj_arg) u8;
pub fn lean_name_hash_ptr(n: b_lean_obj_arg) callconv(.c) u64 {
    assert(@src(), !lean_is_scalar(n), "!lean_is_scalar(n)");
    return lean_ctor_get_uint64(n, @sizeOf(LeanPtr) * 2);
}
pub fn lean_name_hash(n: b_lean_obj_arg) callconv(.c) u64 {
    if (lean_is_scalar(n))
        return 1723
    else
        return lean_name_hash_ptr(n);
}
pub fn lean_float_to_uint8(a: f64) callconv(.c) u8 {
    return if (0.0 <= a) if (a < 256.0) @intFromFloat(a) else 255 else 0;
}
pub fn lean_float_to_uint16(a: f64) callconv(.c) u16 {
    return if (0.0 <= a) if (a < 65536.0) @intFromFloat(a) else 65535 else 0;
}
pub fn lean_float_to_uint32(a: f64) callconv(.c) u32 {
    return if (0.0 <= a) if (a < 4294967296.0) @intFromFloat(a) else 4294967295 else 0;
}
pub fn lean_float_to_uint64(a: f64) callconv(.c) u64 {
    return if (0.0 <= a) if (a < 18446744073709551616.0) @intFromFloat(a) else 18446744073709551615 else 0;
}
pub fn lean_float_to_usize(a: f64) callconv(.c) usize {
    if (@sizeOf(usize) == @sizeOf(u64))
        return @bitCast(lean_float_to_uint64(a))
    else
        return @bitCast(lean_float_to_uint32(a));
}
pub fn lean_float_add(a: f64, b: f64) callconv(.c) f64 {
    return a + b;
}
pub fn lean_float_sub(a: f64, b: f64) callconv(.c) f64 {
    return a - b;
}
pub fn lean_float_mul(a: f64, b: f64) callconv(.c) f64 {
    return a * b;
}
pub fn lean_float_div(a: f64, b: f64) callconv(.c) f64 {
    return a / b;
}
pub fn lean_float_negate(a: f64) callconv(.c) f64 {
    return -a;
}
pub fn lean_float_beq(a: f64, b: f64) callconv(.c) u8 {
    return @intFromBool(a == b);
}
pub fn lean_float_decLe(a: f64, b: f64) callconv(.c) u8 {
    return @intFromBool(a <= b);
}
pub fn lean_float_decLt(a: f64, b: f64) callconv(.c) u8 {
    return @intFromBool(a < b);
}
pub fn lean_uint64_to_float(a: u64) callconv(.c) f64 {
    return @floatFromInt(a);
}
pub fn lean_hashmap_mk_idx(sz: lean_obj_arg, hash: u64) callconv(.c) usize {
    return @bitCast(hash & (lean_unbox(sz) -% 1));
}
pub fn lean_hashset_mk_idx(sz: lean_obj_arg, hash: u64) callconv(.c) usize {
    return @bitCast(hash & (lean_unbox(sz) -% 1));
}
pub fn lean_expr_data(expr: lean_obj_arg) callconv(.c) u64 {
    return lean_ctor_get_uint64(expr, lean_ctor_num_objs(expr) * @sizeOf(*anyopaque));
}
pub fn lean_get_max_ctor_fields(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(LEAN_MAX_CTOR_FIELDS);
}
pub fn lean_get_max_ctor_scalars_size(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(LEAN_MAX_CTOR_SCALARS_SIZE);
}
pub fn lean_get_usize_size(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(@sizeOf(usize));
}
pub fn lean_get_max_ctor_tag(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(LeanMaxCtorTag);
}
pub fn lean_strict_or(b1: u8, b2: u8) callconv(.c) u8 {
    return @intFromBool(b1 != 0 or b2 != 0);
}
pub fn lean_strict_and(b1: u8, b2: u8) callconv(.c) u8 {
    return @intFromBool(b1 != 0 and b2 != 0);
}
pub fn lean_version_get_major(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(LEAN_VERSION_MAJOR);
}
pub fn lean_version_get_minor(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(LEAN_VERSION_MINOR);
}
pub fn lean_version_get_patch(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_box(LEAN_VERSION_PATCH);
}
pub fn lean_version_get_is_release(_: lean_obj_arg) callconv(.c) u8 {
    return LEAN_VERSION_IS_RELEASE;
}
pub fn lean_version_get_special_desc(_: lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_mk_string(LEAN_SPECIAL_VERSION_DESC);
}
pub fn lean_internal_is_stage0(_: lean_obj_arg) callconv(.c) u8 {
    return LEAN_IS_STAGE0;
}
pub fn lean_nat_pred(n: b_lean_obj_arg) callconv(.c) lean_obj_res {
    return lean_nat_sub(n, lean_box(1));
}

test "compile_test" {
    _ = &lean_notify_assert;
    _ = &assert;
    _ = &lean_is_big_object_tag;
    _ = &lean_register_external_class;
    _ = &lean_is_scalar;
    _ = &lean_box;
    _ = &lean_unbox;
    _ = &lean_set_exit_on_panic;
    _ = &lean_set_panic_messages;
    _ = &lean_panic_fn;
    _ = &lean_internal_panic;
    _ = &lean_internal_panic_out_of_memory;
    _ = &lean_internal_panic_unreachable;
    _ = &lean_internal_panic_rc_overflow;
    _ = &lean_align;
    _ = &lean_get_slot_idx;
    _ = &lean_inc_heartbeat;
    _ = &lean_alloc_small_object;
    _ = &lean_alloc_ctor_memory;
    _ = &lean_small_object_size;
    _ = &lean_free_small_object;
    _ = &lean_alloc_object;
    _ = &lean_free_object;
    _ = &lean_ptr_tag;
    _ = &lean_ptr_other;
    _ = &lean_object_byte_size;
    _ = &lean_is_mt;
    _ = &lean_is_st;
    _ = &lean_is_persistent;
    _ = &lean_has_rc;
    _ = &lean_get_rc_mt_addr;
    _ = &lean_inc_ref;
    _ = &lean_inc_ref_n;
    _ = &lean_dec_ref_cold;
    _ = &lean_dec_ref;
    _ = &lean_inc;
    _ = &lean_inc_n;
    _ = &lean_dec;
    _ = &lean_dealloc;
    _ = &lean_is_ctor;
    _ = &lean_is_closure;
    _ = &lean_is_array;
    _ = &lean_is_sarray;
    _ = &lean_is_string;
    _ = &lean_is_mpz;
    _ = &lean_is_thunk;
    _ = &lean_is_task;
    _ = &lean_is_external;
    _ = &lean_is_ref;
    _ = &lean_obj_tag;
    _ = &lean_to_ctor;
    _ = &lean_to_closure;
    _ = &lean_to_array;
    _ = &lean_to_sarray;
    _ = &lean_to_string;
    _ = &lean_to_thunk;
    _ = &lean_to_task;
    _ = &lean_to_ref;
    _ = &lean_to_external;
    _ = &lean_is_exclusive;
    _ = &lean_is_shared;
    _ = &lean_mark_mt;
    _ = &lean_mark_persistent;
    _ = &lean_set_st_header;
    _ = &lean_set_non_heap_header;
    _ = &lean_set_non_heap_header_for_big;
    _ = &lean_ctor_num_objs;
    _ = &lean_ctor_obj_cptr;
    _ = &lean_ctor_scalar_cptr;
    _ = &lean_alloc_ctor;
    _ = &lean_ctor_get;
    _ = &lean_ctor_set;
    _ = &lean_ctor_set_tag;
    _ = &lean_ctor_release;
    _ = &lean_ctor_get_usize;
    _ = &lean_ctor_get_uint8;
    _ = &lean_ctor_get_uint16;
    _ = &lean_ctor_get_uint32;
    _ = &lean_ctor_get_uint64;
    _ = &lean_ctor_get_float;
    _ = &lean_ctor_set_usize;
    _ = &lean_ctor_set_uint8;
    _ = &lean_ctor_set_uint16;
    _ = &lean_ctor_set_uint32;
    _ = &lean_ctor_set_uint64;
    _ = &lean_ctor_set_float;
    _ = &lean_closure_fun;
    _ = &lean_closure_arity;
    _ = &lean_closure_num_fixed;
    _ = &lean_closure_cptr;
    _ = &lean_alloc_closure;
    _ = &lean_closure_get;
    _ = &lean_closure_set;
    _ = &lean_apply_1;
    _ = &lean_apply_2;
    _ = &lean_apply_3;
    _ = &lean_apply_4;
    _ = &lean_apply_5;
    _ = &lean_apply_6;
    _ = &lean_apply_7;
    _ = &lean_apply_8;
    _ = &lean_apply_9;
    _ = &lean_apply_10;
    _ = &lean_apply_11;
    _ = &lean_apply_12;
    _ = &lean_apply_13;
    _ = &lean_apply_14;
    _ = &lean_apply_15;
    _ = &lean_apply_16;
    _ = &lean_apply_n;
    _ = &lean_apply_m;
    _ = &lean_alloc_array;
    _ = &lean_array_size;
    _ = &lean_array_capacity;
    _ = &lean_array_byte_size;
    _ = &lean_array_cptr;
    _ = &lean_array_set_size;
    _ = &lean_array_get_core;
    _ = &lean_array_set_core;
    _ = &lean_array_mk;
    _ = &lean_array_data;
    _ = &lean_array_sz;
    _ = &lean_array_get_size;
    _ = &lean_mk_empty_array;
    _ = &lean_mk_empty_array_with_capacity;
    _ = &lean_array_uget;
    _ = &lean_array_fget;
    _ = &lean_array_get_panic;
    _ = &lean_array_get;
    _ = &lean_copy_expand_array;
    _ = &lean_copy_expand_array_nonlinear;
    _ = &lean_usize_add_checked;
    _ = &lean_usize_mul_checked;
    _ = &lean_internal_panic_overflow;
    _ = &lean_ensure_exclusive_array;
    _ = &lean_array_uset;
    _ = &lean_array_fset;
    _ = &lean_array_set_panic;
    _ = &lean_array_set;
    _ = &lean_array_pop;
    _ = &lean_array_uswap;
    _ = &lean_array_fswap;
    _ = &lean_array_swap;
    _ = &lean_array_push;
    _ = &lean_mk_array;
    _ = &lean_alloc_sarray;
    _ = &lean_sarray_elem_size;
    _ = &lean_sarray_capacity;
    _ = &lean_sarray_byte_size;
    _ = &lean_sarray_size;
    _ = &lean_sarray_set_size;
    _ = &lean_sarray_cptr;
    _ = &lean_byte_array_mk;
    _ = &lean_byte_array_data;
    _ = &lean_copy_byte_array;
    _ = &lean_byte_array_hash;
    _ = &lean_mk_empty_byte_array;
    _ = &lean_byte_array_size;
    _ = &lean_byte_array_uget;
    _ = &lean_byte_array_get;
    _ = &lean_byte_array_fget;
    _ = &lean_byte_array_push;
    _ = &lean_byte_array_uset;
    _ = &lean_byte_array_set;
    _ = &lean_byte_array_fset;
    _ = &lean_float_array_mk;
    _ = &lean_float_array_data;
    _ = &lean_copy_float_array;
    _ = &lean_mk_empty_float_array;
    _ = &lean_float_array_size;
    _ = &lean_float_array_cptr;
    _ = &lean_float_array_uget;
    _ = &lean_float_array_fget;
    _ = &lean_float_array_get;
    _ = &lean_float_array_push;
    _ = &lean_float_array_uset;
    _ = &lean_float_array_fset;
    _ = &lean_float_array_set;
    _ = &lean_alloc_string;
    _ = &lean_utf8_strlen;
    _ = &lean_utf8_n_strlen;
    _ = &lean_string_capacity;
    _ = &lean_string_byte_size;
    _ = &lean_char_default_value;
    _ = &lean_mk_string_from_bytes;
    _ = &lean_mk_string;
    _ = &lean_string_cstr;
    _ = &lean_string_size;
    _ = &lean_string_len;
    _ = &lean_string_push;
    _ = &lean_string_append;
    _ = &lean_string_length;
    _ = &lean_string_mk;
    _ = &lean_string_data;
    _ = &lean_string_utf8_get;
    _ = &lean_string_utf8_get_fast_cold;
    _ = &lean_string_utf8_get_fast;
    _ = &lean_string_utf8_next;
    _ = &lean_string_utf8_next_fast_cold;
    _ = &lean_string_utf8_next_fast;
    _ = &lean_string_utf8_prev;
    _ = &lean_string_utf8_set;
    _ = &lean_string_utf8_at_end;
    _ = &lean_string_utf8_extract;
    _ = &lean_string_utf8_byte_size;
    _ = &lean_string_eq_cold;
    _ = &lean_string_eq;
    _ = &lean_string_ne;
    _ = &lean_string_lt;
    _ = &lean_string_dec_eq;
    _ = &lean_string_dec_lt;
    _ = &lean_string_hash;
    _ = &lean_mk_thunk;
    _ = &lean_thunk_pure;
    _ = &lean_thunk_get_core;
    _ = &lean_thunk_get;
    _ = &lean_thunk_get_own;
    _ = &lean_init_task_manager;
    _ = &lean_init_task_manager_using;
    _ = &lean_finalize_task_manager;
    _ = &lean_task_spawn_core;
    _ = &lean_task_spawn;
    _ = &lean_task_pure;
    _ = &lean_task_bind_core;
    _ = &lean_task_bind;
    _ = &lean_task_map_core;
    _ = &lean_task_map;
    _ = &lean_task_get;
    _ = &lean_task_get_own;
    _ = &lean_io_check_canceled_core;
    _ = &lean_io_cancel_core;
    _ = &lean_io_has_finished_core;
    _ = &lean_io_wait_any_core;
    _ = &lean_alloc_external;
    _ = &lean_get_external_class;
    _ = &lean_get_external_data;
    _ = &lean_nat_big_succ;
    _ = &lean_nat_big_add;
    _ = &lean_nat_big_sub;
    _ = &lean_nat_big_mul;
    _ = &lean_nat_overflow_mul;
    _ = &lean_nat_big_div;
    _ = &lean_nat_big_mod;
    _ = &lean_nat_big_eq;
    _ = &lean_nat_big_le;
    _ = &lean_nat_big_lt;
    _ = &lean_nat_big_land;
    _ = &lean_nat_big_lor;
    _ = &lean_nat_big_xor;
    _ = &lean_cstr_to_nat;
    _ = &lean_big_usize_to_nat;
    _ = &lean_big_uint64_to_nat;
    _ = &lean_usize_to_nat;
    _ = &lean_unsigned_to_nat;
    _ = &lean_uint64_to_nat;
    _ = &lean_nat_succ;
    _ = &lean_nat_add;
    _ = &lean_nat_sub;
    _ = &lean_nat_mul;
    _ = &lean_nat_div;
    _ = &lean_nat_mod;
    _ = &lean_nat_eq;
    _ = &lean_nat_dec_eq;
    _ = &lean_nat_ne;
    _ = &lean_nat_le;
    _ = &lean_nat_dec_le;
    _ = &lean_nat_lt;
    _ = &lean_nat_dec_lt;
    _ = &lean_nat_land;
    _ = &lean_nat_lor;
    _ = &lean_nat_lxor;
    _ = &lean_nat_shiftl;
    _ = &lean_nat_shiftr;
    _ = &lean_nat_pow;
    _ = &lean_nat_gcd;
    _ = &lean_nat_log2;
    _ = &lean_int_big_neg;
    _ = &lean_int_big_add;
    _ = &lean_int_big_sub;
    _ = &lean_int_big_mul;
    _ = &lean_int_big_div;
    _ = &lean_int_big_mod;
    _ = &lean_int_big_eq;
    _ = &lean_int_big_le;
    _ = &lean_int_big_lt;
    _ = &lean_int_big_nonneg;
    _ = &lean_cstr_to_int;
    _ = &lean_big_int_to_int;
    _ = &lean_big_size_t_to_int;
    _ = &lean_big_int64_to_int;
    _ = &lean_int_to_int;
    _ = &lean_int64_to_int;
    _ = &lean_scalar_to_int64;
    _ = &lean_scalar_to_int;
    _ = &lean_nat_to_int;
    _ = &lean_int_neg;
    _ = &lean_int_neg_succ_of_nat;
    _ = &lean_int_add;
    _ = &lean_int_sub;
    _ = &lean_int_mul;
    _ = &lean_int_div;
    _ = &lean_int_mod;
    _ = &lean_int_eq;
    _ = &lean_int_ne;
    _ = &lean_int_le;
    _ = &lean_int_lt;
    _ = &lean_big_int_to_nat;
    _ = &lean_int_to_nat;
    _ = &lean_nat_abs;
    _ = &lean_int_dec_eq;
    _ = &lean_int_dec_le;
    _ = &lean_int_dec_lt;
    _ = &lean_int_dec_nonneg;
    _ = &lean_bool_to_uint64;
    _ = &lean_uint8_of_big_nat;
    _ = &lean_uint8_of_nat;
    _ = &lean_uint8_of_nat_mk;
    _ = &lean_uint8_to_nat;
    _ = &lean_uint8_add;
    _ = &lean_uint8_sub;
    _ = &lean_uint8_mul;
    _ = &lean_uint8_div;
    _ = &lean_uint8_mod;
    _ = &lean_uint8_land;
    _ = &lean_uint8_lor;
    _ = &lean_uint8_xor;
    _ = &lean_uint8_shift_left;
    _ = &lean_uint8_shift_right;
    _ = &lean_uint8_complement;
    _ = &lean_uint8_log2;
    _ = &lean_uint8_dec_eq;
    _ = &lean_uint8_dec_lt;
    _ = &lean_uint8_dec_le;
    _ = &lean_uint8_to_uint16;
    _ = &lean_uint8_to_uint32;
    _ = &lean_uint8_to_uint64;
    _ = &lean_uint16_of_big_nat;
    _ = &lean_uint16_of_nat;
    _ = &lean_uint16_of_nat_mk;
    _ = &lean_uint16_to_nat;
    _ = &lean_uint16_add;
    _ = &lean_uint16_sub;
    _ = &lean_uint16_mul;
    _ = &lean_uint16_div;
    _ = &lean_uint16_mod;
    _ = &lean_uint16_land;
    _ = &lean_uint16_lor;
    _ = &lean_uint16_xor;
    _ = &lean_uint16_shift_left;
    _ = &lean_uint16_shift_right;
    _ = &lean_uint16_complement;
    _ = &lean_uint16_log2;
    _ = &lean_uint16_dec_eq;
    _ = &lean_uint16_dec_lt;
    _ = &lean_uint16_dec_le;
    _ = &lean_uint16_to_uint8;
    _ = &lean_uint16_to_uint32;
    _ = &lean_uint16_to_uint64;
    _ = &lean_uint32_of_big_nat;
    _ = &lean_uint32_of_nat;
    _ = &lean_uint32_of_nat_mk;
    _ = &lean_uint32_to_nat;
    _ = &lean_uint32_add;
    _ = &lean_uint32_sub;
    _ = &lean_uint32_mul;
    _ = &lean_uint32_div;
    _ = &lean_uint32_mod;
    _ = &lean_uint32_land;
    _ = &lean_uint32_lor;
    _ = &lean_uint32_xor;
    _ = &lean_uint32_shift_left;
    _ = &lean_uint32_shift_right;
    _ = &lean_uint32_complement;
    _ = &lean_uint32_log2;
    _ = &lean_uint32_dec_eq;
    _ = &lean_uint32_dec_lt;
    _ = &lean_uint32_dec_le;
    _ = &lean_uint32_to_uint8;
    _ = &lean_uint32_to_uint16;
    _ = &lean_uint32_to_uint64;
    _ = &lean_uint32_to_usize;
    _ = &lean_uint64_of_big_nat;
    _ = &lean_uint64_of_nat;
    _ = &lean_uint64_of_nat_mk;
    _ = &lean_uint64_add;
    _ = &lean_uint64_sub;
    _ = &lean_uint64_mul;
    _ = &lean_uint64_div;
    _ = &lean_uint64_mod;
    _ = &lean_uint64_land;
    _ = &lean_uint64_lor;
    _ = &lean_uint64_xor;
    _ = &lean_uint64_shift_left;
    _ = &lean_uint64_shift_right;
    _ = &lean_uint64_complement;
    _ = &lean_uint64_log2;
    _ = &lean_uint64_dec_eq;
    _ = &lean_uint64_dec_lt;
    _ = &lean_uint64_dec_le;
    _ = &lean_uint64_mix_hash;
    _ = &lean_uint64_to_uint8;
    _ = &lean_uint64_to_uint16;
    _ = &lean_uint64_to_uint32;
    _ = &lean_uint64_to_usize;
    _ = &lean_usize_of_big_nat;
    _ = &lean_usize_of_nat;
    _ = &lean_usize_of_nat_mk;
    _ = &lean_usize_add;
    _ = &lean_usize_sub;
    _ = &lean_usize_mul;
    _ = &lean_usize_div;
    _ = &lean_usize_mod;
    _ = &lean_usize_land;
    _ = &lean_usize_lor;
    _ = &lean_usize_xor;
    _ = &lean_usize_shift_left;
    _ = &lean_usize_shift_right;
    _ = &lean_usize_complement;
    _ = &lean_usize_log2;
    _ = &lean_usize_dec_eq;
    _ = &lean_usize_dec_lt;
    _ = &lean_usize_dec_le;
    _ = &lean_usize_to_uint32;
    _ = &lean_usize_to_uint64;
    _ = &lean_float_to_string;
    _ = &lean_float_scaleb;
    _ = &lean_float_isnan;
    _ = &lean_float_isfinite;
    _ = &lean_float_isinf;
    _ = &lean_float_frexp;
    _ = &lean_box_uint32;
    _ = &lean_unbox_uint32;
    _ = &lean_box_uint64;
    _ = &lean_unbox_uint64;
    _ = &lean_box_usize;
    _ = &lean_unbox_usize;
    _ = &lean_box_float;
    _ = &lean_unbox_float;
    _ = &lean_dbg_trace;
    _ = &lean_dbg_sleep;
    _ = &lean_dbg_trace_if_shared;
    _ = &lean_decode_io_error;
    _ = &lean_io_mk_world;
    _ = &lean_io_result_is_ok;
    _ = &lean_io_result_is_error;
    _ = &lean_io_result_get_value;
    _ = &lean_io_result_get_error;
    _ = &lean_io_result_show_error;
    _ = &lean_io_mark_end_initialization;
    _ = &lean_io_result_mk_ok;
    _ = &lean_io_result_mk_error;
    _ = &lean_mk_io_error_already_exists;
    _ = &lean_mk_io_error_already_exists_file;
    _ = &lean_mk_io_error_eof;
    _ = &lean_mk_io_error_hardware_fault;
    _ = &lean_mk_io_error_illegal_operation;
    _ = &lean_mk_io_error_inappropriate_type;
    _ = &lean_mk_io_error_inappropriate_type_file;
    _ = &lean_mk_io_error_interrupted;
    _ = &lean_mk_io_error_invalid_argument;
    _ = &lean_mk_io_error_invalid_argument_file;
    _ = &lean_mk_io_error_no_file_or_directory;
    _ = &lean_mk_io_error_no_such_thing;
    _ = &lean_mk_io_error_no_such_thing_file;
    _ = &lean_mk_io_error_other_error;
    _ = &lean_mk_io_error_permission_denied;
    _ = &lean_mk_io_error_permission_denied_file;
    _ = &lean_mk_io_error_protocol_error;
    _ = &lean_mk_io_error_resource_busy;
    _ = &lean_mk_io_error_resource_exhausted;
    _ = &lean_mk_io_error_resource_exhausted_file;
    _ = &lean_mk_io_error_resource_vanished;
    _ = &lean_mk_io_error_time_expired;
    _ = &lean_mk_io_error_unsatisfied_constraints;
    _ = &lean_mk_io_error_unsupported_operation;
    _ = &lean_mk_io_user_error;
    _ = &lean_st_mk_ref;
    _ = &lean_st_ref_get;
    _ = &lean_st_ref_set;
    _ = &lean_st_ref_reset;
    _ = &lean_st_ref_swap;
    _ = &lean_ptr_addr;
    _ = &lean_name_eq;
    _ = &lean_name_hash_ptr;
    _ = &lean_name_hash;
    _ = &lean_float_to_uint8;
    _ = &lean_float_to_uint16;
    _ = &lean_float_to_uint32;
    _ = &lean_float_to_uint64;
    _ = &lean_float_to_usize;
    _ = &lean_float_add;
    _ = &lean_float_sub;
    _ = &lean_float_mul;
    _ = &lean_float_div;
    _ = &lean_float_negate;
    _ = &lean_float_beq;
    _ = &lean_float_decLe;
    _ = &lean_float_decLt;
    _ = &lean_uint64_to_float;
    _ = &lean_hashmap_mk_idx;
    _ = &lean_hashset_mk_idx;
    _ = &lean_expr_data;
    _ = &lean_get_max_ctor_fields;
    _ = &lean_get_max_ctor_scalars_size;
    _ = &lean_get_usize_size;
    _ = &lean_get_max_ctor_tag;
    _ = &lean_strict_or;
    _ = &lean_strict_and;
    _ = &lean_version_get_major;
    _ = &lean_version_get_minor;
    _ = &lean_version_get_patch;
    _ = &lean_version_get_is_release;
    _ = &lean_version_get_special_desc;
    _ = &lean_internal_is_stage0;
    _ = &lean_nat_pred;
    _ = &LEAN_UNLIKELY;
    _ = &LEAN_LIKELY;
    _ = &LEAN_BYTE;
}

// Runtime initialization externs previously declared in src/c.zig (folded in
// after the removal of `usingnamespace` in Zig 0.15+, which c.zig used to
// re-export this module). App-specific externs (e.g. module initializers)
// belong in the application that links them.
pub extern fn lean_initialize_runtime_module() void;
pub extern fn lean_initialize() void;

// ===========================================================================
// Lean v4.30 surface additions. Generated to mirror lean.h v4.30.0 exactly;
// audit against `zig build ffi-drift` output when bumping the toolchain.

// --- new LEAN_EXPORT externs ------------------------------------------------
pub extern fn lean_panic(msg: [*:0]const u8, force_stderr: bool) void;
pub extern fn lean_panic_fn_borrowed(default_val: b_lean_obj_arg, msg: LeanPtr) LeanPtr;
pub extern fn lean_object_data_byte_size(o: LeanPtr) usize;
pub extern fn lean_array_to_list(a: lean_obj_arg) LeanPtr;
pub extern fn lean_mk_string_unchecked(s: [*:0]const u8, sz: usize, len: usize) lean_obj_res;
pub extern fn lean_mk_string_from_bytes_unchecked(s: [*]const u8, sz: usize) lean_obj_res;
pub extern fn lean_mk_ascii_string_unchecked(s: [*:0]const u8) lean_obj_res;
pub extern fn lean_string_of_usize(n: usize) lean_obj_res;
pub extern fn lean_string_memcmp(s1: b_lean_obj_arg, s2: b_lean_obj_arg, lstart: b_lean_obj_arg, rstart: b_lean_obj_arg, len: b_lean_obj_arg) u8;
pub extern fn lean_slice_hash(s: b_lean_obj_arg) u64;
pub extern fn lean_slice_dec_lt(s1: b_lean_obj_arg, s2: b_lean_obj_arg) u8;
pub extern fn lean_io_get_task_state_core(t: b_lean_obj_arg) u8;
pub extern fn lean_nat_big_div_exact(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_nat_big_shiftr(a1: b_lean_obj_arg, a2: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_int_big_div_exact(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int_big_ediv(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int_big_emod(a1: LeanPtr, a2: LeanPtr) LeanPtr;
pub extern fn lean_int8_of_big_int(a: b_lean_obj_arg) i8;
pub extern fn lean_int16_of_big_int(a: b_lean_obj_arg) i16;
pub extern fn lean_int32_of_big_int(a: b_lean_obj_arg) i32;
pub extern fn lean_int64_of_big_int(a: b_lean_obj_arg) i64;
pub extern fn lean_isize_of_big_int(a: b_lean_obj_arg) isize;
pub extern fn lean_float_of_bits(u: u64) f64;
pub extern fn lean_float_to_bits(d: f64) u64;
pub extern fn lean_float32_of_bits(u: u32) f32;
pub extern fn lean_float32_to_bits(d: f32) u32;
pub extern fn lean_float32_to_string(a: f32) lean_obj_res;
pub extern fn lean_float32_scaleb(a: f32, b: b_lean_obj_arg) f32;
pub extern fn lean_float32_isnan(a: f32) u8;
pub extern fn lean_float32_isfinite(a: f32) u8;
pub extern fn lean_float32_isinf(a: f32) u8;
pub extern fn lean_float32_frexp(a: f32) lean_obj_res;
pub extern fn lean_decode_uv_error(errnum: c_int, fname: b_lean_obj_arg) lean_obj_res;
pub extern fn lean_run_main(main_fn: ?*const fn (c_int, [*c][*c]u8) callconv(.c) LeanPtr, argc: c_int, argv: [*c][*c]u8) LeanPtr;

// --- once cells -------------------------------------------------------------
pub const lean_once_cell_t = extern struct {
    state: c_int, // _Atomic in C
    lock: c_int, // _Atomic in C
};

pub extern fn lean_obj_once_cold(loc: *LeanPtr, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) LeanPtr) LeanPtr;
pub fn lean_obj_once(loc: *LeanPtr, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) LeanPtr) callconv(.c) LeanPtr {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_obj_once_cold(loc, tok, init_fn);
}
pub extern fn lean_uint8_once_cold(loc: *u8, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u8) u8;
pub fn lean_uint8_once(loc: *u8, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u8) callconv(.c) u8 {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_uint8_once_cold(loc, tok, init_fn);
}
pub extern fn lean_uint16_once_cold(loc: *u16, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u16) u16;
pub fn lean_uint16_once(loc: *u16, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u16) callconv(.c) u16 {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_uint16_once_cold(loc, tok, init_fn);
}
pub extern fn lean_uint32_once_cold(loc: *u32, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u32) u32;
pub fn lean_uint32_once(loc: *u32, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u32) callconv(.c) u32 {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_uint32_once_cold(loc, tok, init_fn);
}
pub extern fn lean_uint64_once_cold(loc: *u64, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u64) u64;
pub fn lean_uint64_once(loc: *u64, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) u64) callconv(.c) u64 {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_uint64_once_cold(loc, tok, init_fn);
}
pub extern fn lean_usize_once_cold(loc: *usize, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) usize) usize;
pub fn lean_usize_once(loc: *usize, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) usize) callconv(.c) usize {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_usize_once_cold(loc, tok, init_fn);
}
pub extern fn lean_float32_once_cold(loc: *f32, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) f32) f32;
pub fn lean_float32_once(loc: *f32, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) f32) callconv(.c) f32 {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_float32_once_cold(loc, tok, init_fn);
}
pub extern fn lean_float_once_cold(loc: *f64, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) f64) f64;
pub fn lean_float_once(loc: *f64, tok: *lean_once_cell_t, init_fn: ?*const fn () callconv(.c) f64) callconv(.c) f64 {
    if (LEAN_LIKELY(@atomicLoad(c_int, &tok.state, .seq_cst) == 1)) return loc.*;
    return lean_float_once_cold(loc, tok, init_fn);
}

// --- signed integers (carrier types are unsigned, as in lean.h) -------------

// Int8
pub fn lean_int8_of_int(a: b_lean_obj_arg) callconv(.c) u8 {
    if (lean_is_scalar(a)) return @truncate(@as(u64, @bitCast(lean_scalar_to_int64(a))));
    return @bitCast(lean_int8_of_big_int(a));
}
pub fn lean_int8_of_nat(a: b_lean_obj_arg) callconv(.c) u8 {
    if (lean_is_scalar(a)) return @truncate(lean_unbox(a));
    return @bitCast(lean_int8_of_big_int(a));
}

pub fn lean_int8_to_int(a: u8) callconv(.c) lean_obj_res {
    return lean_int64_to_int(@as(i64, @as(i8, @bitCast(a))));
}

pub fn lean_int8_neg(a: u8) callconv(.c) u8 {
    return 0 -% a;
}
pub fn lean_int8_add(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 +% a2;
}
pub fn lean_int8_sub(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 -% a2;
}
pub fn lean_int8_mul(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 *% a2;
}
pub fn lean_int8_div(a1: u8, a2: u8) callconv(.c) u8 {
    const lhs: i8 = @bitCast(a1);
    const rhs: i8 = @bitCast(a2);
    if (rhs == 0) return 0;
    // minInt / -1 wraps to minInt (C widens or branches to avoid the idiv trap)
    if (lhs == std.math.minInt(i8) and rhs == -1) return a1;
    return @bitCast(@divTrunc(lhs, rhs));
}
pub fn lean_int8_mod(a1: u8, a2: u8) callconv(.c) u8 {
    const lhs: i8 = @bitCast(a1);
    const rhs: i8 = @bitCast(a2);
    if (rhs == 0) return a1;
    if (lhs == std.math.minInt(i8) and rhs == -1) return 0;
    return @bitCast(@rem(lhs, rhs));
}
pub fn lean_int8_land(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 & a2;
}
pub fn lean_int8_lor(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 | a2;
}
pub fn lean_int8_xor(a1: u8, a2: u8) callconv(.c) u8 {
    return a1 ^ a2;
}
pub fn lean_int8_shift_right(a1: u8, a2: u8) callconv(.c) u8 {
    const lhs: i8 = @bitCast(a1);
    const rhs: i8 = @bitCast(a2);
    // shift amount is rhs smod bitwidth
    const amt: std.math.Log2Int(i8) = @intCast(@mod(rhs, @as(i8, @bitSizeOf(i8))));
    return @bitCast(lhs >> amt);
}
pub fn lean_int8_shift_left(a1: u8, a2: u8) callconv(.c) u8 {
    const rhs: i8 = @bitCast(a2);
    const amt: std.math.Log2Int(u8) = @intCast(@mod(rhs, @as(i8, @bitSizeOf(i8))));
    return a1 << amt;
}
pub fn lean_int8_complement(a: u8) callconv(.c) u8 {
    return ~a;
}
pub fn lean_int8_abs(a: u8) callconv(.c) u8 {
    return if (@as(i8, @bitCast(a)) < 0) 0 -% a else a;
}
pub fn lean_int8_dec_eq(a1: u8, a2: u8) callconv(.c) u8 {
    return @intFromBool(@as(i8, @bitCast(a1)) == @as(i8, @bitCast(a2)));
}
pub fn lean_int8_dec_lt(a1: u8, a2: u8) callconv(.c) u8 {
    return @intFromBool(@as(i8, @bitCast(a1)) < @as(i8, @bitCast(a2)));
}
pub fn lean_int8_dec_le(a1: u8, a2: u8) callconv(.c) u8 {
    return @intFromBool(@as(i8, @bitCast(a1)) <= @as(i8, @bitCast(a2)));
}
pub fn lean_int8_to_float(a: u8) callconv(.c) f64 {
    return @floatFromInt(@as(i8, @bitCast(a)));
}
pub fn lean_int8_to_float32(a: u8) callconv(.c) f32 {
    return @floatFromInt(@as(i8, @bitCast(a)));
}

pub fn lean_int8_to_int16(a: u8) callconv(.c) u16 {
    return @bitCast(@as(i16, @as(i16, @as(i8, @bitCast(a)))));
}

pub fn lean_int8_to_int32(a: u8) callconv(.c) u32 {
    return @bitCast(@as(i32, @as(i32, @as(i8, @bitCast(a)))));
}

pub fn lean_int8_to_int64(a: u8) callconv(.c) u64 {
    return @bitCast(@as(i64, @as(i64, @as(i8, @bitCast(a)))));
}

pub fn lean_int8_to_isize(a: u8) callconv(.c) usize {
    return @bitCast(@as(isize, @as(isize, @as(i8, @bitCast(a)))));
}

// Int16
pub fn lean_int16_of_int(a: b_lean_obj_arg) callconv(.c) u16 {
    if (lean_is_scalar(a)) return @truncate(@as(u64, @bitCast(lean_scalar_to_int64(a))));
    return @bitCast(lean_int16_of_big_int(a));
}
pub fn lean_int16_of_nat(a: b_lean_obj_arg) callconv(.c) u16 {
    if (lean_is_scalar(a)) return @truncate(lean_unbox(a));
    return @bitCast(lean_int16_of_big_int(a));
}

pub fn lean_int16_to_int(a: u16) callconv(.c) lean_obj_res {
    return lean_int64_to_int(@as(i64, @as(i16, @bitCast(a))));
}

pub fn lean_int16_neg(a: u16) callconv(.c) u16 {
    return 0 -% a;
}
pub fn lean_int16_add(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 +% a2;
}
pub fn lean_int16_sub(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 -% a2;
}
pub fn lean_int16_mul(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 *% a2;
}
pub fn lean_int16_div(a1: u16, a2: u16) callconv(.c) u16 {
    const lhs: i16 = @bitCast(a1);
    const rhs: i16 = @bitCast(a2);
    if (rhs == 0) return 0;
    // minInt / -1 wraps to minInt (C widens or branches to avoid the idiv trap)
    if (lhs == std.math.minInt(i16) and rhs == -1) return a1;
    return @bitCast(@divTrunc(lhs, rhs));
}
pub fn lean_int16_mod(a1: u16, a2: u16) callconv(.c) u16 {
    const lhs: i16 = @bitCast(a1);
    const rhs: i16 = @bitCast(a2);
    if (rhs == 0) return a1;
    if (lhs == std.math.minInt(i16) and rhs == -1) return 0;
    return @bitCast(@rem(lhs, rhs));
}
pub fn lean_int16_land(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 & a2;
}
pub fn lean_int16_lor(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 | a2;
}
pub fn lean_int16_xor(a1: u16, a2: u16) callconv(.c) u16 {
    return a1 ^ a2;
}
pub fn lean_int16_shift_right(a1: u16, a2: u16) callconv(.c) u16 {
    const lhs: i16 = @bitCast(a1);
    const rhs: i16 = @bitCast(a2);
    // shift amount is rhs smod bitwidth
    const amt: std.math.Log2Int(i16) = @intCast(@mod(rhs, @as(i16, @bitSizeOf(i16))));
    return @bitCast(lhs >> amt);
}
pub fn lean_int16_shift_left(a1: u16, a2: u16) callconv(.c) u16 {
    const rhs: i16 = @bitCast(a2);
    const amt: std.math.Log2Int(u16) = @intCast(@mod(rhs, @as(i16, @bitSizeOf(i16))));
    return a1 << amt;
}
pub fn lean_int16_complement(a: u16) callconv(.c) u16 {
    return ~a;
}
pub fn lean_int16_abs(a: u16) callconv(.c) u16 {
    return if (@as(i16, @bitCast(a)) < 0) 0 -% a else a;
}
pub fn lean_int16_dec_eq(a1: u16, a2: u16) callconv(.c) u8 {
    return @intFromBool(@as(i16, @bitCast(a1)) == @as(i16, @bitCast(a2)));
}
pub fn lean_int16_dec_lt(a1: u16, a2: u16) callconv(.c) u8 {
    return @intFromBool(@as(i16, @bitCast(a1)) < @as(i16, @bitCast(a2)));
}
pub fn lean_int16_dec_le(a1: u16, a2: u16) callconv(.c) u8 {
    return @intFromBool(@as(i16, @bitCast(a1)) <= @as(i16, @bitCast(a2)));
}
pub fn lean_int16_to_float(a: u16) callconv(.c) f64 {
    return @floatFromInt(@as(i16, @bitCast(a)));
}
pub fn lean_int16_to_float32(a: u16) callconv(.c) f32 {
    return @floatFromInt(@as(i16, @bitCast(a)));
}

pub fn lean_int16_to_int8(a: u16) callconv(.c) u8 {
    return @bitCast(@as(i8, @truncate(@as(i16, @bitCast(a)))));
}

pub fn lean_int16_to_int32(a: u16) callconv(.c) u32 {
    return @bitCast(@as(i32, @as(i32, @as(i16, @bitCast(a)))));
}

pub fn lean_int16_to_int64(a: u16) callconv(.c) u64 {
    return @bitCast(@as(i64, @as(i64, @as(i16, @bitCast(a)))));
}

pub fn lean_int16_to_isize(a: u16) callconv(.c) usize {
    return @bitCast(@as(isize, @as(isize, @as(i16, @bitCast(a)))));
}

// Int32
pub fn lean_int32_of_int(a: b_lean_obj_arg) callconv(.c) u32 {
    if (lean_is_scalar(a)) return @truncate(@as(u64, @bitCast(lean_scalar_to_int64(a))));
    return @bitCast(lean_int32_of_big_int(a));
}
pub fn lean_int32_of_nat(a: b_lean_obj_arg) callconv(.c) u32 {
    if (lean_is_scalar(a)) return @truncate(lean_unbox(a));
    return @bitCast(lean_int32_of_big_int(a));
}

pub fn lean_int32_to_int(a: u32) callconv(.c) lean_obj_res {
    return lean_int64_to_int(@as(i64, @as(i32, @bitCast(a))));
}

pub fn lean_int32_neg(a: u32) callconv(.c) u32 {
    return 0 -% a;
}
pub fn lean_int32_add(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 +% a2;
}
pub fn lean_int32_sub(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 -% a2;
}
pub fn lean_int32_mul(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 *% a2;
}
pub fn lean_int32_div(a1: u32, a2: u32) callconv(.c) u32 {
    const lhs: i32 = @bitCast(a1);
    const rhs: i32 = @bitCast(a2);
    if (rhs == 0) return 0;
    // minInt / -1 wraps to minInt (C widens or branches to avoid the idiv trap)
    if (lhs == std.math.minInt(i32) and rhs == -1) return a1;
    return @bitCast(@divTrunc(lhs, rhs));
}
pub fn lean_int32_mod(a1: u32, a2: u32) callconv(.c) u32 {
    const lhs: i32 = @bitCast(a1);
    const rhs: i32 = @bitCast(a2);
    if (rhs == 0) return a1;
    if (lhs == std.math.minInt(i32) and rhs == -1) return 0;
    return @bitCast(@rem(lhs, rhs));
}
pub fn lean_int32_land(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 & a2;
}
pub fn lean_int32_lor(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 | a2;
}
pub fn lean_int32_xor(a1: u32, a2: u32) callconv(.c) u32 {
    return a1 ^ a2;
}
pub fn lean_int32_shift_right(a1: u32, a2: u32) callconv(.c) u32 {
    const lhs: i32 = @bitCast(a1);
    const rhs: i32 = @bitCast(a2);
    // shift amount is rhs smod bitwidth
    const amt: std.math.Log2Int(i32) = @intCast(@mod(rhs, @as(i32, @bitSizeOf(i32))));
    return @bitCast(lhs >> amt);
}
pub fn lean_int32_shift_left(a1: u32, a2: u32) callconv(.c) u32 {
    const rhs: i32 = @bitCast(a2);
    const amt: std.math.Log2Int(u32) = @intCast(@mod(rhs, @as(i32, @bitSizeOf(i32))));
    return a1 << amt;
}
pub fn lean_int32_complement(a: u32) callconv(.c) u32 {
    return ~a;
}
pub fn lean_int32_abs(a: u32) callconv(.c) u32 {
    return if (@as(i32, @bitCast(a)) < 0) 0 -% a else a;
}
pub fn lean_int32_dec_eq(a1: u32, a2: u32) callconv(.c) u8 {
    return @intFromBool(@as(i32, @bitCast(a1)) == @as(i32, @bitCast(a2)));
}
pub fn lean_int32_dec_lt(a1: u32, a2: u32) callconv(.c) u8 {
    return @intFromBool(@as(i32, @bitCast(a1)) < @as(i32, @bitCast(a2)));
}
pub fn lean_int32_dec_le(a1: u32, a2: u32) callconv(.c) u8 {
    return @intFromBool(@as(i32, @bitCast(a1)) <= @as(i32, @bitCast(a2)));
}
pub fn lean_int32_to_float(a: u32) callconv(.c) f64 {
    return @floatFromInt(@as(i32, @bitCast(a)));
}
pub fn lean_int32_to_float32(a: u32) callconv(.c) f32 {
    return @floatFromInt(@as(i32, @bitCast(a)));
}

pub fn lean_int32_to_int8(a: u32) callconv(.c) u8 {
    return @bitCast(@as(i8, @truncate(@as(i32, @bitCast(a)))));
}

pub fn lean_int32_to_int16(a: u32) callconv(.c) u16 {
    return @bitCast(@as(i16, @truncate(@as(i32, @bitCast(a)))));
}

pub fn lean_int32_to_int64(a: u32) callconv(.c) u64 {
    return @bitCast(@as(i64, @as(i64, @as(i32, @bitCast(a)))));
}

pub fn lean_int32_to_isize(a: u32) callconv(.c) usize {
    return @bitCast(@as(isize, @as(isize, @as(i32, @bitCast(a)))));
}

// Int64
pub fn lean_int64_of_int(a: b_lean_obj_arg) callconv(.c) u64 {
    if (lean_is_scalar(a)) return @truncate(@as(u64, @bitCast(lean_scalar_to_int64(a))));
    return @bitCast(lean_int64_of_big_int(a));
}
pub fn lean_int64_of_nat(a: b_lean_obj_arg) callconv(.c) u64 {
    if (lean_is_scalar(a)) return @truncate(lean_unbox(a));
    return @bitCast(lean_int64_of_big_int(a));
}

pub fn lean_int64_to_int_sint(a: u64) callconv(.c) lean_obj_res {
    return lean_int64_to_int(@bitCast(a));
}

pub fn lean_int64_neg(a: u64) callconv(.c) u64 {
    return 0 -% a;
}
pub fn lean_int64_add(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 +% a2;
}
pub fn lean_int64_sub(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 -% a2;
}
pub fn lean_int64_mul(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 *% a2;
}
pub fn lean_int64_div(a1: u64, a2: u64) callconv(.c) u64 {
    const lhs: i64 = @bitCast(a1);
    const rhs: i64 = @bitCast(a2);
    if (rhs == 0) return 0;
    // minInt / -1 wraps to minInt (C widens or branches to avoid the idiv trap)
    if (lhs == std.math.minInt(i64) and rhs == -1) return a1;
    return @bitCast(@divTrunc(lhs, rhs));
}
pub fn lean_int64_mod(a1: u64, a2: u64) callconv(.c) u64 {
    const lhs: i64 = @bitCast(a1);
    const rhs: i64 = @bitCast(a2);
    if (rhs == 0) return a1;
    if (lhs == std.math.minInt(i64) and rhs == -1) return 0;
    return @bitCast(@rem(lhs, rhs));
}
pub fn lean_int64_land(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 & a2;
}
pub fn lean_int64_lor(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 | a2;
}
pub fn lean_int64_xor(a1: u64, a2: u64) callconv(.c) u64 {
    return a1 ^ a2;
}
pub fn lean_int64_shift_right(a1: u64, a2: u64) callconv(.c) u64 {
    const lhs: i64 = @bitCast(a1);
    const rhs: i64 = @bitCast(a2);
    // shift amount is rhs smod bitwidth
    const amt: std.math.Log2Int(i64) = @intCast(@mod(rhs, @as(i64, @bitSizeOf(i64))));
    return @bitCast(lhs >> amt);
}
pub fn lean_int64_shift_left(a1: u64, a2: u64) callconv(.c) u64 {
    const rhs: i64 = @bitCast(a2);
    const amt: std.math.Log2Int(u64) = @intCast(@mod(rhs, @as(i64, @bitSizeOf(i64))));
    return a1 << amt;
}
pub fn lean_int64_complement(a: u64) callconv(.c) u64 {
    return ~a;
}
pub fn lean_int64_abs(a: u64) callconv(.c) u64 {
    return if (@as(i64, @bitCast(a)) < 0) 0 -% a else a;
}
pub fn lean_int64_dec_eq(a1: u64, a2: u64) callconv(.c) u8 {
    return @intFromBool(@as(i64, @bitCast(a1)) == @as(i64, @bitCast(a2)));
}
pub fn lean_int64_dec_lt(a1: u64, a2: u64) callconv(.c) u8 {
    return @intFromBool(@as(i64, @bitCast(a1)) < @as(i64, @bitCast(a2)));
}
pub fn lean_int64_dec_le(a1: u64, a2: u64) callconv(.c) u8 {
    return @intFromBool(@as(i64, @bitCast(a1)) <= @as(i64, @bitCast(a2)));
}
pub fn lean_int64_to_float(a: u64) callconv(.c) f64 {
    return @floatFromInt(@as(i64, @bitCast(a)));
}
pub fn lean_int64_to_float32(a: u64) callconv(.c) f32 {
    return @floatFromInt(@as(i64, @bitCast(a)));
}

pub fn lean_int64_to_int8(a: u64) callconv(.c) u8 {
    return @bitCast(@as(i8, @truncate(@as(i64, @bitCast(a)))));
}

pub fn lean_int64_to_int16(a: u64) callconv(.c) u16 {
    return @bitCast(@as(i16, @truncate(@as(i64, @bitCast(a)))));
}

pub fn lean_int64_to_int32(a: u64) callconv(.c) u32 {
    return @bitCast(@as(i32, @truncate(@as(i64, @bitCast(a)))));
}

pub fn lean_int64_to_isize(a: u64) callconv(.c) usize {
    return @bitCast(@as(isize, @truncate(@as(i64, @bitCast(a)))));
}

// Isize
pub fn lean_isize_of_int(a: b_lean_obj_arg) callconv(.c) usize {
    if (lean_is_scalar(a)) return @truncate(@as(u64, @bitCast(lean_scalar_to_int64(a))));
    return @bitCast(lean_isize_of_big_int(a));
}
pub fn lean_isize_of_nat(a: b_lean_obj_arg) callconv(.c) usize {
    if (lean_is_scalar(a)) return @truncate(lean_unbox(a));
    return @bitCast(lean_isize_of_big_int(a));
}

pub fn lean_isize_to_int(a: usize) callconv(.c) lean_obj_res {
    return lean_int64_to_int(@as(i64, @as(isize, @bitCast(a))));
}

pub fn lean_isize_neg(a: usize) callconv(.c) usize {
    return 0 -% a;
}
pub fn lean_isize_add(a1: usize, a2: usize) callconv(.c) usize {
    return a1 +% a2;
}
pub fn lean_isize_sub(a1: usize, a2: usize) callconv(.c) usize {
    return a1 -% a2;
}
pub fn lean_isize_mul(a1: usize, a2: usize) callconv(.c) usize {
    return a1 *% a2;
}
pub fn lean_isize_div(a1: usize, a2: usize) callconv(.c) usize {
    const lhs: isize = @bitCast(a1);
    const rhs: isize = @bitCast(a2);
    if (rhs == 0) return 0;
    // minInt / -1 wraps to minInt (C widens or branches to avoid the idiv trap)
    if (lhs == std.math.minInt(isize) and rhs == -1) return a1;
    return @bitCast(@divTrunc(lhs, rhs));
}
pub fn lean_isize_mod(a1: usize, a2: usize) callconv(.c) usize {
    const lhs: isize = @bitCast(a1);
    const rhs: isize = @bitCast(a2);
    if (rhs == 0) return a1;
    if (lhs == std.math.minInt(isize) and rhs == -1) return 0;
    return @bitCast(@rem(lhs, rhs));
}
pub fn lean_isize_land(a1: usize, a2: usize) callconv(.c) usize {
    return a1 & a2;
}
pub fn lean_isize_lor(a1: usize, a2: usize) callconv(.c) usize {
    return a1 | a2;
}
pub fn lean_isize_xor(a1: usize, a2: usize) callconv(.c) usize {
    return a1 ^ a2;
}
pub fn lean_isize_shift_right(a1: usize, a2: usize) callconv(.c) usize {
    const lhs: isize = @bitCast(a1);
    const rhs: isize = @bitCast(a2);
    // shift amount is rhs smod bitwidth
    const amt: std.math.Log2Int(isize) = @intCast(@mod(rhs, @as(isize, @bitSizeOf(isize))));
    return @bitCast(lhs >> amt);
}
pub fn lean_isize_shift_left(a1: usize, a2: usize) callconv(.c) usize {
    const rhs: isize = @bitCast(a2);
    const amt: std.math.Log2Int(usize) = @intCast(@mod(rhs, @as(isize, @bitSizeOf(isize))));
    return a1 << amt;
}
pub fn lean_isize_complement(a: usize) callconv(.c) usize {
    return ~a;
}
pub fn lean_isize_abs(a: usize) callconv(.c) usize {
    return if (@as(isize, @bitCast(a)) < 0) 0 -% a else a;
}
pub fn lean_isize_dec_eq(a1: usize, a2: usize) callconv(.c) u8 {
    return @intFromBool(@as(isize, @bitCast(a1)) == @as(isize, @bitCast(a2)));
}
pub fn lean_isize_dec_lt(a1: usize, a2: usize) callconv(.c) u8 {
    return @intFromBool(@as(isize, @bitCast(a1)) < @as(isize, @bitCast(a2)));
}
pub fn lean_isize_dec_le(a1: usize, a2: usize) callconv(.c) u8 {
    return @intFromBool(@as(isize, @bitCast(a1)) <= @as(isize, @bitCast(a2)));
}
pub fn lean_isize_to_float(a: usize) callconv(.c) f64 {
    return @floatFromInt(@as(isize, @bitCast(a)));
}
pub fn lean_isize_to_float32(a: usize) callconv(.c) f32 {
    return @floatFromInt(@as(isize, @bitCast(a)));
}

pub fn lean_isize_to_int8(a: usize) callconv(.c) u8 {
    return @bitCast(@as(i8, @truncate(@as(isize, @bitCast(a)))));
}

pub fn lean_isize_to_int16(a: usize) callconv(.c) u16 {
    return @bitCast(@as(i16, @truncate(@as(isize, @bitCast(a)))));
}

pub fn lean_isize_to_int32(a: usize) callconv(.c) u32 {
    return @bitCast(@as(i32, @truncate(@as(isize, @bitCast(a)))));
}

pub fn lean_isize_to_int64(a: usize) callconv(.c) u64 {
    return @bitCast(@as(i64, @as(i64, @as(isize, @bitCast(a)))));
}

// --- Float32 -----------------------------------------------------------------
pub fn lean_float32_add(a: f32, b: f32) callconv(.c) f32 {
    return a + b;
}
pub fn lean_float32_sub(a: f32, b: f32) callconv(.c) f32 {
    return a - b;
}
pub fn lean_float32_mul(a: f32, b: f32) callconv(.c) f32 {
    return a * b;
}
pub fn lean_float32_div(a: f32, b: f32) callconv(.c) f32 {
    return a / b;
}
pub fn lean_float32_negate(a: f32) callconv(.c) f32 {
    return -a;
}
pub fn lean_float32_beq(a: f32, b: f32) callconv(.c) u8 {
    return @intFromBool(a == b);
}
pub fn lean_float32_decLe(a: f32, b: f32) callconv(.c) u8 {
    return @intFromBool(a <= b);
}
pub fn lean_float32_decLt(a: f32, b: f32) callconv(.c) u8 {
    return @intFromBool(a < b);
}
pub fn lean_float32_to_float(a: f32) callconv(.c) f64 {
    return @floatCast(a);
}
pub fn lean_float_to_float32(a: f64) callconv(.c) f32 {
    return @floatCast(a);
}
pub fn lean_box_float32(v: f32) callconv(.c) lean_obj_res {
    const r = lean_alloc_ctor(0, 0, @sizeOf(f32));
    lean_ctor_set_float32(r, 0, v);
    return r;
}
pub fn lean_unbox_float32(o: b_lean_obj_arg) callconv(.c) f32 {
    return lean_ctor_get_float32(o, 0);
}
pub fn lean_ctor_get_float32(o: b_lean_obj_arg, offset: c_uint) callconv(.c) f32 {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    return @as(*align(1) const f32, @ptrCast(@as([*]const u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset)).*;
}
pub fn lean_ctor_set_float32(o: b_lean_obj_arg, offset: c_uint, v: f32) callconv(.c) void {
    assert(@src(), offset >= lean_ctor_num_objs(o) * @sizeOf(*anyopaque), "offset >= lean_ctor_num_objs(o) * sizeof(void*)");
    @as(*align(1) f32, @ptrCast(@as([*]u8, @ptrCast(lean_ctor_obj_cptr(o))) + offset)).* = v;
}

// --- saturating float/float32 -> integer conversions (lean.h semantics) -----
pub fn lean_float_to_int8(a: f64) callconv(.c) u8 {
    const result: i8 = if (lean_float_isnan(a) != 0)
        0
    else if (-129.0 < a)
        (if (a < 128.0) @intFromFloat(a) else std.math.maxInt(i8))
    else
        std.math.minInt(i8);
    return @bitCast(result);
}

pub fn lean_float_to_int16(a: f64) callconv(.c) u16 {
    const result: i16 = if (lean_float_isnan(a) != 0)
        0
    else if (-32769.0 < a)
        (if (a < 32768.0) @intFromFloat(a) else std.math.maxInt(i16))
    else
        std.math.minInt(i16);
    return @bitCast(result);
}

pub fn lean_float_to_int32(a: f64) callconv(.c) u32 {
    const result: i32 = if (lean_float_isnan(a) != 0)
        0
    else if (-2147483649.0 < a)
        (if (a < 2147483648.0) @intFromFloat(a) else std.math.maxInt(i32))
    else
        std.math.minInt(i32);
    return @bitCast(result);
}

pub fn lean_float_to_int64(a: f64) callconv(.c) u64 {
    const result: i64 = if (lean_float_isnan(a) != 0)
        0
    else if (-9223372036854775809.0 < a)
        (if (a < 9223372036854775808.0) @intFromFloat(a) else std.math.maxInt(i64))
    else
        std.math.minInt(i64);
    return @bitCast(result);
}

pub fn lean_float_to_isize(a: f64) callconv(.c) usize {
    if (@bitSizeOf(usize) == 64) {
        return @truncate(lean_float_to_int64(a));
    } else {
        return @as(u32, lean_float_to_int32(a));
    }
}

pub fn lean_float32_to_int8(a: f32) callconv(.c) u8 {
    const result: i8 = if (lean_float32_isnan(a) != 0)
        0
    else if (-129.0 < a)
        (if (a < 128.0) @intFromFloat(a) else std.math.maxInt(i8))
    else
        std.math.minInt(i8);
    return @bitCast(result);
}

pub fn lean_float32_to_int16(a: f32) callconv(.c) u16 {
    const result: i16 = if (lean_float32_isnan(a) != 0)
        0
    else if (-32769.0 < a)
        (if (a < 32768.0) @intFromFloat(a) else std.math.maxInt(i16))
    else
        std.math.minInt(i16);
    return @bitCast(result);
}

pub fn lean_float32_to_int32(a: f32) callconv(.c) u32 {
    const result: i32 = if (lean_float32_isnan(a) != 0)
        0
    else if (-2147483649.0 < a)
        (if (a < 2147483648.0) @intFromFloat(a) else std.math.maxInt(i32))
    else
        std.math.minInt(i32);
    return @bitCast(result);
}

pub fn lean_float32_to_int64(a: f32) callconv(.c) u64 {
    const result: i64 = if (lean_float32_isnan(a) != 0)
        0
    else if (-9223372036854775809.0 < a)
        (if (a < 9223372036854775808.0) @intFromFloat(a) else std.math.maxInt(i64))
    else
        std.math.minInt(i64);
    return @bitCast(result);
}

pub fn lean_float32_to_isize(a: f32) callconv(.c) usize {
    if (@bitSizeOf(usize) == 64) {
        return @truncate(lean_float32_to_int64(a));
    } else {
        return @as(u32, lean_float32_to_int32(a));
    }
}

pub fn lean_float32_to_uint8(a: f32) callconv(.c) u8 {
    return if (0.0 <= a) (if (a < 256.0) @intFromFloat(a) else std.math.maxInt(u8)) else 0;
}

pub fn lean_float32_to_uint16(a: f32) callconv(.c) u16 {
    return if (0.0 <= a) (if (a < 65536.0) @intFromFloat(a) else std.math.maxInt(u16)) else 0;
}

pub fn lean_float32_to_uint32(a: f32) callconv(.c) u32 {
    return if (0.0 <= a) (if (a < 4294967296.0) @intFromFloat(a) else std.math.maxInt(u32)) else 0;
}

pub fn lean_float32_to_uint64(a: f32) callconv(.c) u64 {
    return if (0.0 <= a) (if (a < 18446744073709551616.0) @intFromFloat(a) else std.math.maxInt(u64)) else 0;
}

pub fn lean_float32_to_usize(a: f32) callconv(.c) usize {
    if (@bitSizeOf(usize) == 64) {
        return lean_float32_to_uint64(a);
    } else {
        return lean_float32_to_uint32(a);
    }
}

// --- bool / unsigned conversions ---------------------------------------------
pub fn lean_bool_to_uint8(a: u8) callconv(.c) u8 {
    return a;
}
pub fn lean_bool_to_uint16(a: u8) callconv(.c) u16 {
    return a;
}
pub fn lean_bool_to_uint32(a: u8) callconv(.c) u32 {
    return a;
}
pub fn lean_bool_to_usize(a: u8) callconv(.c) usize {
    return a;
}
pub fn lean_bool_to_int8(a: u8) callconv(.c) u8 {
    return a;
}
pub fn lean_bool_to_int16(a: u8) callconv(.c) u16 {
    return a;
}
pub fn lean_bool_to_int32(a: u8) callconv(.c) u32 {
    return a;
}
pub fn lean_bool_to_int64(a: u8) callconv(.c) u64 {
    return a;
}
pub fn lean_bool_to_isize(a: u8) callconv(.c) usize {
    return a;
}
pub fn lean_uint8_neg(a: u8) callconv(.c) u8 {
    return 0 -% a;
}
pub fn lean_uint16_neg(a: u16) callconv(.c) u16 {
    return 0 -% a;
}
pub fn lean_uint32_neg(a: u32) callconv(.c) u32 {
    return 0 -% a;
}
pub fn lean_uint64_neg(a: u64) callconv(.c) u64 {
    return 0 -% a;
}
pub fn lean_usize_neg(a: usize) callconv(.c) usize {
    return 0 -% a;
}
pub fn lean_uint8_to_float(a: u8) callconv(.c) f64 {
    return @floatFromInt(a);
}
pub fn lean_uint16_to_float(a: u16) callconv(.c) f64 {
    return @floatFromInt(a);
}
pub fn lean_uint32_to_float(a: u32) callconv(.c) f64 {
    return @floatFromInt(a);
}
pub fn lean_usize_to_float(a: usize) callconv(.c) f64 {
    return @floatFromInt(a);
}
pub fn lean_uint8_to_float32(a: u8) callconv(.c) f32 {
    return @floatFromInt(a);
}
pub fn lean_uint16_to_float32(a: u16) callconv(.c) f32 {
    return @floatFromInt(a);
}
pub fn lean_uint32_to_float32(a: u32) callconv(.c) f32 {
    return @floatFromInt(a);
}
pub fn lean_uint64_to_float32(a: u64) callconv(.c) f32 {
    return @floatFromInt(a);
}
pub fn lean_usize_to_float32(a: usize) callconv(.c) f32 {
    return @floatFromInt(a);
}
pub fn lean_uint8_to_usize(a: u8) callconv(.c) usize {
    return a;
}
pub fn lean_uint16_to_usize(a: u16) callconv(.c) usize {
    return a;
}
pub fn lean_usize_to_uint8(a: usize) callconv(.c) u8 {
    return @truncate(a);
}
pub fn lean_usize_to_uint16(a: usize) callconv(.c) u16 {
    return @truncate(a);
}

// --- object / array / string helpers -----------------------------------------
pub fn lean_del_object(o: LeanPtr) callconv(.c) void {
    if (!lean_is_scalar(o)) lean_free_object(o);
}
pub fn lean_void_mk(a: lean_obj_arg) callconv(.c) lean_obj_res {
    lean_dec(a);
    return lean_box(0);
}
pub fn lean_is_exclusive_obj(o: LeanPtr) callconv(.c) u8 {
    return @intFromBool(lean_is_exclusive(o));
}
pub fn lean_io_result_take_value(r: lean_obj_arg) callconv(.c) lean_obj_res {
    assert(@src(), lean_io_result_is_ok(r), "lean_io_result_is_ok(r)");
    const v = lean_ctor_get(r, 0);
    lean_inc(v);
    lean_dec(r);
    return v;
}
pub fn lean_runtime_hold(a: b_lean_obj_arg) callconv(.c) lean_obj_res {
    _ = a;
    return lean_box(0);
}
pub fn lean_usize_mul_would_overflow(a: usize, b: usize) callconv(.c) bool {
    const r = @mulWithOverflow(a, b);
    return r[1] != 0;
}
pub fn lean_usize_add_would_overflow(a: usize, b: usize) callconv(.c) bool {
    const r = @addWithOverflow(a, b);
    return r[1] != 0;
}
pub fn lean_alloc_sarray_would_overflow(elem_size: c_uint, capacity: usize) callconv(.c) bool {
    if (lean_usize_mul_would_overflow(elem_size, capacity)) return true;
    if (lean_usize_add_would_overflow(@sizeOf(lean_sarray_object), elem_size * capacity)) return true;
    return false;
}
pub fn lean_closure_arg_cptr(o: LeanPtr) callconv(.c) [*c]LeanPtr {
    return lean_to_closure(o).m_objs();
}
pub fn lean_closure_byte_size(o: LeanPtr) callconv(.c) usize {
    return @sizeOf(lean_closure_object) + @sizeOf(*anyopaque) * lean_closure_num_fixed(o);
}
pub fn lean_closure_data_byte_size(o: LeanPtr) callconv(.c) usize {
    return lean_closure_byte_size(o);
}
pub fn lean_array_data_byte_size(o: LeanPtr) callconv(.c) usize {
    return @sizeOf(lean_array_object) + @sizeOf(*anyopaque) * lean_array_size(o);
}
pub fn lean_sarray_data_byte_size(o: LeanPtr) callconv(.c) usize {
    return @sizeOf(lean_sarray_object) + lean_sarray_elem_size(o) * lean_sarray_size(o);
}
pub fn lean_string_data_byte_size(o: LeanPtr) callconv(.c) usize {
    return @sizeOf(lean_string_object) + lean_string_size(o);
}
pub fn lean_string_get_byte_fast(s: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) u8 {
    const str = lean_string_cstr(s);
    return str[lean_unbox(i)];
}
pub fn lean_set_external_data(o: LeanPtr, data: ?*anyopaque) callconv(.c) LeanPtr {
    if (lean_is_exclusive(o)) {
        lean_to_external(o).m_data = data;
        return o;
    } else {
        const o_new = lean_alloc_external(lean_get_external_class(o), data);
        lean_dec_ref(o);
        return o_new;
    }
}
pub fn lean_array_uget_borrowed(a: b_lean_obj_arg, i: usize) callconv(.c) b_lean_obj_res {
    return lean_array_get_core(a, i);
}
pub fn lean_array_fget_borrowed(a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) b_lean_obj_res {
    return lean_array_get_core(a, lean_unbox(i));
}
pub fn lean_array_get_borrowed(def_val: b_lean_obj_arg, a: b_lean_obj_arg, i: b_lean_obj_arg) callconv(.c) LeanPtr {
    if (lean_is_scalar(i)) {
        const idx = lean_unbox(i);
        if (idx < lean_array_size(a)) {
            return lean_array_get_core(a, idx);
        }
    }
    lean_inc(def_val);
    return lean_array_get_panic(def_val);
}

// --- promises ------------------------------------------------------------------
pub const lean_promise_object = extern struct {
    m_header: lean_object,
    m_result: *lean_task_object,
};
pub fn lean_is_promise(o: LeanPtr) callconv(.c) bool {
    return lean_ptr_tag(o) == LeanPromise;
}
pub fn lean_to_promise(o: LeanPtr) callconv(.c) *align(1) lean_promise_object {
    assert(@src(), lean_is_promise(o), "lean_is_promise(o)");
    return @ptrCast(o);
}

// --- Int/Nat euclidean & exact division -----------------------------------------
pub fn lean_int_ediv(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const n: i64 = lean_scalar_to_int64(a1);
        const d: i64 = lean_scalar_to_int64(a2);
        if (d == 0) return lean_box(0);
        var q = @divTrunc(n, d);
        const r = @rem(n, d);
        if (r < 0) q = if (d > 0) q - 1 else q + 1;
        return lean_int64_to_int(q);
    } else {
        return lean_int_big_ediv(a1, a2);
    }
}
pub fn lean_int_emod(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const n: i64 = lean_scalar_to_int64(a1);
        const d: i64 = lean_scalar_to_int64(a2);
        if (d == 0) return a1;
        var r = @rem(n, d);
        if (r < 0) r = if (d > 0) r + d else r - d;
        return lean_int64_to_int(r);
    } else {
        return lean_int_big_emod(a1, a2);
    }
}
pub fn lean_int_div_exact(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const v1: i64 = lean_scalar_to_int64(a1);
        const v2: i64 = lean_scalar_to_int64(a2);
        if (v2 == 0) return lean_box(0);
        return lean_int64_to_int(@divTrunc(v1, v2));
    } else {
        return lean_int_big_div_exact(a1, a2);
    }
}
pub fn lean_nat_div_exact(a1: b_lean_obj_arg, a2: b_lean_obj_arg) callconv(.c) lean_obj_res {
    if (LEAN_LIKELY(lean_is_scalar(a1) and lean_is_scalar(a2))) {
        const n1 = lean_unbox(a1);
        const n2 = lean_unbox(a2);
        if (n2 == 0) return lean_box(0);
        return lean_box(n1 / n2);
    } else {
        return lean_nat_big_div_exact(a1, a2);
    }
}

// ---------------------------------------------------------------------------
// Behavioral tests: exercise the inline translations above against the real
// Lean runtime (libleanshared). The compile_test only proves that the decls
// compile and that extern symbols link; these prove the translated semantics
// still match the runtime they execute against.

var test_runtime_initialized = false;
fn testEnsureRuntime() void {
    if (!test_runtime_initialized) {
        lean_initialize_runtime_module();
        lean_io_mark_end_initialization();
        test_runtime_initialized = true;
    }
}

test "box/unbox roundtrip for scalars" {
    const o = lean_box(42);
    try std.testing.expect(lean_is_scalar(o));
    try std.testing.expectEqual(@as(usize, 42), lean_unbox(o));
}

test "small object allocation records its size (mimalloc runtime)" {
    testEnsureRuntime();
    const o = lean_alloc_small_object(24);
    try std.testing.expectEqual(@as(c_uint, 24), lean_small_object_size(o));
    lean_free_small_object(o);
}

test "ctor alloc/set/get, header fields, refcount, free via runtime dec" {
    testEnsureRuntime();
    const o = lean_alloc_ctor(3, 2, 0);
    lean_ctor_set(o, 0, lean_box(7));
    lean_ctor_set(o, 1, lean_box(9));
    try std.testing.expectEqual(@as(u8, 3), lean_ptr_tag(o));
    try std.testing.expectEqual(@as(c_uint, 2), lean_ctor_num_objs(o));
    try std.testing.expectEqual(@as(usize, 7), lean_unbox(lean_ctor_get(o, 0)));
    try std.testing.expectEqual(@as(usize, 9), lean_unbox(lean_ctor_get(o, 1)));
    try std.testing.expect(lean_is_st(o));
    lean_inc(o);
    try std.testing.expectEqual(@as(c_int, 2), o.m_rc);
    lean_dec(o);
    try std.testing.expectEqual(@as(c_int, 1), o.m_rc);
    // final dec frees through the runtime: it must accept our mimalloc allocation
    lean_dec(o);
}

test "io results use the 4.30 single-field ctor shape" {
    testEnsureRuntime();
    const ok = lean_io_result_mk_ok(lean_box(5));
    try std.testing.expect(lean_io_result_is_ok(ok));
    try std.testing.expectEqual(@as(c_uint, 1), lean_ctor_num_objs(ok));
    try std.testing.expectEqual(@as(usize, 5), lean_unbox(lean_io_result_get_value(ok)));
    lean_dec(ok);

    const err = lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string("expected test error")));
    try std.testing.expect(lean_io_result_is_error(err));
    lean_dec(err);
}

test "strings: runtime-allocated object, inline accessors" {
    testEnsureRuntime();
    const s = lean_mk_string("hello!");
    try std.testing.expect(lean_is_string(s));
    try std.testing.expectEqual(@as(usize, 7), lean_string_size(s)); // includes NUL
    try std.testing.expectEqual(@as(usize, 6), lean_string_len(s));
    try std.testing.expectEqualStrings("hello!", std.mem.span(lean_string_cstr(s)));
    const s2 = lean_string_push(s, 'x'); // consumes s
    try std.testing.expectEqualStrings("hello!x", std.mem.span(lean_string_cstr(s2)));
    lean_dec(s2);
}

test "arrays: alloc via bindings, push via runtime, borrowed def_val" {
    testEnsureRuntime();
    var a = lean_mk_empty_array(); // lean_alloc_array(0, 0) from the bindings
    a = lean_array_push(a, lean_box(1));
    a = lean_array_push(a, lean_box(2));
    try std.testing.expectEqual(@as(usize, 2), lean_array_size(a));
    const hit = lean_array_get(lean_box(99), a, lean_box(1));
    try std.testing.expectEqual(@as(usize, 2), lean_unbox(hit));
    // def_val is borrowed since 4.30: its refcount must be untouched on a hit
    const def = lean_mk_string("default");
    try std.testing.expectEqual(@as(c_int, 1), def.m_rc);
    _ = lean_array_get(def, a, lean_box(0));
    try std.testing.expectEqual(@as(c_int, 1), def.m_rc);
    lean_dec(def);
    lean_dec(a);
}

test "closures: alloc via bindings, apply via runtime" {
    testEnsureRuntime();
    const S = struct {
        fn add3(x: lean_obj_arg) callconv(.c) lean_obj_res {
            return lean_box(lean_unbox(x) + 3);
        }
    };
    const cl = lean_alloc_closure(@ptrCast(@constCast(&S.add3)), 1, 0);
    const r = lean_apply_1(cl, lean_box(4)); // consumes cl
    try std.testing.expectEqual(@as(usize, 7), lean_unbox(r));
}

test "nat arithmetic across the bignum boundary" {
    testEnsureRuntime();
    const big = lean_cstr_to_nat("36893488147419103232"); // 2^65
    try std.testing.expect(!lean_is_scalar(big));
    const one = lean_unsigned_to_nat(1);
    const sum = lean_nat_add(big, one);
    const expected = lean_cstr_to_nat("36893488147419103233");
    try std.testing.expect(lean_nat_dec_eq(sum, expected) != 0);
    lean_dec(big);
    lean_dec(one);
    lean_dec(sum);
    lean_dec(expected);
}

test "tasks: pure + sync map through the 4.30 task ABI" {
    testEnsureRuntime();
    lean_init_task_manager();
    const S = struct {
        fn double(x: lean_obj_arg) callconv(.c) lean_obj_res {
            return lean_box(lean_unbox(x) * 2);
        }
    };
    const t = lean_task_pure(lean_box(21));
    const cl = lean_alloc_closure(@ptrCast(@constCast(&S.double)), 1, 0);
    const t2 = lean_task_map(cl, t, lean_box(0), 1);
    const v = lean_task_get_own(t2);
    try std.testing.expectEqual(@as(usize, 42), lean_unbox(v));
}

test "compile_all_pub_decls" {
    // Force semantic analysis of every public declaration (incl. ones not
    // referenced by the hand-written compile_test above), so removed or
    // renamed runtime symbols always surface as link errors here.
    @setEvalBranchQuota(100_000);
    inline for (comptime std.meta.declarations(@This())) |d| {
        _ = &@field(@This(), d.name);
    }
}

// --- M3: scalar ABI -----------------------------------------------------------

test "signed integer families follow C semantics" {
    const fams = .{
        .{ "int8", u8, i8 },
        .{ "int16", u16, i16 },
        .{ "int32", u32, i32 },
        .{ "int64", u64, i64 },
        .{ "isize", usize, isize },
    };
    inline for (fams) |f| {
        const name = f[0];
        const uT = f[1];
        const iT = f[2];
        const Self = @This();
        const add = @field(Self, "lean_" ++ name ++ "_add");
        const mul = @field(Self, "lean_" ++ name ++ "_mul");
        const neg = @field(Self, "lean_" ++ name ++ "_neg");
        const div = @field(Self, "lean_" ++ name ++ "_div");
        const mod = @field(Self, "lean_" ++ name ++ "_mod");
        const shr = @field(Self, "lean_" ++ name ++ "_shift_right");
        const shl = @field(Self, "lean_" ++ name ++ "_shift_left");
        const abs = @field(Self, "lean_" ++ name ++ "_abs");
        const dec_lt = @field(Self, "lean_" ++ name ++ "_dec_lt");
        const min: uT = @bitCast(@as(iT, std.math.minInt(iT)));
        const max: uT = @bitCast(@as(iT, std.math.maxInt(iT)));
        const m1: uT = @bitCast(@as(iT, -1));
        const u = struct {
            fn of(x: iT) uT {
                return @bitCast(x);
            }
        };

        // wrapping arithmetic on the unsigned carriers
        try std.testing.expectEqual(min, add(max, 1));
        try std.testing.expectEqual(u.of(-2), mul(max, 2));
        try std.testing.expectEqual(min, neg(min));
        // div/mod conventions: x/0 = 0, x%0 = x, minInt/-1 wraps
        try std.testing.expectEqual(@as(uT, 0), div(u.of(5), 0));
        try std.testing.expectEqual(u.of(7), mod(u.of(7), 0));
        try std.testing.expectEqual(min, div(min, m1));
        try std.testing.expectEqual(@as(uT, 0), mod(min, m1));
        try std.testing.expectEqual(u.of(-3), div(u.of(7), u.of(-2))); // trunc
        try std.testing.expectEqual(u.of(-1), mod(u.of(-7), u.of(2)));
        // arithmetic shift right; amounts are smod bit-width
        try std.testing.expectEqual(u.of(-4), shr(u.of(-16), 2));
        const bits: iT = @bitSizeOf(iT);
        try std.testing.expectEqual(shr(u.of(-16), 1), shr(u.of(-16), u.of(bits + 1)));
        try std.testing.expectEqual(u.of(8), shl(1, 3));
        try std.testing.expectEqual(min, shl(1, m1)); // smod: shift by width-1
        // abs(minInt) = minInt; signed comparison (not bit-pattern order)
        try std.testing.expectEqual(min, abs(min));
        try std.testing.expectEqual(u.of(5), abs(u.of(-5)));
        try std.testing.expectEqual(@as(u8, 1), dec_lt(m1, 1));

        // of_int / to_int roundtrip through the runtime's Int objects
        testEnsureRuntime();
        const to_int = if (comptime std.mem.eql(u8, name, "int64"))
            Self.lean_int64_to_int_sint
        else
            @field(Self, "lean_" ++ name ++ "_to_int");
        const of_int = @field(Self, "lean_" ++ name ++ "_of_int");
        const neg42 = lean_int64_to_int(-42);
        const carried = of_int(neg42);
        try std.testing.expectEqual(u.of(-42), carried);
        const back = to_int(carried);
        try std.testing.expectEqual(@as(u8, 1), lean_int_dec_eq(back, neg42));
        lean_dec(back);
        lean_dec(neg42);
    }
}

test "signed cross-width conversions sign-extend and truncate" {
    try std.testing.expectEqual(@as(u64, @bitCast(@as(i64, -5))), lean_int8_to_int64(@bitCast(@as(i8, -5))));
    try std.testing.expectEqual(@as(u8, @bitCast(@as(i8, -1))), lean_int64_to_int8(@bitCast(@as(i64, -1))));
    try std.testing.expectEqual(@as(u8, 0x34), lean_int64_to_int8(0x1234)); // truncation
    try std.testing.expectEqual(@as(u64, @bitCast(@as(i64, -7))), lean_isize_to_int64(@bitCast(@as(isize, -7))));
    try std.testing.expectEqual(@as(usize, @bitCast(@as(isize, -7))), lean_int64_to_isize(@bitCast(@as(i64, -7))));
}

// --- M3: Float / Float32 --------------------------------------------------------

test "float bit conversions and saturating casts" {
    testEnsureRuntime();
    try std.testing.expectEqual(@as(u64, 0x3FF8000000000000), lean_float_to_bits(1.5));
    try std.testing.expectEqual(@as(f64, 1.5), lean_float_of_bits(0x3FF8000000000000));
    try std.testing.expectEqual(@as(u32, 0x3FC00000), lean_float32_to_bits(1.5));
    try std.testing.expectEqual(@as(f32, 1.5), lean_float32_of_bits(0x3FC00000));

    // saturation per lean.h: clamp to min/max, NaN -> 0
    try std.testing.expectEqual(@as(u8, 127), lean_float_to_int8(200.0));
    try std.testing.expectEqual(@as(u8, @bitCast(@as(i8, -128))), lean_float_to_int8(-200.0));
    try std.testing.expectEqual(@as(u8, 0), lean_float_to_int8(std.math.nan(f64)));
    try std.testing.expectEqual(@as(u8, 255), lean_float32_to_uint8(300.0));
    try std.testing.expectEqual(@as(u8, 0), lean_float32_to_uint8(-1.0));
    try std.testing.expectEqual(@as(u64, @bitCast(@as(i64, -3))), lean_float_to_int64(-3.7));
    try std.testing.expectEqual(@as(usize, @bitCast(@as(isize, -3))), lean_float_to_isize(-3.7));
    try std.testing.expect(lean_float32_isnan(std.math.nan(f32)) != 0);
    try std.testing.expect(lean_float32_isinf(std.math.inf(f32)) != 0);
}

test "float32 boxing and ctor float fields" {
    testEnsureRuntime();
    const b = lean_box_float32(2.25);
    try std.testing.expectEqual(@as(f32, 2.25), lean_unbox_float32(b));
    lean_dec(b);

    // ctor with one object field and a float32 + float scalar area
    const o = lean_alloc_ctor(0, 1, @sizeOf(f64) + @sizeOf(f32));
    lean_ctor_set(o, 0, lean_box(1));
    const scalar_base: c_uint = @sizeOf(*anyopaque) * 1;
    lean_ctor_set_float(o, scalar_base, 6.5);
    lean_ctor_set_float32(o, scalar_base + @sizeOf(f64), -1.5);
    try std.testing.expectEqual(@as(f64, 6.5), lean_ctor_get_float(o, scalar_base));
    try std.testing.expectEqual(@as(f32, -1.5), lean_ctor_get_float32(o, scalar_base + @sizeOf(f64)));
    lean_dec(o);
}

// --- M3: Nat / Int boundaries ----------------------------------------------------

test "int euclidean and exact division, scalar and bignum" {
    testEnsureRuntime();
    const n7 = lean_int64_to_int(-7);
    const p2 = lean_int64_to_int(2);
    const q = lean_int_ediv(n7, p2);
    const r = lean_int_emod(n7, p2);
    const exp_q = lean_int64_to_int(-4);
    const exp_r = lean_int64_to_int(1);
    try std.testing.expectEqual(@as(u8, 1), lean_int_dec_eq(q, exp_q));
    try std.testing.expectEqual(@as(u8, 1), lean_int_dec_eq(r, exp_r));
    for ([_]LeanPtr{ n7, p2, q, r, exp_q, exp_r }) |x| lean_dec(x);

    // bignum path: (-2^65) ediv 2 == -2^64
    const big = lean_cstr_to_int("-36893488147419103232");
    const two = lean_int64_to_int(2);
    const bq = lean_int_ediv(big, two);
    const exp_bq = lean_cstr_to_int("-18446744073709551616");
    try std.testing.expectEqual(@as(u8, 1), lean_int_dec_eq(bq, exp_bq));
    for ([_]LeanPtr{ big, two, bq, exp_bq }) |x| lean_dec(x);

    const t = lean_int64_to_int(-12);
    const f = lean_int64_to_int(4);
    const e = lean_int_div_exact(t, f);
    const exp_e = lean_int64_to_int(-3);
    try std.testing.expectEqual(@as(u8, 1), lean_int_dec_eq(e, exp_e));
    for ([_]LeanPtr{ t, f, e, exp_e }) |x| lean_dec(x);

    const nd = lean_nat_div_exact(lean_box(12), lean_box(4));
    try std.testing.expectEqual(@as(usize, 3), lean_unbox(nd));
}

test "nat scalar<->bignum boundary in both directions" {
    testEnsureRuntime();
    // usize max does not fit in a scalar nat
    const big = lean_usize_to_nat(std.math.maxInt(usize));
    try std.testing.expect(!lean_is_scalar(big));
    const expected = lean_cstr_to_nat("18446744073709551615");
    try std.testing.expectEqual(@as(u8, 1), lean_nat_dec_eq(big, expected));
    // subtracting brings it back below the scalar boundary
    const small = lean_nat_sub(big, expected);
    try std.testing.expect(lean_is_scalar(small));
    try std.testing.expectEqual(@as(usize, 0), lean_unbox(small));
    lean_dec(big);
    lean_dec(expected);
}

// --- M3: strings ------------------------------------------------------------------

test "utf8 string accessors on multi-byte content" {
    testEnsureRuntime();
    const s = lean_mk_string("h\xc3\xa9\xce\xbb\xf0\x9f\x8c\x8d!"); // "héλ🌍!"
    try std.testing.expectEqual(@as(usize, 5), lean_string_len(s)); // codepoints
    try std.testing.expectEqual(@as(usize, 11), lean_string_size(s)); // bytes + NUL
    try std.testing.expectEqual(@as(u32, 'h'), lean_string_utf8_get(s, lean_box(0)));
    try std.testing.expectEqual(@as(u32, 0xE9), lean_string_utf8_get(s, lean_box(1))); // é
    try std.testing.expectEqual(@as(u32, 0x1F30D), lean_string_utf8_get(s, lean_box(5))); // 🌍
    const next = lean_string_utf8_next(s, lean_box(1));
    try std.testing.expectEqual(@as(usize, 3), lean_unbox(next)); // é is 2 bytes
    try std.testing.expectEqual(@as(u8, 'h'), lean_string_get_byte_fast(s, lean_box(0)));
    lean_dec(s);
}

test "unchecked string constructors and memcmp" {
    testEnsureRuntime();
    const a = lean_mk_string_from_bytes_unchecked("abc", 3);
    try std.testing.expectEqualStrings("abc", std.mem.span(lean_string_cstr(a)));
    try std.testing.expectEqual(@as(usize, 3), lean_string_len(a));
    const b = lean_mk_ascii_string_unchecked("abd");
    // equal prefixes compare equal; differing bytes do not
    try std.testing.expectEqual(@as(u8, 1), lean_string_memcmp(a, b, lean_box(0), lean_box(0), lean_box(2)));
    try std.testing.expectEqual(@as(u8, 0), lean_string_memcmp(a, b, lean_box(0), lean_box(0), lean_box(3)));
    lean_dec(a);
    lean_dec(b);
}

// --- M3: arrays --------------------------------------------------------------------

test "array copy-on-write via ensure_exclusive" {
    testEnsureRuntime();
    var a = lean_mk_empty_array();
    a = lean_array_push(a, lean_box(1));
    a = lean_array_push(a, lean_box(2));
    // shared array: uset must copy, leaving the original intact
    lean_inc(a);
    const a2 = lean_array_uset(a, 0, lean_box(9));
    try std.testing.expect(a2 != a);
    try std.testing.expectEqual(@as(usize, 1), lean_unbox(lean_array_uget(a, 0)));
    try std.testing.expectEqual(@as(usize, 9), lean_unbox(lean_array_uget(a2, 0)));
    lean_dec(a2);
    // exclusive array: uset mutates in place
    const a3 = lean_array_uset(a, 1, lean_box(7));
    try std.testing.expect(a3 == a);
    lean_dec(a3);
}

test "borrowed array getters do not touch refcounts" {
    testEnsureRuntime();
    var a = lean_mk_empty_array();
    const s = lean_mk_string("elem");
    lean_inc(s); // keep our own reference
    a = lean_array_push(a, s);
    const rc_before = s.m_rc;
    const got = lean_array_uget_borrowed(a, 0);
    try std.testing.expect(got == s);
    try std.testing.expectEqual(rc_before, s.m_rc);
    // owned uget increments
    const got_owned = lean_array_uget(a, 0);
    try std.testing.expectEqual(rc_before + 1, s.m_rc);
    lean_dec(got_owned);
    const def = lean_mk_string("default");
    _ = lean_array_get_borrowed(def, a, lean_box(0));
    try std.testing.expectEqual(@as(c_int, 1), def.m_rc);
    lean_dec(def);
    lean_dec(a);
    lean_dec(s);
}

test "array_to_list and byte/float arrays" {
    testEnsureRuntime();
    var a = lean_mk_empty_array();
    a = lean_array_push(a, lean_box(1));
    const l = lean_array_to_list(a); // consumes a
    try std.testing.expectEqual(@as(c_uint, 1), lean_obj_tag(l)); // List.cons
    try std.testing.expectEqual(@as(usize, 1), lean_unbox(lean_ctor_get(l, 0)));
    const tail = lean_ctor_get(l, 1);
    try std.testing.expect(lean_is_scalar(tail)); // List.nil == lean_box(0)
    try std.testing.expectEqual(@as(usize, 0), lean_unbox(tail));
    lean_dec(l);

    var ba = lean_mk_empty_byte_array(lean_box(0));
    ba = lean_byte_array_push(ba, 0xAB);
    ba = lean_byte_array_push(ba, 0xCD);
    try std.testing.expectEqual(@as(u8, 0xCD), lean_byte_array_uget(ba, 1));
    try std.testing.expectEqual(@as(usize, 2), lean_unbox(lean_byte_array_size(ba)));
    try std.testing.expectEqual(lean_object_data_byte_size(ba), lean_sarray_data_byte_size(ba));
    lean_dec(ba);

    var fa = lean_mk_empty_float_array(lean_box(0));
    fa = lean_float_array_push(fa, 1.5);
    try std.testing.expectEqual(@as(f64, 1.5), lean_float_array_uget(fa, 0));
    lean_dec(fa);
}

// --- M3: ctor scalar fields and byte sizes -----------------------------------------

test "ctor scalar fields and runtime byte-size agreement" {
    testEnsureRuntime();
    const o = lean_alloc_ctor(5, 1, @sizeOf(usize) + 1);
    lean_ctor_set(o, 0, lean_box(3));
    lean_ctor_set_usize(o, 1, 9999);
    const byte_off: c_uint = @sizeOf(*anyopaque) * 1 + @sizeOf(usize);
    lean_ctor_set_uint8(o, byte_off, 0x5A);
    try std.testing.expectEqual(@as(usize, 9999), lean_ctor_get_usize(o, 1));
    try std.testing.expectEqual(@as(u8, 0x5A), lean_ctor_get_uint8(o, byte_off));
    lean_ctor_release(o, 0); // dec + null the object field
    lean_dec(o);

    // inline byte-size helpers agree with the runtime's lean_object_data_byte_size
    const s = lean_mk_string("hello!");
    try std.testing.expectEqual(lean_object_data_byte_size(s), lean_string_data_byte_size(s));
    lean_dec(s);
    var arr = lean_mk_empty_array();
    arr = lean_array_push(arr, lean_box(1));
    try std.testing.expectEqual(lean_object_data_byte_size(arr), lean_array_data_byte_size(arr));
    lean_dec(arr);
}

// --- M3: ownership, MT/persistent, externals ----------------------------------------

test "io_result_take_value transfers ownership" {
    testEnsureRuntime();
    const v = lean_mk_string("payload");
    const r = lean_io_result_mk_ok(v);
    const taken = lean_io_result_take_value(r); // consumes r
    try std.testing.expect(taken == v);
    try std.testing.expectEqual(@as(c_int, 1), taken.m_rc);
    lean_dec(taken);
}

test "multi-threaded and persistent refcount paths" {
    testEnsureRuntime();
    const o = lean_alloc_ctor(0, 1, 0);
    lean_ctor_set(o, 0, lean_box(1));
    lean_mark_mt(o);
    try std.testing.expect(o.m_rc < 0);
    const rc0 = o.m_rc;
    lean_inc(o); // atomic sub on negative rc
    try std.testing.expectEqual(rc0 - 1, o.m_rc);
    lean_dec(o);
    try std.testing.expectEqual(rc0, o.m_rc);
    lean_dec(o); // frees through the MT path

    const p = lean_alloc_ctor(0, 0, 0);
    lean_mark_persistent(p);
    try std.testing.expectEqual(@as(c_int, 0), p.m_rc);
    lean_inc(p);
    lean_dec(p);
    try std.testing.expectEqual(@as(c_int, 0), p.m_rc); // rc never moves
}

var test_finalized: bool = false;
test "external classes: wrap, unwrap, finalize" {
    testEnsureRuntime();
    const S = struct {
        fn finalize(data: ?*anyopaque) callconv(.c) void {
            _ = data;
            test_finalized = true;
        }
        fn foreach(data: ?*anyopaque, arg: b_lean_obj_arg) callconv(.c) void {
            _ = data;
            _ = arg;
        }
    };
    const cls = lean_register_external_class(&S.finalize, &S.foreach);
    const payload: *anyopaque = @ptrFromInt(0x1234);
    const e = lean_alloc_external(cls, payload);
    try std.testing.expect(lean_is_external(e));
    try std.testing.expectEqual(@as(?*anyopaque, payload), lean_get_external_data(e));
    // exclusive set_external_data mutates in place
    const e2 = lean_set_external_data(e, @ptrFromInt(0x5678));
    try std.testing.expect(e2 == e);
    try std.testing.expectEqual(@as(?*anyopaque, @ptrFromInt(0x5678)), lean_get_external_data(e2));
    try std.testing.expect(!test_finalized);
    lean_dec(e2);
    try std.testing.expect(test_finalized);
}

// --- M3: thunks and tasks -------------------------------------------------------------

test "thunks: pure and lazily forced closures" {
    testEnsureRuntime();
    const t = lean_thunk_pure(lean_box(5));
    const v = lean_thunk_get_own(t);
    try std.testing.expectEqual(@as(usize, 5), lean_unbox(v));
    lean_dec(t);

    const S = struct {
        fn compute(unit: lean_obj_arg) callconv(.c) lean_obj_res {
            lean_dec(unit);
            return lean_box(7);
        }
    };
    const cl = lean_alloc_closure(@ptrCast(@constCast(&S.compute)), 1, 0);
    const lazy = lean_mk_thunk(cl);
    const forced = lean_thunk_get_own(lazy);
    try std.testing.expectEqual(@as(usize, 7), lean_unbox(forced));
    lean_dec(lazy);
}

test "tasks: spawn through the task manager and query state" {
    testEnsureRuntime();
    lean_init_task_manager();
    const S = struct {
        fn work(unit: lean_obj_arg) callconv(.c) lean_obj_res {
            lean_dec(unit);
            return lean_box(11);
        }
    };
    const cl = lean_alloc_closure(@ptrCast(@constCast(&S.work)), 1, 0);
    const t = lean_task_spawn(cl, lean_box(0));
    const v = lean_task_get_own(t);
    try std.testing.expectEqual(@as(usize, 11), lean_unbox(v));

    const done = lean_task_pure(lean_box(0));
    try std.testing.expectEqual(@as(u8, 2), lean_io_get_task_state_core(done)); // finished
    lean_dec(done);
}

test "unsigned integer families follow C semantics" {
    const fams = .{
        .{ "uint8", u8 },
        .{ "uint16", u16 },
        .{ "uint32", u32 },
        .{ "uint64", u64 },
        .{ "usize", usize },
    };
    inline for (fams) |f| {
        const name = f[0];
        const uT = f[1];
        const Self = @This();
        const add = @field(Self, "lean_" ++ name ++ "_add");
        const mul = @field(Self, "lean_" ++ name ++ "_mul");
        const div = @field(Self, "lean_" ++ name ++ "_div");
        const mod = @field(Self, "lean_" ++ name ++ "_mod");
        const neg = @field(Self, "lean_" ++ name ++ "_neg");
        const max: uT = std.math.maxInt(uT);

        try std.testing.expectEqual(@as(uT, 0), add(max, 1)); // wraps
        try std.testing.expectEqual(max - 1, mul(max, 2)); // wraps
        try std.testing.expectEqual(@as(uT, 0), div(@as(uT, 5), 0)); // x/0 = 0
        try std.testing.expectEqual(@as(uT, 7), mod(@as(uT, 7), 0)); // x%0 = x
        try std.testing.expectEqual(max, neg(1)); // two's complement
    }
}

# Plan: Full FFI Surface Completeness & Testing

**Date:** 2026-06-03 · **Status: COMPLETE (2026-06-03)**
**Target:** Lean v4.30.0 (`lean-toolchain`) · Zig 0.16.0
**Reference:** [Lean FFI documentation](https://lean-lang.org/doc/reference/latest/Run-Time-Code/Foreign-Function-Interface/#ffi)

> Outcome: surface complete (0 missing modulo allowlist), 30 behavioral
> tests, self-asserting conformance examples, CI gates. Found & fixed along
> the way: LeanMaxCtorTag/LeanPromise tag drift, scalar Int 32-bit payload
> encoding (3 pre-existing bugs). Deviations: CI installs zig+elan directly
> (mlugg/setup-zig + elan-init) instead of `nix develop` — standard elan
> proxies are hardlinks and don't hit the nix-symlink findProgram issue;
> Windows remains unsupported (documented in README/workflow).

## Background

`src/lean.zig` is a manual translation of `lean.h`, originally written against
Lean v4.4.0. The v4.30.0 migration fixed all *drifted* translations (audited by
diffing every function body between the two headers), but the binding surface
is still 4.4-shaped. Measured against v4.30.0's `lean.h`:

| Surface | In lean.h 4.30 | Missing from bindings |
|---|---|---|
| `static inline` functions (need Zig re-implementation) | 562 | **216** |
| `LEAN_EXPORT` externs (need a one-line declaration) | 208 | **~42** (45 minus 3 intentionally excluded) |

Gap lists are regenerated with the inventory script (Milestone 0). Inline
translations carry semantic risk (the linker cannot catch a wrong body);
extern declarations carry almost none.

**Intentionally excluded externs:** `lean_alloc_small`, `lean_free_small`,
`lean_small_mem_size` — declared in `lean.h` but **not exported** by official
binaries, which are built with `LEAN_MIMALLOC`. The bindings use
`mi_malloc_small`/`mi_free` instead (see `lean_alloc_small_object`).

## Guiding principles (from the FFI reference)

- **ABI fidelity** — each Lean type's C representation must be mirrored
  exactly: `UInt8`–`UInt64`/`USize` → `u8`–`u64`/`usize`, `Int8`–`Int64`/`ISize` →
  signed ints, `Char` → `u32`, `Float` → `f64`, `Float32` → `f32`, `Nat`/`Int` →
  `lean_object *` with scalar (lowest-bit) encoding, `Unit` → `lean_box(0)`,
  enum-like inductives → `lean_box(cidx)` / `uint8`.
- **Ownership model** — `lean_object *` parameters are *owned* by default
  (callee consumes an RC token); `@&` parameters are *borrowed* (callee must
  not consume; may `lean_inc` to take ownership). Every binding must encode
  the correct convention — getting this wrong is a refcount bug, not a
  compile error (cf. the `lean_array_get` def_val drift found 2026-06-03).
- **Initialization protocol** — `lean_initialize_runtime_module()` (runtime
  only) vs `lean_initialize()` (full Lean package), `lean_setup_args()` before
  init when libuv process functionality is used, per-module
  `initialize_<pkg>_<Module>(uint8_t builtin)` (package-prefixed since ~4.9,
  idempotent, **not** thread-safe), `lean_io_mark_end_initialization()`, and
  `lean_initialize_thread()`/`lean_finalize_thread()` for non-Lean threads.

---

## Milestone 0 — Inventory & tooling

Make the gap measurable and re-runnable so progress is mechanical, not
guesswork.

- [x] Add `tools/ffi-inventory.pl` (or `.zig`): extracts every `static inline`
      fn and `LEAN_EXPORT` extern from the active toolchain's `lean.h`,
      compares against `pub fn`/`pub extern fn` decls in `src/lean.zig`,
      prints missing/extra/excluded
- [x] Add `tools/ffi-drift.pl`: per-function normalized body diff between two
      `lean.h` versions (the tool that caught the 5 silent 4.30 bugs)
- [x] Check in an allowlist file for intentional exclusions with reasons
      (`lean_alloc_small` family; `_Atomic` parse artifact)
- [x] Wire both into `zig build` steps (`zig build ffi-inventory`,
      `zig build ffi-drift`) so they run without remembering perl incantations
- [x] Record baseline counts in this doc

> Baseline 2026-06-03 (v4.30.0): 216 missing inline translations, 42 missing
> externs (after allowlist). `zig build ffi-inventory` fails until both are 0.

## Milestone 1 — Extern declaration completeness (~42 decls, low risk)

One-line `pub extern fn` declarations; the linker verifies existence via the
`compile_test`. Grouped by family:

- [x] Float bit-level & string ops: `lean_float_to_bits`, `lean_float_of_bits`,
      `lean_float_frexp`(if missing), `lean_float32_to_bits`,
      `lean_float32_of_bits`, `lean_float32_to_string`, `lean_float32_frexp`,
      `lean_float32_scaleb`, `lean_float32_isnan/isinf/isfinite`
- [x] Big-int bridges: `lean_int8/16/32/64_of_big_int`, `lean_isize_of_big_int`,
      `lean_int_big_ediv/emod/div_exact`, `lean_nat_big_div_exact`,
      `lean_nat_big_shiftr`
- [x] String: `lean_mk_string_unchecked`, `lean_mk_ascii_string_unchecked`,
      `lean_mk_string_from_bytes_unchecked`, `lean_string_memcmp`,
      `lean_string_of_usize`
- [x] Once/lazy-init cold paths: `lean_obj_once_cold`,
      `lean_uint8/16/32/64_once_cold`, `lean_usize_once_cold`,
      `lean_float_once_cold`, `lean_float32_once_cold`
- [x] Misc: `lean_array_to_list`, `lean_object_data_byte_size`, `lean_panic`,
      `lean_panic_fn_borrowed`, `lean_run_main`, `lean_decode_uv_error`,
      `lean_io_get_task_state_core`, `lean_slice_hash`, `lean_slice_dec_lt`
- [x] Re-run inventory: missing-extern count is 0 modulo allowlist
- [x] `zig build test` green (compile_test now links every new extern)

## Milestone 2 — Inline translation completeness (216 fns, semantic risk)

Translate in families, each with its upstream body read side-by-side. Every
family lands together with its Milestone 3 tests.

- [x] **Signed integers** (~120 fns): `Int8`/`Int16`/`Int32`/`Int64`/`ISize` —
      `add/sub/mul/div/mod/neg/abs/complement/land/lor/xor/shift_left/
      shift_right/dec_eq/dec_le/dec_lt/of_int/of_nat/to_*` for each width.
      Mind C semantics: wrapping arithmetic, shift masking, division by zero
      → 0 / `a`, `INT_MIN` edge cases
- [x] **Float32** (~30 fns): arithmetic, comparisons, conversions to/from all
      integer widths, `lean_box_float32`/`lean_unbox_float32`,
      `lean_ctor_get_float32`/`lean_ctor_set_float32`
- [x] **Remaining conversions** (~25 fns): `lean_bool_to_*`, `lean_uint*_neg`,
      `lean_uint*_to_float/float32`, `lean_usize_to_uint8/16`,
      `lean_float_to_int*`/`isize`, `lean_float_to_float32`/`float32_to_float`
- [x] **Once helpers**: `lean_obj_once`, `lean_uint8/16/32/64_once`,
      `lean_usize_once`, `lean_float_once`, `lean_float32_once` (pair with
      their `_cold` externs from M1; double-checked locking semantics)
- [x] **Borrowed accessors**: `lean_array_get_borrowed`,
      `lean_array_fget_borrowed`, `lean_array_uget_borrowed`,
      `lean_io_result_take_value` — these encode the `@&` borrowing
      convention from the reference
- [x] **Object/alloc helpers**: `lean_del_object`, `lean_void_mk`,
      `lean_is_exclusive_obj`, `lean_set_external_data`,
      `lean_closure_arg_cptr`, `lean_closure_byte_size`,
      `lean_closure_data_byte_size`, `lean_array_data_byte_size`,
      `lean_sarray_data_byte_size`, `lean_string_data_byte_size`,
      `lean_sarray_would_overflow`, `lean_usize_add/mul_would_overflow`,
      `lean_string_get_byte_fast`
- [x] **Promises**: `lean_is_promise`, `lean_to_promise` (+ verify the
      `lean_promise_*` externs are declared)
- [x] **Int/Nat exact division**: `lean_int_ediv`, `lean_int_emod`,
      `lean_int_div_exact`, `lean_nat_div_exact`
- [x] **Platform helpers**: `lean_system_platform_target`,
      `lean_manual_get_root`, `lean_runtime_hold` (read upstream docs/usage
      first; skip-with-reason if not meaningful from Zig)
- [x] Re-run inventory: missing-inline count is 0 modulo allowlist
- [x] Add every new pub decl to `compile_test`

## Milestone 3 — Behavioral test coverage of the ABI

Extend the in-`lean.zig` test suite (10 tests today) so every type
representation and convention in the reference's ABI section is exercised
against the live runtime.

- [x] **Scalar ABI**: each `UIntN`/`IntN`/`USize`/`ISize` family — wrapping
      mul/add, div/mod-by-zero conventions, shift semantics, signed `abs` of
      `INT_MIN`, boundary conversions (cross-checked against Lean-evaluated
      expected values where practical)
- [x] **Float/Float32**: box/unbox roundtrip, ctor float fields
      (`lean_ctor_get/set_float{,32}`), `to_bits`/`of_bits` roundtrip, NaN/inf
      classification
- [x] **Nat/Int**: scalar↔bignum boundary in both directions for add, sub,
      mul, div, mod, ediv/emod, shiftr, comparisons; `lean_cstr_to_nat`
      roundtrips
- [x] **String**: UTF-8 multi-byte content through `lean_string_len` vs
      `lean_string_size`, `utf8_get/next` fast paths vs `_cold` fallbacks,
      `lean_string_memcmp`, unchecked constructors
- [x] **Array/ByteArray/FloatArray**: push/get/set/uset exclusivity
      (`lean_ensure_exclusive_array` copy-on-write observable via pointer
      change), borrowed getters leave refcounts untouched, sarray element
      access, `lean_array_to_list` roundtrip
- [x] **Ctor objects**: scalar fields (`lean_ctor_get/set_usize/uint8/...`),
      object+scalar mixed layout, `lean_ctor_release`, `lean_obj_byte_size`
      agreement between bindings and runtime (`lean_object_data_byte_size`)
- [x] **Ownership/borrowing**: for each owned-vs-borrowed pair in the
      bindings, an explicit refcount assertion test (pattern: the
      `lean_array_get` borrowed-def_val test from 2026-06-03)
- [x] **MT/persistent objects**: `lean_mark_mt` / `lean_mark_persistent`
      paths — inc/dec on negative-rc and zero-rc objects (currently untested;
      exercises the atomic-sub `lean_inc_ref_n`)
- [x] **External classes**: register a `lean_external_class` from Zig with
      finalizer + foreach, wrap/unwrap data, observe finalizer runs on dec
- [x] **Thunks/Tasks/Promises**: thunk pure+get, task spawn (not just pure),
      `lean_io_get_task_state_core`, promise new/resolve/result — note: lean.h
      exposes no C-level promise constructors; covered is_promise/to_promise only
- [x] All tests pass under `zig build test` on macOS (arm64) and Linux —
      macOS verified locally; Linux gated by CI in Milestone 5

## Milestone 4 — FFI conformance examples (the reference, end to end)

The examples are the doc-conformance fixtures: each section of the official
FFI page should have a working counterpart in `examples/`.

- [x] **`@[extern]` with borrowing**: extend `examples/ffi` with a Lean
      `@[extern]` binding that uses `@&` borrowed parameters implemented in
      Zig (verifies the borrowed convention crossing the real compiler, not
      just our test harness)
- [x] **`@[export]`**: extend `examples/reverse-ffi` with a Lean `@[export]`
      function (unmangled name) called from Zig alongside the generated
      `initialize_<pkg>_<Module>` flow
- [x] **Enum-like inductives**: pass a small Lean inductive (uint8 cidx ABI)
      and an `Option`-style boxed inductive across the boundary both ways
- [x] **Initialization protocol**: reverse-ffi app demonstrates correct order —
      optional `lean_setup_args`, `lean_initialize_runtime_module` (or
      `lean_initialize` when Lean-package code is used), module init with
      `builtin = 1`, `lean_io_mark_end_initialization`
- [x] **Threads**: a Zig-spawned thread calls into Lean wrapped in
      `lean_initialize_thread`/`lean_finalize_thread`
- [x] README: document which example demonstrates which reference section
- [x] `zig build zffi` and `zig build rffi` outputs asserted in a script (not
      eyeballed) so CI can gate on them

## Milestone 5 — CI & maintenance

- [x] GitHub Actions: macOS + Linux matrix running `zig build test`, `rffi`,
      `zffi` via `nix develop` (restore/replace the old windows workflow
      in `.github/` as a follow-up decision)
- [x] CI step: `ffi-inventory` must report 0 missing (modulo allowlist) —
      completeness can't regress silently
- [x] Toolchain-bump checklist in `CONTRIBUTING`/README: bump
      `lean-toolchain` → run `ffi-drift` old-vs-new → fix flagged bodies →
      `zig build test` → examples
- [x] Decide & document a policy for Lean version support (latest stable
      only, like today, vs. a compatibility shim layer)
- [x] Update project memory + this plan's checkboxes as milestones land

---

## Definition of done

- `ffi-inventory` reports zero missing externs and zero missing inline
  translations against the pinned toolchain's `lean.h` (allowlist excepted).
- Every ABI category in the FFI reference has at least one behavioral test
  executing against `libleanshared`, including ownership/borrowing refcount
  assertions and the MT path.
- Each section of the FFI reference doc maps to a working example or test
  named in the README.
- CI fails on: missing surface, drifted bodies at bump time, broken examples.

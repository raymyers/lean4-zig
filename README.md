# lean4-zig

Zig bindings for Lean4's C API.

Functions and comments manually translated from those in the [`lean.h` header](https://github.com/leanprover/lean4/blob/master/src/include/lean/lean.h) provided with Lean 4

### Required

- [zig](https://ziglang.org/download/) v0.16.0
- [lean4](https://leanprover.github.io/download/) v4.30.0 (installed automatically by [elan](https://github.com/leanprover/elan) from `lean-toolchain`)

Or with Nix: `nix develop` provides zig and elan (see `flake.nix`).


### How to run

Both example targets assert their expected output, so a successful build *is*
the test.

- **FFI** (zig lib ⇒ lean4 app)
```bash
$> zig build zffi   # asserts: 3, 5, 65280, 39
```

- **Reverse-FFI** (lean4 lib ⇒ zig app)
```bash
$> zig build rffi   # asserts: output: 6, double: 84, thread: 7
```

- **Binding tests** (run every translated function against `libleanshared`)
```bash
$> zig build test
```

### FFI reference coverage

The examples double as conformance fixtures for the
[Lean FFI documentation](https://lean-lang.org/doc/reference/latest/Run-Time-Code/Foreign-Function-Interface/#ffi):

| Reference concept | Demonstrated in |
|---|---|
| `@[extern]` calling Zig | `examples/ffi/lib/lean/FFI/Add.lean` + `zig/ffi.zig` |
| `@&` borrowed parameters | `myStringLen` in `examples/ffi/lib/lean/FFI/Misc.lean` |
| Enum-like inductives (uint8 ctor index) | `colorCode` in `FFI/Misc.lean` |
| Boxed inductives & ownership (`Option`) | `optionOrZero` in `FFI/Misc.lean` |
| `@[export]` called from Zig | `my_length`/`my_double` in `examples/reverse-ffi/lib/RFFI.lean` |
| Initialization protocol & `builtin` flag | `examples/reverse-ffi/app/app.zig` |
| `lean_initialize_thread`/`lean_finalize_thread` | `lengthFromOtherThread` in `app.zig` |
| ABI type representations & ownership rules | behavioral tests at the end of `src/lean.zig` |

### Maintenance tooling

```bash
$> zig build ffi-inventory   # binding completeness vs the toolchain's lean.h
$> zig build ffi-drift -- old/lean.h new/lean.h   # semantic drift between versions
```

When bumping `lean-toolchain`: run `ffi-drift` against the old and new
`lean.h`, audit every listed function against `src/lean.zig`, check the tag
`#define`s (constants are invisible to the drift tool), then run
`zig build test`, `zffi`, and `rffi`.

**Version policy:** `main` tracks exactly the Lean version pinned in
`lean-toolchain` (latest stable at the time of the bump). Older Lean
versions are not supported on `main` — check out the commit that pinned
them. Windows is currently unsupported (the mimalloc allocator path and
`leanshared.dll` linking are unverified).

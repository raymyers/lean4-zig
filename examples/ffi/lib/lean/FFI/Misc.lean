/-- Enum-like inductive: passed to C as `uint8_t` carrying the ctor index. -/
inductive Color where
  | red
  | green
  | blue

@[extern "my_color_code"]
opaque colorCode : Color → UInt32

/-- `@&` marks the parameter as *borrowed*: the Zig side must not consume it. -/
@[extern "my_string_len"]
opaque myStringLen : @&String → Nat

/-- Boxed inductive: `none` is `lean_box(0)`, `some x` is a ctor object.
The parameter is owned, so the Zig side consumes it. -/
@[extern "my_option_or_zero"]
opaque optionOrZero : Option Nat → Nat

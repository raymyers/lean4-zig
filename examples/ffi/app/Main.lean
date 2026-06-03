import FFI

def main : IO Unit := do
  IO.println <| myAdd 1 2
  IO.println <| myStringLen "hello"
  IO.println <| colorCode .green
  IO.println <| optionOrZero (some 39)

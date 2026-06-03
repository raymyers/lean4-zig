@[export my_length]
def myLength (s : String) : UInt64 :=
  s.length.toUInt64

@[export my_double]
def myDouble (n : UInt64) : UInt64 :=
  n * 2

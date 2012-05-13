/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity low)
module dil.String;

import common;

/// A string implementation that uses two pointers,
/// as opposed to one pointer and a size variable.
struct StringT(C)
{
  alias StringT S; /// Shortcut to own type.
  C* ptr; /// Points to the beginning of the string.
  C* end; /// Points one past the end of the string.

  /// Constructs from an array string.
  this(inout(C)[] str) inout
  {
    ptr = str.ptr;
    end = str.ptr + str.length;
  }

  /// Constructs from start and end pointers.
  this(inout(C)* p, inout(C)* e) inout
  {
    ptr = p;
    end = e;
  }

  /// Checks pointers.
  invariant()
  {
    assert(ptr <= end);
    if (ptr is null) assert(end is null);
  }

  /// Returns a slice.
  inout(S) opSlice(size_t x, size_t y) inout
  {
    return *new S(ptr + x, ptr + y);
  }

  /// Compares the bytes of two Strings for exact equality.
  int opEquals(ref inout(S) s) inout
  {
    if (len != s.len)
      return 0;
    inout(C)* p = ptr, p2 = s.ptr;
    while (p < end)
      if (*p++ != *p2++)
        return 0;
    return 1;
  }

  /// Compares to a boolean value.
  int opEquals(bool b) inout
  {
    return cast(bool)this == b;
  }

  /// Compares the bytes of two Strings.
  int opCmp(ref inout(S) s) inout
  {
    auto l = len, l2 = s.len;
    if (l != l2)
      return l < l2 ? -1 : 1;
    inout(C)* p = ptr, p2 = s.ptr;
    while (p < end)
      if (*p < *p2)
        return -1;
      else
      if (*p++ < *p2++)
        return  1;
    return 0;
  }

  /// Concatenates x copies of this string.
  S opBinary(string op)(uint rhs) inout if (op == "*")
  {
    C[] result;
    for (; rhs; rhs--)
      result ~= this.toChars();
    return S(result);
  }

  /// Concatenates x copies of this string.
  S opBinaryRight(string op)(uint lhs) inout if (op == "*")
  {
    return opBinary!("*")(lhs);
  }

  /// Converts to bool.
  bool opCast(T : bool)() inout
  {
    return !isEmpty();
  }

  /// Converts to an array string.
  inout(C)[] opCast(T : inout(C)[])() inout
  {
    return ptr[0..len];
  }

  /// Returns the byte length.
  @property size_t len() inout
  {
    return end - ptr;
  }

  /// Returns a copy.
  @property S dup() inout
  {
    return S(ptr[0..len].dup);
  }

  /// Returns true if pointers are null.
  bool isNull() inout
  {
    return ptr is null;
  }

  /// Returns true if the string is empty.
  bool isEmpty() inout
  {
    return ptr is end;
  }

  /// Returns an array string.
  inout(C)[] toChars() inout
  {
    return ptr[0..len];
  }

  /// Splits by character c and returns a list of string slices.
  inout(S)[] split(inout(C) c) inout
  {
    inout(S)[] result;
    inout(C)* p = ptr, prev = p;
    for (; p < end; p++)
      if (*p == c) {
        result ~= *new S(prev, p);
        prev = p;
      }
    return result;
  }

  /// Substitutes a with b in this string.
  /// Returns: Itself.
  ref S sub(C a, C b)
  {
    auto p = ptr;
    for (; p < end; p++)
      if (*p == a)
        *p = b;
    return this;
  }
}

alias StringT!(char)  String;  /// Instantiation for char.
alias StringT!(wchar) WString; /// Instantiation for wchar.
alias StringT!(dchar) DString; /// Instantiation for dchar.

unittest
{
  scope msg = new UnittestMsg("Testing struct String.");
  alias String S;

  if (S("is cool")) {}
  else assert(0);
  assert(S() == false && !S());
  assert(S("") == false && !S(""));
  assert(S() == S("") && "" == null);
  assert(S("verdad") == true);


  assert(S("abce".dup).sub('e', 'd') == S("abcd"));

  assert(S("chica").dup == S("chica"));

  assert(S("a") < S("b"));

  assert(S("ha") * 6 == S("hahahahahaha"));
  assert(S("palabra") * 0 == S());
  assert(1 * S("mundo") == S("mundo"));

  assert(S("rapido")[1..5] == S("apid"));
}
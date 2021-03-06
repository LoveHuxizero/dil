/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity average)
module dil.String;

import common;

/// A string implementation that uses two pointers,
/// as opposed to one pointer and a size variable.
struct StringT(C)
{
  alias S = StringT; /// Shortcut to own type.
  /// Explicit constness for construction.
  alias CS = const S, IS = immutable S;
  alias inoutS = inout(S); /// Useful for explicit construction of inout Strings.
  C* ptr; /// Points to the beginning of the string.
  C* end; /// Points one past the end of the string.

  /// A dummy struct to simulate "tail const".
  ///
  /// When a local variable with the type inout(S) has to be defined,
  /// one cannot modify it or its members.
  /// This issue can be worked around with this struct.
  struct S2
  {
    const(C)* ptr;
    const(C)* end;
    void set(const(C)* p, const(C)* e)
    {
      ptr = p;
      end = e;
    }
    void set(const(S) s)
    {
      set(s.ptr, s.end);
    }
    void set(const(C)[] a)
    {
      set(a.ptr, a.ptr + a.length);
    }
    static S2 ctor(T)(T x)
    {
      S2 s = void;
      s.set(x);
      return s;
    }
  }


  /// Constructs from start and end pointers.
  this(inout C* p, inout C* e) inout
  {
    assert(p <= e);
    ptr = p;
    end = e;
  }

  /// Constructs from a start pointer and a length value.
  /// NB: use 'u' suffix on int literals, e.g.: this(str.ptr, 13u)
  this(inout C* p, const size_t length) inout
  {
    this(p, p + length);
  }

  /// Constructs from a character array.
  this(inout C[] str) inout
  {
    this(str.ptr, str.length);
  }

  /// Constructs from a character-terminated string.
  this(inout C* p, const C terminator) inout
  {
    inout(C)* q = p;
    while (*q != terminator)
      q++;
    this(p, q);
  }

  /// Constructs from Strings by joining them with joinStr.
  this(const S[] strs, const S joinStr)
  {
    this = joinStr.join(strs);
  }

  /// ditto
  this(const C[][] strs, const C[] joinStr)
  {
    this = CS(joinStr).join(strs);
  }

  /// Constructs from a single character.
  this(const C c)
  {
    this = CS(&c, 1u).dup;
  }

  /// Constructs from an unsigned long.
  /// NB: Not a regular constructor because "char" converts implicitly to ulong.
  static S itoa(ulong x)
  {
    C[20] buffer; // ulong.max -> "18446744073709551615".len == 20
    auto end = buffer.ptr + buffer.length;
    auto p = end;
    do
      *--p = '0' + x % 10;
    while (x /= 10);
    return S(p, end).dup;
  }

  /// Checks pointers.
  invariant()
  {
    assert(ptr ? ptr <= end : !end);
  }

  /// Converts t to S in case it's a different type than S.
  static auto toS(T)(T t)
  {
    static if (is(T : const(S)))
      return t;
    else static if (is(typeof(IS(t))))
      return IS(t);
    else static if (is(typeof(CS(t))))
      return CS(t);
    else static if (is(typeof(S(t))))
      return S(t);
    else
      static assert(0, "no StringT constructor for " ~ T.stringof);
  }

  /// Returns a character array.
  inout(C)[] opSlice() inout
  {
    return ptr[0..len];
  }

  /// Returns a pointer from an index number.
  /// When x is negative it is subtracted from the end pointer.
  inout(C)* indexPtr(T)(T x) inout
  {
    static if (is(T : Neg))
      auto p = end - x.n;
    else
      auto p = ptr + x;
    assert(ptr <= p && p <= end);
    return p;
  }

  /// Returns a slice.
  /// Params:
  ///   x = Start index. Negative values are subtracted from the end.
  ///   y = End index. Negative values are subtracted from the end.
  inout(S) opSlice(T1, T2)(T1 x, T2 y) inout
  {
    return inoutS(indexPtr!T1(x), indexPtr!T2(y));
  }

  /// Returns the character at position x.
  /// Params:
  ///   x = Character index. Negative values are subtracted from the end.
  inout(C) opIndex(T)(T x) inout
  {
    return *indexPtr!T(x);
  }

  /// Assigns c at position x.
  ref S opIndexAssign(T)(C c, T x)
  {
    *indexPtr!T(x) = c;
    return this;
  }

  /// Compares the bytes of two Strings for exact equality.
  bool opEquals(T)(T x) const
  {
    return this[] == toS!T(x)[];
  }

  /// Compares to a boolean value.
  bool opEquals(bool b) const
  {
    return cast(bool)this == b;
  }

  /// Compares the chars of two Strings.
  /// Returns: 0 if both are equal.
  int_t opCmp(const S s) const
  {
    auto n = (len <= s.len) ? len : s.len;
    const(C)* p = ptr, p2 = s.ptr;
    for (; n; n--, p++, p2++)
      if (int_t diff = *p - *p2)
        return diff;
    if (len != s.len)
      n = len - s.len;
    return n;
  }

  /// Compares two Strings ignoring case (only ASCII.)
  int_t icmp(T)(T x) const
  {
    auto s = toS!T(x);
    auto n = (len <= s.len) ? len : s.len;
    const(C)* p = ptr, p2 = s.ptr;
    for (; n; n--, p++, p2++)
      if (int_t diff = tolower(*p) - tolower(*p2))
        return diff;
    if (len != s.len)
      n = len - s.len;
    return n;
  }

  /// Compares two Strings ignoring case for equality (only ASCII.)
  bool ieql(T)(T x) const
  {
    return icmp(x) == 0;
  }

  /// Concatenates x copies of this string.
  S times(uint_t x) const
  {
    auto str = this[];
    auto slen = str.length;
    C[] result = new C[x * slen];
    auto p = result.ptr;
    for (; x--; p += slen)
      p[0..slen] = str;
    return S(result.ptr, p);
  }

  /// ditto
  S opBinary(string op : "*")(uint_t rhs) const
  {
    return times(rhs);
  }

  /// ditto
  S opBinaryRight(string op : "*")(uint_t lhs) const
  {
    return times(lhs);
  }

  /// Returns a list of Strings where each piece is of length n.
  /// The last piece may be shorter.
  inout(S)[] pieces(uint_t n) inout
  {
    if (n == 0)
      return null; // TODO: throw Exception?
    if (n >= len)
      return [this];

    const roundlen = (len + len % n) / n;
    S2[] result = new S2[roundlen];
    const(C)* p = ptr;
    auto elem = result.ptr;

    for (; p + n <= end; (p += n), elem++)
      elem.set(p, p + n);
    if (p < end)
      elem.set(p, end);

    return cast(inout(S)[])result;
  }

  /// Divides the String into num parts.
  /// The remainder is appended to the last piece.
  inout(S)[] divide(uint_t num) inout
  {
    if (num == 0)
      return null; // TODO: throw Exception?
    if (num == 1)
      return [this];

    const piecelen = len / num; // Length of one piece.
    S2[] result = new S2[num];
    const(C)* p = ptr;
    auto elem = result.ptr;

    for (; num--; (p += piecelen), elem++)
      elem.set(p, p + piecelen);
    if (p < end) // Update last element and include the rest of the String.
      (--elem).set(p-piecelen, end);

    return cast(inout(S)[])result;
  }

  /// ditto
  inout(S)[] opBinary(string op : "/")(uint_t rhs) inout
  {
    return divide(rhs);
  }

  /// Appends another string or character. Returns a new object.
  S opBinary(string op : "~", T)(T rhs) const
  {
    return S(cast(C[])(this[] ~ toS!T(rhs)[]));
  }

  /// Appends another string or character. Returns itself.
  ref S opOpAssign(string op : "~", T)(T rhs)
  {
    this = this ~ rhs;
    return this;
  }

  /// Returns a pointer to the first character, if this String is in rhs.
  inout(C)* opBinary(string op : "in")(inout C[] rhs) const
  {
    return inoutS(rhs).findp(this);
  }

  /// Returns a pointer to the first character, if lhs is in this String.
  inout(C)* opBinaryRight(string op : "in", T)(T lhs) inout
  {
    return findp(toS!T(lhs));
  }

  /// Converts to bool.
  bool opCast(T : bool)() const
  {
    return !isEmpty();
  }

  /// Converts to an array string.
  inout(C)[] opCast(T : inout C[])() inout
  {
    return ptr[0..len];
  }

  /// Returns the byte length.
  size_t len() const
  {
    return end - ptr;
  }

  /// Returns a copy.
  S dup() const
  {
    return S(ptr[0..len].dup);
  }

  /// Returns true if pointers are null.
  bool isNull() const
  {
    return ptr is null;
  }

  /// Returns true if the string is empty.
  bool isEmpty() const
  {
    return ptr is end;
  }

  /// ditto
  immutable(C)[] toString()
  {
    return this[].idup;
  }

  /// Return true if lower-case.
  static bool islower(const C c)
  {
    return 'a' <= c && c <= 'z';
  }

  /// Return true if upper-case.
  static bool isupper(const C c)
  {
    return 'A' <= c && c <= 'Z';
  }

  /// Returns the lower-case version of c.
  static inout(C) tolower(inout C c)
  {
    return isupper(c) ? cast(typeof(c))(c + 0x20) : c;
  }

  /// Returns the upper-case version of c.
  static inout(C) toupper(inout C c)
  {
    return islower(c) ? cast(typeof(c))(c - 0x20) : c;
  }

  /// Converts to lower-case (only ASCII.)
  ref S tolower()
  {
    auto p = ptr;
    for (; p < end; p++)
      *p = tolower(*p);
    return this;
  }

  /// ditto
  S tolower() const
  {
    return dup.tolower();
  }

  /// Converts to upper-case (only ASCII.)
  ref S toupper()
  {
    for (auto p = ptr; p < end; p++)
      *p = toupper(*p);
    return this;
  }

  /// ditto
  S toupper() const
  {
    return dup.toupper();
  }

  /// Encodes the byte characters with hexadecimal digits.
  S toHex(bool lowercase)() const
  {
    immutable hexdigits = lowercase ? "0123456789abcdef" : "0123456789ABCDEF";
    auto result = S(new C[len * C.sizeof * 2]); // Reserve space.
    auto pr = result.ptr;
    for (const(C)* p = ptr; p < end; p++)
      static if (C.sizeof == 4)
      {
        *pr++ = hexdigits[*p >> 28];
        *pr++ = hexdigits[*p >> 24 & 0x0F];
        *pr++ = hexdigits[*p >> 20 & 0x0F];
        *pr++ = hexdigits[*p >> 16 & 0x0F];
        *pr++ = hexdigits[*p >> 12 & 0x0F];
        *pr++ = hexdigits[*p >> 8 & 0x0F];
        *pr++ = hexdigits[*p >> 4 & 0x0F];
        *pr++ = hexdigits[*p & 0x0F];
      }
      else
      static if (C.sizeof == 2)
      {
        *pr++ = hexdigits[*p >> 12];
        *pr++ = hexdigits[*p >> 8 & 0x0F];
        *pr++ = hexdigits[*p >> 4 & 0x0F];
        *pr++ = hexdigits[*p & 0x0F];
      }
      else
      {
        *pr++ = hexdigits[*p >> 4];
        *pr++ = hexdigits[*p & 0x0F];
      }
    assert(pr is result.end);
    return result;
  }

  alias tohex = toHex!(true);
  alias toHEX = toHex!(false);

  /// Calculates a hash value.
  /// Note: The value will differ between 32bit and 64bit systems,
  /// and also between little and big endian systems.
  hash_t hashOf() const
  {
    hash_t hash;
    const(C)* sptr = ptr;
    auto slen = len;

    auto rem_len = slen % hash_t.sizeof; // Remainder.
    auto hptr = cast(const(hash_t)*)sptr;
    if (slen == rem_len)
      goto Lonly_remainder;

    {
      // Divide the length by 4 or 8 (x86 vs. x86_64).
      auto hlen = slen / hash_t.sizeof;
      assert(hlen, "can't be zero");

      while (hlen--) // Main loop.
        hash = hash * 11 + *hptr++;
    }

    if (rem_len)
    { // Calculate the hash of the remaining characters.
      sptr = cast(typeof(sptr))hptr; // hptr points exactly to the remainder.
    Lonly_remainder:
      hash_t chunk;
      while (rem_len--) // Remainder loop.
        chunk = (chunk << 8) | *sptr++;
      hash = hash * 11 + chunk;
    }

    return hash;
  }

  /// Returns true if this String starts with prefix.
  bool startsWith(const S prefix) const
  {
    return prefix.len <= len && CS(ptr, prefix.len) == prefix;
  }

  /// ditto
  bool startsWith(const C[] prefix) const
  {
    return startsWith(CS(prefix));
  }

  /// Returns true if this String starts with one of the specified prefixes.
  bool startsWith(const S[] prefixes) const
  {
    foreach (prefix; prefixes)
      if (startsWith(prefix))
        return true;
    return false;
  }

  /// ditto
  bool startsWith(const C[][] prefixes) const
  {
    foreach (prefix; prefixes)
      if (startsWith(CS(prefix)))
        return true;
    return false;
  }

  /// Returns true if this String ends with suffix.
  bool endsWith(const S suffix) const
  {
    return suffix.len <= len && CS(end - suffix.len, end) == suffix;
  }

  /// ditto
  bool endsWith(const C[] suffix) const
  {
    return endsWith(CS(suffix));
  }

  /// Returns true if this String ends with one of the specified suffixes.
  bool endsWith(const S[] suffixes) const
  {
    foreach (suffix; suffixes)
      if (endsWith(suffix))
        return true;
    return false;
  }

  /// ditto
  bool endsWith(const C[][] suffixes) const
  {
    foreach (suffix; suffixes)
      if (endsWith(CS(suffix)))
        return true;
    return false;
  }

  /// Returns true if this string is a slice of s.
  bool slices(const S s) const
  {
    return s.ptr <= ptr && end <= s.end;
  }

  /// ditto
  bool slices(const C[] s) const
  {
    return slices(CS(s));
  }

  /// Returns 'a' if RT is of type size_t, otherwise 'b'.
  static auto choice(RT, A, B)(A a, B b)
  {
    static if (is(RT == size_t))
      return a;
    else
      return b;
  }

  /// Searches for character c.
  RT findC(RT, string pred = q{*p == c})(const C c) inout
  {
    inout(C)* p = ptr;
    for (; p < end; p++)
      if (mixin(pred))
        return choice!RT(p - ptr, p);
    return choice!RT(-1, null);
  }

  /// Searches for character c starting from the end.
  RT findrC(RT, string pred = q{*p == c})(const C c) inout
  {
    inout(C)* p = end;
    while (--p >= ptr)
      if (mixin(pred))
        return choice!RT(p - ptr, p);
    return choice!RT(-1, null);
  }

  /// Searches for s.
  RT findS(RT)(const S s) inout
  {
    if (s.len == 0)
      return choice!RT(0, ptr);
    else
    if (s.len == 1)
      return choice!RT(find(s[0]), findp(s[0]));
    else
    if (s.len <= len) // Return when the argument string is longer.
    {
      inout(C)* p = ptr;
      const firstChar = *s.ptr;

      for (; p < end; p++)
        if (*p == firstChar) // Find first matching character.
        {
          const(C)* p2 = s.ptr;
          inout(C)* matchBegin = p;
          while (p < end && *p++ == *p2++)
            if (p2 is s.end) // If at the end, we have a match.
              return choice!RT(matchBegin - ptr, matchBegin);
        }
    }
    return choice!RT(-1, null);
  }

  /// Searches for s starting from the end.
  RT findrS(RT)(const S s) inout
  {
    if (s.len == 0)
      return choice!RT(len, end);
    else
    if (s.len == 1)
      return choice!RT(findr(s[0]), findrp(s[0]));
    else
    if (s.len <= len) // Return when the argument string is longer.
    {
      inout(C)* p = end;
      const lastChar = *(s.end - 1);

      while (--p >= ptr)
        if (*p == lastChar) // Find first matching character.
        {
          const(C)* p2 = s.end - 1;
          while (--p >= ptr)
            if (*p != *--p2)
              break;
            else if (p2 is s.ptr) // If at the start, we have a match.
              return choice!RT(p - ptr, p);
        }
    }
    return choice!RT(-1, null);
  }

  /// Searches for character c.
  alias find = findC!(size_t);
  /// Searches for character c.
  /// Returns: A pointer to c, or null if not found.
  alias findp = findC!(inout(C)*);
  /// Searches for character c starting from the end.
  alias findr = findrC!(size_t);
  /// Searches for character c, returning a pointer.
  alias findrp = findrC!(inout(C)*);
  /// Searches for s.
  /// Returns: The position index, or -1 if not found.
  alias find = findS!(size_t);
  /// Searches for s.
  /// Returns: A pointer to the beginning of s, or null if not found.
  alias findp = findS!(inout(C)*);
  /// Searches for s starting from the end, returning the index.
  alias findr = findrS!(size_t);
  /// Searches for s starting from the end, returning a pointer.
  alias findrp = findrS!(inout(C)*);

  /// Splits by String s and returns a list of slices.
  inout(S)[] split(T)(T x) inout
  {
    auto s = toS!T(x);
    S2[] result;
    const(C)* p = ptr, prev = p;
    auto slen = s.len;
    if (slen == 0)
    {
      result = new S2[len + 2]; // +2 for first and last empty elements.
      auto elem = result.ptr;

      for (; p <= end; p++, elem++)
      {
        elem.set(prev, p);
        prev = p;
      }
      elem.set(p, p);
    }
    else
    if (slen == 1)
      return split(*s.ptr);
    else
    {
      const(C)* ps;
      while ((ps = CS(p, end).findp(s)) !is null)
      {
        result ~= S2(p, ps);
        p = ps + slen;
        assert(p <= end);
      }
      result ~= S2(p, end);
    }
    return cast(inout(S)[])result;
  }

  /// ditto
  inout(S)[] split(T : C)(T c) inout
  {
    S2[] result;
    const(C)* p = ptr, prev = p;
    for (; p < end; p++)
      if (*p == c)
      {
        result ~= S2(prev, p);
        prev = p+1;
      }
    result ~= S2(prev, end);
    return cast(inout(S)[])result;
  }

  /// Substitutes a with b.
  ref S sub_(const C a, const C b)
  {
    auto p = ptr;
    for (; p < end; p++)
      if (*p == a)
        *p = b;
    return this;
  }

  /// ditto
  ref S sub_(const S a, const S b)
  {
    auto alen = a.len, blen = b.len;

    if (alen == 0 && blen == 0)
    {}
    else
    if (alen == 0)
    {
      C[] result;
      const bstr = b[];
      const(C)* p = ptr;

      while (p < end)
        result ~= bstr ~ *p++;
      result ~= bstr;
      this = S(result);
    }
    else
    if (alen == 1 && blen == 1)
      sub_(a[0], b[0]);
    else
    if (blen == 0)
    {
      C* pwriter = ptr;
      const(C)* preader = pwriter, pa;

      while ((pa = CS(preader, end).findp(a)) !is null)
      {
        while (preader < pa) // Copy till beginning of a.
          *pwriter++ = *preader++;
        preader += alen; // Skip a.
      }
      if (preader !is pwriter)
      { // Write the rest.
        while (preader < end)
          *pwriter++ = *preader++;
        end = pwriter;
      }
    }
    else
    {
      const(C)* pa = findp(a);
      if (pa)
      {
        C[] result;
        const bstr = b[];
        const(C)* p = ptr;

        do
        {
          if (pa) // Append previous string?
            result ~= CS(p, pa)[];
          result ~= bstr;
          p = pa + alen; // Skip a.
        } while ((pa = CS(p, end).findp(a)) !is null);
        if (p < end)
          result ~= CS(p, end)[];
        this = S(result);
      }
    }
    return this;
  }

  /// ditto
  ref S sub(A, B)(A a, B b)
  {
    static if (is(typeof(sub_(a, b))))
      return sub_(a, b);
    else
      return sub_(toS!A(a), toS!B(b));
  }

  /// ditto
  S sub(A, B)(A a, B b) const
  {
    return dup.sub_(toS!A(a), toS!B(b));
  }

  /// Searches for sep and returns the part before and after that.
  inout(S)[2] partition(T)(T sep) inout
  {
    static if (is(sep : C))
    {
      if (auto psep = findp(sep))
        return [inoutS(ptr, psep), inoutS(psep + 1, end)];
    }
    else
    {
      auto sep_ = toS!T(sep);
      if (auto psep = findp(sep_))
        return [inoutS(ptr, psep), inoutS(psep + sep_.len, end)];
    }
    return [this, inoutS()];
  }

  /// Searches for sep and returns the part before and after that.
  inout(S)[2] rpartition(T)(T sep) inout
  {
    static if (is(sep : C))
    {
      if (auto psep = findrp(sep))
        return [inoutS(ptr, psep), inoutS(psep + 1, end)];
    }
    else
    {
      auto sep_ = toS!T(sep);
      if (auto psep = findrp(sep_))
        return [inoutS(ptr, psep), inoutS(psep + sep_.len, end)];
    }
    return [inoutS(), this];
  }

  /// Concatenates strs using this String as a separator.
  S join(const S[] strs) const
  {
    C[] result;
    if (strs.length)
    {
      const sep = this[];
      result = strs[0][].dup;
      foreach (str; strs[1..$])
        result ~= sep ~ str[];
    }
    return S(result);
  }

  /// ditto
  S join(const C[][] strs) const
  {
    C[] result;
    if (strs.length)
    {
      const sep = this[];
      result = strs[0].dup;
      foreach (str; strs[1..$])
        result ~= sep ~ str;
    }
    return S(result);
  }

  /// Like join, but also appends the separator.
  S rjoin(const S[] strs) const
  {
     C[] result;
     const sep = this[];
     foreach (str; strs)
       (result ~= str[]) ~= sep;
     return S(result);
  }

  /// ditto
  S rjoin(const C[][] strs) const
  {
    return rjoin(strs.toStrings());
  }

  /// Like join, but also prepends the separator.
  S ljoin(const S[] strs) const
  {
     C[] result;
     const sep = this[];
     foreach (str; strs)
       (result ~= sep) ~= str[];
     return S(result);
  }

  /// ditto
  S ljoin(const C[][] strs) const
  {
    return ljoin(strs.toStrings());
  }

  /// Returns itself reversed.
  ref S reverse()
  {
    auto lft = ptr;
    auto rgt = end - 1;
    for (auto n = len / 2; n != 0; n--, lft++, rgt--)
    { // Swap left and right characters.
      const c = *lft;
      *lft = *rgt;
      *rgt = c;
    }
    return this;
  }

  /// Returns a reversed String.
  S reverse() const
  {
    return dup.reverse();
  }
}

alias MString = StringT!(char);    /// Mutable instantiation for char.
alias String  = const MString;     /// Alias for const.
alias IString = immutable MString; /// Alias for immutable.
alias WString = StringT!(wchar); /// Instantiation for wchar.
alias DString = StringT!(dchar); /// Instantiation for dchar.

/// Returns a string array slice ranging from begin to end.
inout(char)[] slice(inout(char)* begin, inout(char)* end)
{
  return String.inoutS(begin, end)[];
}

/// Returns a copy of str where a is replaced with b.
cstring replace(cstring str, char a, char b)
{
  return String(str).sub(a, b)[];
}

/// Converts x to a string array.
char[] itoa(ulong x)
{
  if (__ctfe)
  {
    auto buffer = new char[20]; // ulong.max -> "18446744073709551615".len == 20
    auto i = buffer.length;
    do
      buffer[--i] = '0' + x % 10;
    while (x /= 10);
    return buffer[i .. $];
  }
  else
    return String.itoa(x)[];
}

/// Returns a list of Strings from a list of char arrays.
inout(StringT!C)[] toStrings(C)(inout C[][] strs)
{
   auto result = new StringT!C.S2[strs.length];
   auto elem = result.ptr - 1;
   foreach (i, s; strs)
     (++elem).set(s);
   return cast(inout(StringT!C)[])result;
}

/// Calculates a hash value for str.
/// Note: The value will differ between 32bit and 64bit systems.
/// It will also differ between little and big endian systems.
hash_t hashOf(cstring str)
{
  return String(str).hashOf();
}

/// ditto
hash_t hashOfCTF(cstring str)
{
  hash_t hash;

  // Can't reinterpret cast inside CTFs. See: $(DMDBUG 5497)
  auto count = str.length / hash_t.sizeof;
  size_t i; // Index into str.
  while (count--) // Main loop.
  {
    hash_t hc; auto t = hash_t.sizeof; // Convert t nr of bytes from str.
    while (t--)
      version(BigEndian)
        hc = (hc << 8) | str[i++]; // Add c as LSByte.
      else // Add c as MSByte.
        hc = (hc >> 8) | (str[i++] << (hash_t.sizeof-1)*8);
    hash = hash * 11 + hc;
  }

  if (auto t = str.length - i)
  { // Add remainder hash.
    hash_t hc;
    while (t--) // Remainder loop.
      hc = (hc << 8) | str[i++];
    hash = hash * 11 + hc;
  }
  return hash;
}

void testString()
{
  scope msg = new UnittestMsg("Testing struct String.");
  alias S = String;

  // Constructing.
  assert(S("") == "");
  assert(S("a"[0]) == "a");
  assert(S(['a'][0]) == "a");
  assert(S("".ptr, '\0') == ""); // String literals are always zero terminated.
  assert(S("abcd".ptr, '\0') == S("abcd"));
  assert(S("abcd".ptr, 'c') == S("ab"));
  assert(S("abcd".ptr, 2u) == S("ab"));
  assert(S.itoa(0) == S("0") && S.itoa(1999) == S("1999"));

  // Boolean conversion.
  if (S("is cool")) {}
  else assert(0);
  assert(S() == false && !S());
  assert(S("") == false && !S(""));
  assert(S("verdad") == true);

  // Concatenation.
  {
  auto s = MString("x".dup);
  ((s ~= S()) ~= 'y') ~= "z";
  assert(s == S("x") ~ S("yz"));
  assert(S() ~ S() == S());
  }

  // Substitution.
  assert(S("abce").sub('e', 'd') == "abcd");
  assert(S("abc ef").sub(' ', 'd') == "abcdef");
  assert(S("abc f").sub(' ', "de") == "abcdef");
  assert(S("abcd").sub("", " ") == " a b c d ");
  assert(S("").sub("", "a") == "a");
  assert(S(" a b c d ").sub(" ", "") == "abcd");
  assert(S("ab_cd").sub("_", "") == "abcd");
  assert(S("abcd").sub("abcd", "") == "");
  assert(S("aaaa").sub("a", "") == "");
  assert(S("").sub(S(""), "") == "");
  assert(S("").sub("", S("")) == "");
  assert(S("").sub(S(""), S("")) == "");

  // Duplication.
  assert(S("chica").dup == S("chica"));

  // Comparison.
  assert(S("a") < S("b"));
  assert(S("b") > S("a"));
  assert(S("a") > S("B"));
  assert(S("B") < S("a"));
  assert(S("a") <= S("a"));
  assert(S("b") >= S("b"));
  assert(S("a") == S("a"));
  assert(S("a") != S("b"));
  assert(S("abcd") == S("abcd"));
  assert(S("") == S());
  assert(S() == "");
  assert(S() == S("") && "" == null);
  assert(S("ABC").ieql("abc"));
  assert(S("XYZ").ieql(S("xyz")));
  assert(S("a").icmp("B") < 0);
  assert(S("x").icmp(S("Y")) < 0);
  assert(S("B").icmp("a") > 0);
  assert(S("Y").icmp(S("x")) > 0);

  // Slicing.
  assert(S("rapido")[] == "rapido");
  assert(S("rapido")[0..0] == "");
  assert(S("rapido")[1..4] == "api");
  assert(S("rapido")[2..Neg(3)] == "p");
  assert(S("rapido")[Neg(3)..3] == "");
  assert(S("rapido")[Neg(4)..Neg(1)] == "pid");
  assert(S("rapido")[6..6] == "");

  {
    auto s = S("rebanada");
    assert(s.slices(s));
    assert(s[0..0].slices(s));
    assert(s[1..Neg(1)].slices(s));
    assert(s[s.len..s.len].slices(s));
    assert(S(s.end, s.end).slices(s));
  }

  // Indexing.
  assert(S("abcd")[0] == 'a');
  assert(S("abcd")[2] == 'c');
  assert(S("abcd")[Neg(1)] == 'd');

  // Multiplying.
  assert(S("ha") * 6 == "hahahahahaha");
  assert(S("oi") * 3 == "oioioi");
  assert(S("palabra") * 0 == "");
  assert(1 * S("mundo") == "mundo");
  assert(S("") * 4 == "");

  // Dividing.
  assert(S("abcd") / 1 == [S("abcd")]);
  assert(S("abcd") / 2 == [S("ab"), S("cd")]);
  assert(S("abcd") / 3 == [S("a"), S("b"), S("cd")]);
  assert(S("abcdefghi") / 2 == [S("abcd"), S("efghi")]);
  assert(S("abcdefghijk") / 4 == [S("ab"), S("cd"), S("ef"), S("ghijk")]);

  assert(S("abcdef").pieces(2) == [S("ab"), S("cd"), S("ef")]);
  assert(S("abcdef").pieces(4) == [S("abcd"), S("ef")]);

  // Splitting.
  assert(S("").split("") == [S(""), S("")]);
  assert(S("abc").split("") == [S(""), S("a"), S("b"), S("c"), S("")]);
  assert(S("abc").split("b") == [S("a"), S("c")]);
  assert(S("abc").split('b') == [S("a"), S("c")]);

  // Searching.
  assert("Mundo" in S("¡Hola Mundo!"));
  assert(S("") in "a");
  assert(S("abcd").find(S("cd")) == 2);
  assert(S("").find(S("")) == 0);
  assert(S("abcd").findr('d') == 3);
  assert(S("abcd").findr('a') == 0);
  assert(S("abcd").findr('e') == -1);
  {
  auto s = S("abcd");
  assert(s.findp(S("abcd")) is s.ptr);
  assert(s.findp(S("d")) is s.end - 1);
  assert(s.findrp(S("ab")) is s.ptr);
  assert(s.findrp(S("cd")) is s.end - 2);
  assert(s.findrp(S("")) is s.end);
  }
  assert(S("abcd").findr(S("ab")) == 0);
  assert(S("abcd").findr(S("cd")) == 2);

  // Reversing.
  assert(S().reverse() == "");
  assert(S("").reverse() == "");
  assert(S("a").reverse() == "a");
  assert(S("abc").reverse() == "cba");
  assert(S("abcd").reverse() == "dcba");
  assert(S("abc").reverse().reverse() == "abc");

  // Matching prefixes and suffixes.
  assert(S("abcdefg").startsWith("abc"));
  assert(S("abcdefg").startsWith([" ", "abc"]));
  assert(!S("ab").startsWith("abc"));
  assert(S("abcdefg").endsWith("efg"));
  assert(S("abcdefg").endsWith([" ", "efg"]));
  assert(!S("fg").endsWith("efg"));

  // Partitioning.
  assert(S("").partition("") == [S(), S()]);
  assert(S("ab.cd").partition(".") == [S("ab"), S("cd")]);
  assert(S("ab.cd").partition('.') == [S("ab"), S("cd")]);
  assert(S("abcd").partition(".") == [S("abcd"), S("")]);
  assert(S("abcd.").partition(".") == [S("abcd"), S("")]);
  assert(S(".abcd").partition(".") == [S(""), S("abcd")]);
  assert(S("abcd").partition("") == [S(""), S("abcd")]);

  assert(S("").rpartition("") == [S(), S()]);
  assert(S("ab.cd").rpartition(".") == [S("ab"), S("cd")]);
  assert(S("ab.cd").rpartition('.') == [S("ab"), S("cd")]);
  assert(S("abcd").rpartition(".") == [S(""), S("abcd")]);
  assert(S("abcd.").rpartition(".") == [S("abcd"), S("")]);
  assert(S(".abcd").rpartition(".") == [S(""), S("abcd")]);
  assert(S("abcd").rpartition("") == [S("abcd"), S("")]);

  // Converting to hex string.
  assert(S("äöü").tohex() == "c3a4c3b6c3bc");
  assert(S("äöü").toHEX() == "C3A4C3B6C3BC");

  // Case conversion.
  assert(S("^agmtz$").toupper() == "^AGMTZ$");
  assert(S("^AGMTZ$").tolower() == "^agmtz$");

  // Joining.
  {
  string[] strs;
  assert(S(strs=["a","b","c","d"], ".") == "a.b.c.d");
  assert(S(strs, "") == "abcd");
  assert(S(strs=["a"], ".") == "a");
  assert(S(",").rjoin(strs) == "a,");
  assert(S(",").ljoin(strs) == ",a");
  assert(S(",").rjoin(strs=["a", "b"]) == "a,b,");
  assert(S(",").ljoin(strs) == ",a,b");
  assert(S(",").rjoin(strs=null) == "");
  assert(S(",").ljoin(strs) == "");
  }
}

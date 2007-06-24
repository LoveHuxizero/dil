/++
  Author: Aziz Köksal
  License: GPL2
+/
module Token;

struct Position
{
  size_t loc;
  size_t col;
}

enum TOK
{
  Identifier,
  Comment,
  String,
  Character,
  DivisionAssign,
  Number,
/* Braces */
  LParen,
  RParen,
  LBracket,
  RBracket,
  LBrace,
  RBrace,

  Dot, Slice, Ellipses,

  Assign, Equal,
  OrAssign, OrLogical, OrBinary,
  AndAssign, AndLogical, AndBinary,
  PlusAssign, PlusPlus, Plus,
  MinusAssign, MinusMinus, Minus,
  CatAssign, Catenate,

  Tilde,
  Colon,
  Semicolon,
  Question,
  Comma,
  Dollar,

  /* Keywords:
     NB.: Token.isKeyword() depends on this list being contiguous.
  */
  Abstract,Alias,Align,Asm,Assert,Auto,Body,
  Bool,Break,Byte,Case,Cast,Catch,Cdouble,
  Cent,Cfloat,Char,Class,Const,Continue,Creal,
  Dchar,Debug,Default,Delegate,Delete,Deprecated,Do,
  Double,Else,Enum,Export,Extern,False,Final,
  Finally,Float,For,Foreach,Foreach_reverse,Function,Goto,
  Idouble,If,Ifloat,Import,In,Inout,Int,
  Interface,Invariant,Ireal,Is,Lazy,Long,Macro,
  Mixin,Module,New,Null,Out,Override,Package,
  Pragma,Private,Protected,Public,Real,Ref,Return,
  Scope,Short,Static,Struct,Super,Switch,Synchronized,
  Template,This,Throw,True,Try,Typedef,Typeid,
  Typeof,Ubyte,Ucent,Uint,Ulong,Union,Unittest,
  Ushort,Version,Void,Volatile,Wchar,While,With,

  EOF
}

alias TOK.Abstract KeywordsBegin;
alias TOK.With KeywordsEnd;

struct Token
{
  TOK type;
  Position pos;

  char* start;
  char* end;

  union
  {
    char[] str;
    dchar chr;
    float f;
    double d;
  }

  string span()
  {
    return start[0 .. end - start];
  }

  bool isKeyword()
  {
    if (KeywordsBegin <= type && type <= KeywordsEnd)
      return true;
    return false;
  }
}
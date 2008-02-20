/++
  Author: Aziz Köksal
  License: GPL3
+/
module dil.lexer.Keywords;

import dil.lexer.Token;
import dil.lexer.Identifier;

/// Table of reserved identifiers.
static const Identifier[] keywords = [
  {"abstract", TOK.Abstract},
  {"alias", TOK.Alias},
  {"align", TOK.Align},
  {"asm", TOK.Asm},
  {"assert", TOK.Assert},
  {"auto", TOK.Auto},
  {"body", TOK.Body},
  {"bool", TOK.Bool},
  {"break", TOK.Break},
  {"byte", TOK.Byte},
  {"case", TOK.Case},
  {"cast", TOK.Cast},
  {"catch", TOK.Catch},
  {"cdouble", TOK.Cdouble},
  {"cent", TOK.Cent},
  {"cfloat", TOK.Cfloat},
  {"char", TOK.Char},
  {"class", TOK.Class},
  {"const", TOK.Const},
  {"continue", TOK.Continue},
  {"creal", TOK.Creal},
  {"dchar", TOK.Dchar},
  {"debug", TOK.Debug},
  {"default", TOK.Default},
  {"delegate", TOK.Delegate},
  {"delete", TOK.Delete},
  {"deprecated", TOK.Deprecated},
  {"do", TOK.Do},
  {"double", TOK.Double},
  {"else", TOK.Else},
  {"enum", TOK.Enum},
  {"export", TOK.Export},
  {"extern", TOK.Extern},
  {"false", TOK.False},
  {"final", TOK.Final},
  {"finally", TOK.Finally},
  {"float", TOK.Float},
  {"for", TOK.For},
  {"foreach", TOK.Foreach},
  {"foreach_reverse", TOK.Foreach_reverse},
  {"function", TOK.Function},
  {"goto", TOK.Goto},
  {"idouble", TOK.Idouble},
  {"if", TOK.If},
  {"ifloat", TOK.Ifloat},
  {"import", TOK.Import},
  {"in", TOK.In},
  {"inout", TOK.Inout},
  {"int", TOK.Int},
  {"interface", TOK.Interface},
  {"invariant", TOK.Invariant},
  {"ireal", TOK.Ireal},
  {"is", TOK.Is},
  {"lazy", TOK.Lazy},
  {"long", TOK.Long},
  {"macro", TOK.Macro}, // D2.0
  {"mixin", TOK.Mixin},
  {"module", TOK.Module},
  {"new", TOK.New},
  {"nothrow", TOK.Nothrow}, // D2.0
  {"null", TOK.Null},
  {"out", TOK.Out},
  {"override", TOK.Override},
  {"package", TOK.Package},
  {"pragma", TOK.Pragma},
  {"private", TOK.Private},
  {"protected", TOK.Protected},
  {"public", TOK.Public},
  {"pure", TOK.Pure}, // D2.0
  {"real", TOK.Real},
  {"ref", TOK.Ref},
  {"return", TOK.Return},
  {"scope", TOK.Scope},
  {"short", TOK.Short},
  {"static", TOK.Static},
  {"struct", TOK.Struct},
  {"super", TOK.Super},
  {"switch", TOK.Switch},
  {"synchronized", TOK.Synchronized},
  {"template", TOK.Template},
  {"this", TOK.This},
  {"throw", TOK.Throw},
  {"__traits", TOK.Traits}, // D2.0
  {"true", TOK.True},
  {"try", TOK.Try},
  {"typedef", TOK.Typedef},
  {"typeid", TOK.Typeid},
  {"typeof", TOK.Typeof},
  {"ubyte", TOK.Ubyte},
  {"ucent", TOK.Ucent},
  {"uint", TOK.Uint},
  {"ulong", TOK.Ulong},
  {"union", TOK.Union},
  {"unittest", TOK.Unittest},
  {"ushort", TOK.Ushort},
  {"version", TOK.Version},
  {"void", TOK.Void},
  {"volatile", TOK.Volatile},
  {"wchar", TOK.Wchar},
  {"while", TOK.While},
  {"with", TOK.With},
  // Special tokens:
  {"__FILE__", TOK.FILE},
  {"__LINE__", TOK.LINE},
  {"__DATE__", TOK.DATE},
  {"__TIME__", TOK.TIME},
  {"__TIMESTAMP__", TOK.TIMESTAMP},
  {"__VENDOR__", TOK.VENDOR},
  {"__VERSION__", TOK.VERSION},
  {"__EOF__", TOK.EOF}, // D2.0
];

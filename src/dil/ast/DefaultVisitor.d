/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity very high)
module dil.ast.DefaultVisitor;

import dil.ast.Visitor,
       dil.ast.Node,
       dil.ast.Declarations,
       dil.ast.Expressions,
       dil.ast.Statements,
       dil.ast.Types,
       dil.ast.Parameters;
import common;

/// Provides a visit() method which calls Visitor.visitN() on subnodes.
mixin template visitDefault(N, Ret = returnType!(N))
{
  override Ret visit(N n)
  {
    foreach (i, T; N.CTTI_Types)
    {
      auto member = __traits(getMember, n, N.CTTI_Members[i]);
      static if (is(T : Node)) // A Node?
      {
        if (!N.CTTI_MayBeNull[i] || member !is null)
          visitN(member);
      }
      else
      static if (is(T : E[], E : Node)) // A Node array?
      {
        foreach (x; member)
          if (!N.CTTI_MayBeNull[i] || x !is null)
            visitN(x);
      }
    }
    static if (!is(Ret : void))
      return n;
  }
}

/// Generates the default visit methods.
///
/// E.g.:
/// ---
/// mixin visitDefault!(ClassDecl);
/// mixin visitDefault!(InterfaceDecl);
/// ---
char[] generateDefaultVisitMethods()
{
  char[] code;
  foreach (className; NodeClassNames)
    code ~= "mixin visitDefault!(" ~ className ~ ");\n";
  return code;
}
//pragma(msg, generateDefaultVisitMethods());

/// Same as above but returns void.
char[] generateDefaultVisitMethods2()
{
  char[] code;
  foreach (className; NodeClassNames)
    code ~= "mixin visitDefault!(" ~ className ~ ", void);\n";
  return code;
}


/// This class provides default methods for
/// traversing nodes and their subnodes.
class DefaultVisitor : Visitor
{
  // Comment out if too many errors are shown.
  mixin(generateDefaultVisitMethods());
}

/// This class provides default methods for
/// traversing nodes and their subnodes.
class DefaultVisitor2 : Visitor2
{
  // Comment out if too many errors are shown.
  mixin(generateDefaultVisitMethods2());
}

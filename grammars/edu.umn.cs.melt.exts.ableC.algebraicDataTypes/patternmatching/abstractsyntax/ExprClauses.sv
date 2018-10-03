grammar edu:umn:cs:melt:exts:ableC:algebraicDataTypes:patternmatching:abstractsyntax;

-- Clauses --
-------------

{-  A sequence of Expr Clauses

     p1 -> e1 
     p2 -> e2
     ...
     pn -> en

    becomes

     {(
       type-of-scrutinee  _result; 
       if ( ... p1 matches ... ) {    
         _result = e1;
       } else if ( ... p2 matches ... ) {
         _result = e2;
       } else ... if ( ... pn matches ... ) {
         _result = en;
       }
       _result;
     })

    Thus, the translation of later clauses are children of the
    translation of earlier clauses.  To achieve this, a pair of
    (backward) threaded attribute, transform and tranformIn, are used.
 -}

{-  Patterns are checked against an expected type, which is initially
    the type of the scrutinee.  The following inherited attribute are
    used to pass these types down the clause and pattern ASTs.
 -}

nonterminal ExprClauses with location, pp, errors, env, expectedType, transform<Stmt>, returnType, typerep;

abstract production consExprClause
top::ExprClauses ::= c::ExprClause rest::ExprClauses
{ 
  top.pp = cat( c.pp, rest.pp );

  c.expectedType = top.expectedType;
  rest.expectedType = top.expectedType;

  top.errors := c.errors ++ rest.errors;
  top.errors <-
    if typeAssignableTo(c.typerep, rest.typerep)
    then []
    else [err(c.location,
              s"Incompatible types in rhs of pattern, expected ${showType(rest.typerep)} but found ${showType(c.typerep)}")];

  top.transform = c.transform;
  c.transformIn = rest.transform;

  top.typerep =
    if typeAssignableTo(c.typerep, rest.typerep)
    then c.typerep
    else errorType();
}

abstract production oneExprClause
top::ExprClauses ::= c::ExprClause
{
  top.pp = c.pp;
  c.expectedType = top.expectedType;
  top.errors := c.errors;
  top.errors <-
    if null(lookupValue("exit", top.env))
    then [err(builtin, "Pattern match requires definition of exit (include <stdlib.h>?)")]
    else [];
  top.errors <-
    if null(lookupValue("fprintf", top.env))
    then [err(builtin, "Pattern match requires definition of fprintf (include <stdio.h>?)")]
    else [];
  top.errors <-
    if null(lookupValue("stderr", top.env))
    then [err(builtin, "Pattern match requires definition of stderr (include <stdio.h>?)")]
    else [];

  top.transform = c.transform;
  c.transformIn =
    ableC_Stmt {
      fprintf(stderr, $stringLiteralExpr{s"Pattern match failure at ${c.location.unparse}"});
      exit(1);
    };
  top.typerep = c.typerep;
}

nonterminal ExprClause with location, pp, errors, env, returnType, expectedType, transform<Stmt>, transformIn<Stmt>, typerep;

abstract production exprClause
top::ExprClause ::= p::Pattern e::Expr
{
  top.pp = ppConcat([ p.pp, text("->"), space(), nestlines(2, e.pp), text(";")]);
  top.errors := p.errors ++ e.errors;

  e.env = addEnv(p.defs,top.env);
  p.expectedType = top.expectedType;

  top.typerep = e.typerep;

  top.transform =
    ableC_Stmt {
      $Stmt{foldStmt(p.decls)}
      if ($Expr{p.transform}) {
        _result = $Expr{e};
      } else {
        $Stmt{top.transformIn}
      }
    };
  p.transformIn = ableC_Expr { _match_scrutinee_val };
}

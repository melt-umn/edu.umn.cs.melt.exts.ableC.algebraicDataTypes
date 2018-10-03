grammar edu:umn:cs:melt:exts:ableC:algebraicDataTypes:patternmatching:abstractsyntax;

-- ADT Patterns --
-------------------

abstract production constructorPattern
top::Pattern ::= id::String ps::PatternList
{
  top.pp = cat( text(id), parens( ppImplode(text(","), ps.pps) ) );
  ps.env = top.env;
  top.decls = ps.decls;
  top.defs := ps.defs;
  
  -- Type checking
  top.errors :=
    case top.expectedType, adtLookup, constructorParamLookup of
    -- Check that expected type for this pattern is an ADT type of some sort.
    | errorType(), _, _ -> []
    | extType(_, _), [], _ -> [err(top.location, s"${showType(top.expectedType)} does not have a definiton.")]
    | _, [], _ -> [err(top.location, s"${showType(top.expectedType)} is not a datatype.")]
    | _, item :: _, _ ->
      if !item.adtName.isJust
      then [err(top.location, s"${showType(top.expectedType)} is not a datatype.")]
      else []
    -- Check that this pattern is a constructor for the expected ADT type.
    | _, _, just(paramTypes) ->
      -- Check that the number of patterns matches number of arguments for this constructor.
      if ps.len != length(paramTypes)
      then [err(top.location, s"This pattern has ${toString(ps.len)} arguments, but ${toString(length(paramTypes))} were expected.")]
      else []
    | _, _, nothing() -> [err(top.location, s"${showType(top.expectedType)} does not have constructor ${id}.")]
    end;
  
  local adtLookup::[RefIdItem] =
    case top.expectedType of
    | extType( _, e) ->
      case e.maybeRefId of
      | just(rid) -> lookupRefId(rid, top.env)
      | nothing() -> []
      end
    | _ -> []
    end;
  
  local adtName::String =
    case adtLookup of
    | item :: _ -> item.adtName.fromJust
    | _ -> error("adtName demanded when lookup failed")
    end;
  
  local constructors::[Pair<String [Type]>] =
    case adtLookup of
    | item :: _ -> item.constructors
    | [] -> []
    end;
  
  local constructorParamLookup::Maybe<[Type]> = lookupBy(stringEq, id, constructors);
  ps.expectedTypes = fromMaybe([], constructorParamLookup);
  
  -- adtName ++ "_" ++ id is the tag name to match against
  top.transform =
    ableC_Expr {
      $Expr{top.transformIn}.tag == $name{adtName ++ "_" ++ id} && $Expr{ps.transform}
    };
  ps.transformIn = ableC_Expr { $Expr{top.transformIn}.contents.$name{id} };
  ps.position = 0;
}

-- PatternList --
-----------------
nonterminal PatternList with location, pps, errors, env, returnType, defs, decls, expectedTypes, len, position, transform<Expr>, transformIn<Expr>;

abstract production consPattern
top::PatternList ::= p::Pattern rest::PatternList
{
  top.pps = p.pp :: rest.pps;
  top.errors := p.errors ++ rest.errors;
  top.defs := p.defs ++ rest.defs;
  top.decls = p.decls ++ rest.decls;
  top.len = 1 + rest.len;
  
  p.env = top.env;
  rest.env = addEnv(p.defs, top.env);

  local splitTypes :: Pair<Type [Type]> =
    case top.expectedTypes of
    | t::ts -> pair(t, ts)
    | [] -> pair(errorType(), [])
    end;
  p.expectedType = splitTypes.fst;
  rest.expectedTypes = splitTypes.snd;
  
  top.transform = andExpr(p.transform, rest.transform, location=builtin);
  p.transformIn =
    ableC_Expr { $Expr{top.transformIn}.$name{"f" ++ toString(top.position)} };
  rest.transformIn = top.transformIn;
  rest.position = top.position + 1;
}

abstract production nilPattern
top::PatternList ::= {-empty-}
{
  top.pps = [];
  top.errors := [];
  top.len = 0;
  top.defs := [];
  top.decls = [];
  top.transform = mkIntConst(1, builtin);
}



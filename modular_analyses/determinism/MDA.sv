grammar edu:umn:cs:melt:exts:ableC:algDataTypes:modular_analyses:determinism ;

import edu:umn:cs:melt:ableC:host ;


-- datatype MDA tests
copper_mda datatype_datatype(ablecParser) {
  edu:umn:cs:melt:ableC:host;
  edu:umn:cs:melt:exts:ableC:algDataTypes:src:datatype:concretesyntax:datatype;
}

copper_mda datatype_datatypeFwd(ablecParser) {
  edu:umn:cs:melt:ableC:host;
  edu:umn:cs:melt:exts:ableC:algDataTypes:src:datatype:concretesyntax:datatypeFwd;
}


-- patternmatching MDA tests
copper_mda patternmatching_matchExpr(ablecParser) {
  edu:umn:cs:melt:ableC:host;
  edu:umn:cs:melt:exts:ableC:algDataTypes:src:patternmatching:concretesyntax:matchExpr;
}

copper_mda patternmatching_matchStmt(ablecParser) {
  edu:umn:cs:melt:ableC:host;
  edu:umn:cs:melt:exts:ableC:algDataTypes:src:patternmatching:concretesyntax:matchStmt;
}


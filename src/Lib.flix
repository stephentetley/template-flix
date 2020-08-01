/*
 * Copyright 2020 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

use TemplateFlix/QuoteMonad.{QuoteM};
use TemplateFlix/QuoteMonad.{flatMap, return, sequence, option};

use TemplateFlix/Syntax.{Expression};
use TemplateFlix/Syntax.Expression.{SNameE, LitE, ApplyE,  UnaryE, BinaryE, 
    IfThenElseE, TupleE};
use TemplateFlix/Syntax.{Literal};
use TemplateFlix/Syntax.Literal.{UnitL, TrueL, FalseL, CharL, StringL, 
    Int8L, Int16L, Int32L, Int64L};
use TemplateFlix/Syntax.{Name};
use TemplateFlix/Syntax.Name.{Name};
use TemplateFlix/Syntax.{Pattern};
use TemplateFlix/Syntax.Pattern.{LitP, VarP, TagP, TupleP, ArrayP, 
    ArrayTailSpreadP, ArrayHeadSpreadP};

namespace TemplateFlix/Lib {

    type alias ExpressionQ = QuoteM[Expression]
    type alias PatternQ = QuoteM[Pattern]

    /// Literall
    pub def unitL(): Literal = UnitL
    pub def trueL(): Literal = TrueL
    pub def falseL(): Literal = FalseL
    pub def charL(x: Char): Literal = CharL(x)
    pub def stringL(x: String): Literal = StringL(x)
    
    pub def int8L(x: Int8): Literal = Int8L(x)
    pub def int16L(x: Int16): Literal = Int16L(x)
    pub def int32L(x: Int32): Literal = Int32L(x)
    pub def int64L(x: Int64): Literal = Int64L(x)


    /// Pattern
    pub def litP(x: Literal): PatternQ = return(LitP(x))

    pub def varP(ident: Name): PatternQ = return(VarP(ident))

    pub def tagP(ident: Name, pat: Option[PatternQ]): PatternQ = 
        let* p1 = option(pat);
        return(TagP(ident, p1))

    pub def tupleP(xs: List[PatternQ]): PatternQ = 
        let* xs1 = sequence(xs);
        return(TupleP(xs1))

    pub def arrayP(xs: List[PatternQ]): PatternQ = 
        let* xs1 = sequence(xs);
        return(ArrayP(xs1))

    pub def arrayTailSpreadP(xs: List[PatternQ], ident: Name): PatternQ = 
        let* xs1 = sequence(xs);
        return(ArrayTailSpreadP(xs1, ident))

    pub def arrayHeadSpreadP(ident: Name, xs: List[PatternQ]): PatternQ = 
        let* xs1 = sequence(xs);
        return(ArrayHeadSpreadP(ident, xs1))

    pub def litE(x: Literal): ExpressionQ = return(LitE(x))

    pub def applyE(x: ExpressionQ, xs: List[ExpressionQ]): ExpressionQ = 
        let* e = x;
        let* es = sequence(xs);
        return(ApplyE(e, es))


    pub def tupleE(xs: List[ExpressionQ]): ExpressionQ = 
        let* es = sequence(xs);
        return(TupleE(es))
}

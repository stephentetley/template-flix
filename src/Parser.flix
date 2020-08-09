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

use TextParser.TextParser;
use TextParser.TextParser1;
use TextParser.{return, flatMap, map, ap, alt, swapError, parseError, seqRight, seqLeft, 
    tryparse, endOfInput, lookingAts, liftResult, evalLookingAts};
use TextParser/Combinators.{<*, *>};
use TextParser/Combinators.{optional, tuple2, choice, many1Till, ignore, sepBy};
use TextParser/Text.{whiteSpace,  skip1OneOf, content, restOfLine, peekRestOfLine};
use TextParser/Token1.{symbol, lexeme, commaSep};


use TemplateFlix/Syntax.{Attribute};
use TemplateFlix/Syntax.{Case};
use TemplateFlix/Syntax.{ContextBound};
use TemplateFlix/Syntax.{Declaration};
use TemplateFlix/Syntax.Declaration.{DefD, EnumD, RelationD};
use TemplateFlix/Syntax.{Expression};
use TemplateFlix/Syntax.Expression.{SNameE, HoleE, UseE, LitE, ApplyE, UnaryE, BinaryE, IfThenElseE, TupleE, 
    RecordLitE, RecordSelectE, RecordOperationE,
    ArrayLitE, ArrayNewE, ArrayLoadE, ArrayStoreE, ArraySliceE, 
    CastE};
use TemplateFlix/Syntax.{FormalParam};    
use TemplateFlix/Syntax.{JvmOp};
use TemplateFlix/Syntax.JvmOp.{ConstructorJ, MethodJ, StaticMethodJ, GetFieldJ, PutFieldJ, 
    GetStaticFieldJ, PutStaticFieldJ};
use TemplateFlix/Syntax.{Literal};
use TemplateFlix/Syntax.Literal.{UnitL, NullL, TrueL, FalseL, CharL, StringL, 
    Int8L, Int16L, Int32L, Int64L};
use TemplateFlix/Syntax.{Modifier};
use TemplateFlix/Syntax.Modifier.{Modifier};
use TemplateFlix/Syntax.{Name};
use TemplateFlix/Syntax.Name.{Name};
use TemplateFlix/Syntax.{NameAndAlias};
use TemplateFlix/Syntax.{Pattern};
use TemplateFlix/Syntax.Pattern.{LitP, VarP, TagP, TupleP, ArrayP, 
    ArrayTailSpreadP, ArrayHeadSpreadP, FNilP, FConsP};
use TemplateFlix/Syntax.{RecordField};
use TemplateFlix/Syntax.{RecordFieldType};
use TemplateFlix/Syntax.{RecordOp};
use TemplateFlix/Syntax.RecordOp.{ExtendR, RestrictR, UpdateR};
use TemplateFlix/Syntax.{TyParams};
use TemplateFlix/Syntax.TyParams.{ElidedTp, ExplicitTp};
use TemplateFlix/Syntax.{Type};
use TemplateFlix/Syntax.Type.{UnitT, VarT, TupleT, RecordT};
use TemplateFlix/Syntax.{Use};
use TemplateFlix/Syntax.Use.{UseOneU, UseManyU, UseOneTagU, UseManyTagU};

namespace TemplateFlix/Parser {
    
    def <!>(p1: TextParser[a, t], p2: TextParser[a, t]): TextParser[a, t] = 
        alt(p1, p2)

    // Haskells <$>
    def <&>(f: a -> b, p2: TextParser[a, t]): TextParser[b, t] = 
        map(f, p2)

    def <&(x: b, p2: TextParser[a, t]): TextParser[b, t] = 
        p2 *> return(x)


    // Haskells ap <*>
    pub def <*>(mf: TextParser[a -> b, t], p2: TextParser[a, t]): TextParser[b, t] = 
        ap(mf, p2)

    pub def rightUpdate(ma: TextParser[a, t], p2: TextParser[a -> a, t]): TextParser[a, t] = 
        use TextParser/Combinators.{optionalWithDefault};
        let* x = ma;
        let* fn = optionalWithDefault(p2, v -> v);
        return(fn(x))

    /// Change TextParser naming...
    pub def brackets(p: TextParser[r, t]): TextParser[r, t] = TextParser/Token1.squares(p)

    /// Note trueP is an illegal name in Flix

    pub def parses(p: TextParser1[t], input: String) : Result[t, String] & Impure =
        TextParser.runs(p, input)

    pub def pModifier(): TextParser[Modifier, t] = 
        let pInline = symbol("inline")  *> return(Modifier("inline"));
        let pPub    = symbol("pub")     *> return(Modifier("pub"));
        alt(pPub, pInline)

    /// Note pint32 last...
    pub def pLiteral(): TextParser[Literal, t] = 
        let pUnit = symbol("()")  *> return(UnitL);
        let pTrue = symbol("true")  *> return(TrueL);
        let pFalse = symbol("false")  *> return(FalseL);
        choice(pUnit :: pTrue :: pFalse :: pInt8() :: pInt16() :: pInt64() :: pInt32() :: Nil)

    def pInt8(): TextParser[Literal, t] = 
        use Text/Regex/MatchEvaluator.{getCapture};
        let* s = evalLookingAts("(?<body>-?\d+)i8", getCapture(0));
        let* i = liftResult(Int8.fromString(s));
        return(Int8L(i))

    def pInt16(): TextParser[Literal, t] = 
        use Text/Regex/MatchEvaluator.{getCapture};
        let* s = evalLookingAts("(?<body>-?\d+)i16", getCapture(0));
        let* i = liftResult(Int16.fromString(s));
        return(Int16L(i))

    def pInt32(): TextParser[Literal, t] = 
        use Text/Regex/MatchEvaluator.{getCapture};
        let* s = evalLookingAts("(?<body>-?\d+)(?:i32)?", getCapture(0));
        let* i = liftResult(Int32.fromString(s));
        return(Int32L(i))

    def pInt64(): TextParser[Literal, t] = 
        use Text/Regex/MatchEvaluator.{getCapture};
        let* s = evalLookingAts("(?<body>-?\d+)i64", getCapture(0));
        let* i = liftResult(Int64.fromString(s));
        return(Int64L(i))

    pub def pExpression(): TextParser[Expression, t] = 
        pExpression10()

    // cast (postfix)
    def pExpression10(): TextParser[Expression, t] =
        pExpression9() `rightUpdate`  pCast()

    inline def pCast(): TextParser[Expression -> Expression, t] =
        let* _ = symbol("as");
        let* tpe = optional(pType());
        let* etpe = optional(symbol("&") *> pType());
        return(x -> CastE(x, tpe, etpe))

    def pExpression9(): TextParser[Expression, t] = 
        pPrimaryExpression() 


    /// Identifer, Literal or parens(expression)
    pub def pPrimaryExpression(): TextParser[Expression, t] = 
        let pSNameE = map(SNameE, pName());
        let pLiteralE = LitE <&> pLiteral();
        pSNameE <!> pLiteralE

    pub def pArrayLitE(): TextParser[Expression, t] = 
        ArrayLitE <&> brackets(commaSep(pExpression()))

    pub def pName(): TextParser[Name, t] = 
        Name <&> lookingAts("(\p{Lower}|_)(\p{Alnum}|_)*")

    pub def pPattern(): TextParser[Pattern, t] = 
        let pLiteralP = LitP <&> pLiteral();
        let pVarP = VarP <&> pName();
        pLiteralP <!> pVarP

    pub def pType(): TextParser[Type, t] = 
        let pUnitT = UnitT <& symbol("Unit");
        let pVarT = VarT <&> pName();
        pUnitT <!> pVarT


}


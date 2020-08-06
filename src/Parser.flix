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
use TextParser.{return, map, alt, swapError, parseError, seqRight, seqLeft, tryparse, endOfInput, lookingAts, liftResult};
use TextParser/Combinators.{tuple2, choice, many1Till, ignore};
use TextParser/Text.{whiteSpace,  skip1OneOf, content, restOfLine, peekRestOfLine};
use TextParser/Token1.{symbol, lexeme};


use TemplateFlix/Syntax.{Attribute};
use TemplateFlix/Syntax.{Case};
use TemplateFlix/Syntax.{ContextBound};
use TemplateFlix/Syntax.{Declaration};
use TemplateFlix/Syntax.Declaration.{DefD, EnumD, RelationD};
use TemplateFlix/Syntax.{Expression};
use TemplateFlix/Syntax.Expression.{SNameE, HoleE, UseE, LitE, ApplyE, UnaryE, BinaryE, IfThenElseE, TupleE, 
    RecordLitE, RecordSelectE, RecordOperationE,
    ArrayLitE, ArrayNewE, ArrayLoadE, ArrayStoreE, ArraySliceE};
use TemplateFlix/Syntax.{FormalParam};    
use TemplateFlix/Syntax.{JvmOp};
use TemplateFlix/Syntax.JvmOp.{ConstructorJ, MethodJ, StaticMethodJ, GetFieldJ, PutFieldJ, 
    GetStaticFieldJ, PutStaticFieldJ};
use TemplateFlix/Syntax.{Literal};
use TemplateFlix/Syntax.Literal.{UnitL, NullL, TrueL, FalseL, CharL, StringL, 
    Int8L, Int16L, Int32L, Int64L};
use TemplateFlix/Syntax.{Modifier};
use TemplateFlix/Syntax.Modifier.{Modifier};
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
    
    /// Add to TextParser
    pub def *>(p1: TextParser[a, t], p2: TextParser[b, t]): TextParser[b, t] = seqRight(p1, p2)
    
    /// Add to TextParser
    pub def <*(p1: TextParser[a, t], p2: TextParser[b, t]): TextParser[a, t] = seqLeft(p1, p2)

    pub def modifierP(): TextParser[Modifier, t] = 
        let inlineP = symbol("inline")  *> return(Modifier("inline"));
        let pubP    = symbol("pub")     *> return(Modifier("pub"));
        alt(pubP, inlineP)
    
}

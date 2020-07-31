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



use TemplateFlix/PrettyLib.{Doc};
use TemplateFlix/PrettyLib.{text, int8, int16, int32, int64,
    ppName, parens, commaSep, commaSpaceSep, squotes, dquotes, 
    braces, brackets, equals, colon, pipe, vsep};
use TemplateFlix/PrettyLib.{<>, <<>>};

use TemplateFlix/Syntax.{Attribute};
use TemplateFlix/Syntax.{Case};
use TemplateFlix/Syntax.{Declaration};
use TemplateFlix/Syntax.Declaration.{EnumD, RelationD};
use TemplateFlix/Syntax.{Expression};
use TemplateFlix/Syntax.Expression.{SNameE, LitE, ApplyE, UnaryE, BinaryE, IfThenElseE, TupleE, RecordLitE, 
    ArrayLitE};
use TemplateFlix/Syntax.{Literal};
use TemplateFlix/Syntax.Literal.{UnitL, NullL, TrueL, FalseL, CharL, StringL, 
    Int8L, Int16L, Int32L, Int64L};
use TemplateFlix/Syntax.{Pattern};
use TemplateFlix/Syntax.Pattern.{LitP, VarP, TagP, TupleP};
use TemplateFlix/Syntax.{RecordField};
use TemplateFlix/Syntax.{RecordFieldType};
use TemplateFlix/Syntax.{Type};
use TemplateFlix/Syntax.Type.{UnitT, VarT, TupleT, RecordT};

namespace TemplateFlix/Pretty {

    def noPrec(): Int32 = 0

    pub def ppDeclaration(x: Declaration): Doc = match x { 
        case EnumD(v, _, cs)            => text("enum") <<>> ppName(v) <<>> braces(vsep(List.map(ppCase, cs)))
        case RelationD(v, _, cs)        => text("rel") <<>> ppName(v) <<>> parens(commaSpaceSep(List.map(ppAttribute, cs)))
    }

    pub def ppCase(x: Case): Doc = match x.tpe { 
        case UnitT          => text("case") <<>> ppName(x.ident)
        case TupleT(_)      => text("case") <<>> ppName(x.ident) <> ppType(x.tpe)
        case _              => text("case") <<>> ppName(x.ident) <> parens(ppType(x.tpe))
    }

    pub def ppAttribute(x: Attribute): Doc = ppName(x.ident) <> colon() <<>> ppType(x.tpe)
        

    pub def ppLiteral(_prec: Int32, x: Literal): Doc = match x { 
        case UnitL              => text("()")
        case TrueL              => text("true")
        case NullL              => text("null")
        case FalseL             => text("false")
        case CharL(c)           => squotes(text(Char.toString(c)))
        case StringL(s)         => dquotes(ppString(s))
        case Int8L(d)           => int8(d) <> text("i8")
        case Int16L(d)          => int16(d) <> text("i16")
        case Int32L(d)          => int32(d)
        case Int64L(d)          => int64(d) <> text("i64")
    }

    pub def ppPattern(prec: Int32, x: Pattern): Doc = match x { 
        case LitP(l)            => ppLiteral(prec, l)
        case VarP(v)            => ppName(v)
        case TagP(n, None)      => ppName(n)
        case TagP(n, Some(p))   => ppName(n) <> ppPattern(prec, p)
        case TupleP(ps)         => parens(commaSep(List.map(ppPattern(noPrec()), ps)))        
    }

    pub def ppExpression(prec: Int32, x: Expression): Doc = match x { 
        case SNameE(s)                  => ppName(s)
        case LitE(l)                    => ppLiteral(prec, l)
        case ApplyE(e1, es)             => ppExpression(prec, e1) <> parens(commaSpaceSep(List.map(ppExpression(prec), es)))
        case UnaryE(op, e)              => text(op) <> ppExpression(prec, e)
        case BinaryE(e1, op, e2)        => ppExpression(prec, e1) <> text(op) <> ppExpression(prec, e2)
        case IfThenElseE(e1, e2, e3)    => text("if") <<>> parens(ppExpression(prec, e1)) <<>> ppExpression(prec, e2) <<>> text("else") <<>> ppExpression(prec, e3)
        case TupleE(es)                 => parens(commaSpaceSep(List.map(ppExpression(prec), es)))
        case RecordLitE(xs)             => braces(commaSpaceSep(List.map(ppRecordField(prec), xs)))
        case ArrayLitE(es)              => brackets(commaSpaceSep(List.map(ppExpression(prec), es)))
    }

    def ppRecordField(prec: Int32, x: RecordField): Doc = 
        ppName(x.label) <<>> equals() <<>> ppExpression(prec, x.value)

    pub def ppType(x: Type): Doc = match x {
        case UnitT                      => text("Unit")
        case VarT(v)                    => ppName(v)
        case TupleT(ts)                 => parens(commaSpaceSep(List.map(ppType, ts)))
        case RecordT(ts, Some(v))       => braces(commaSpaceSep(List.map(ppRecordFieldType, ts)) <> pipe() <> ppName(v))
        case RecordT(ts, None)          => braces(commaSpaceSep(List.map(ppRecordFieldType, ts)))
        
    }
        
    def ppRecordFieldType(x: RecordFieldType): Doc = 
        ppName(x.label) <> colon() <<>> ppType(x.tpe)


    pub def ppString(x: String): Doc = text(x)
}

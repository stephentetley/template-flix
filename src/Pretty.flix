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
use TemplateFlix/PrettyLib.{empty, char, text, int8, int16, int32, int64,
    ppName, parens, commaSep, commaSpaceSep, squotes, dquotes, 
    braces, brackets, tupled, equals, ampersand, colon, pipe, vsep, hcat, hsep, dot, semi};
use TemplateFlix/PrettyLib.{<>, <<>>, <!>};

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

namespace TemplateFlix/Pretty {

    def noPrec(): Int32 = 0
    def maxPrec(): Int32 = 10       // ???

    pub def ppDeclaration(x: Declaration): Doc = match x { 
        case DefD(n, typams, formals, ty, ety, e1)        =>
            text("def") <<>> ppName(n) <> ppTyParams(typams) <> pplFormalParam(formals)
                <> colon() <<>> ppType(ty) <<>> ppoEffect(ety) <<>> ppExpression(maxPrec(), e1)

        case EnumD(v, typams, cs)            => 
            text("enum") <<>> ppName(v) <<>> ppTyParams(typams) <> braces(vsep(List.map(ppCase, cs)))
        
        case RelationD(v, typams, cs)        => 
            text("rel") <<>> ppName(v) <<>> ppTyParams(typams) <> parens(commaSpaceSep(List.map(ppAttribute, cs)))
    }

    def ppoEffect(x: Option[Type]): Doc = match x { 
        case None       => empty()
        case Some(ty)   => ampersand() <<>> ppType(ty)
    }
    

    pub def ppAttribute(x: Attribute): Doc = ppName(x.ident) <> colon() <<>> ppType(x.tpe)
        

    pub def ppCase(x: Case): Doc = match x.tpe { 
        case UnitT          => text("case") <<>> ppName(x.ident)
        case TupleT(_)      => text("case") <<>> ppName(x.ident) <> ppType(x.tpe)
        case _              => text("case") <<>> ppName(x.ident) <> parens(ppType(x.tpe))
    }


    pub def ppUse(x: Use): Doc = match x { 
        case UseOneU(qname, n)          => text("use") <<>> ppName(qname) <> dot() <> ppName(n)
        case UseManyU(qname, ns)        => 
            text("use") <<>> ppName(qname) <> dot() <> braces(commaSpaceSep(List.map(ppNameAndAlias, ns)))

        case UseOneTagU(qname, n)       => text("use") <<>> ppName(qname) <> dot() <> ppName(n)
        case UseManyTagU(qname, ns)     => 
            text("use") <<>> ppName(qname) <> dot() <> braces(commaSpaceSep(List.map(ppNameAndAlias, ns)))
    }
    
    pub def ppNameAndAlias (x: NameAndAlias): Doc = match x.alias { 
        case Some(n2)   => ppName(x.ident) <<>> text("=>") <<>> ppName(n2)
        case None       => ppName(x.ident)
    }
        

    
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
        case LitP(l)                    => ppLiteral(prec, l)
        case VarP(v)                    => ppName(v)
        case TagP(n, None)              => ppName(n)
        case TagP(n, Some(p))           => ppName(n) <> ppPattern(prec, p)
        case TupleP(ps)                 => parens(commaSep(List.map(ppPattern(noPrec()), ps)))
        case ArrayP(ps)                 => brackets(commaSep(List.map(ppPattern(noPrec()), ps)))
        case ArrayTailSpreadP(ps, n)    => 
            let tl = (text("..") <> ppName(n)) :: Nil;
            commaSep(List.map(ppPattern(noPrec()), ps) ::: tl)
        
        case ArrayHeadSpreadP(n, ps)    => 
            let hd = ppName(n) <> text("..");
            commaSep(hd :: List.map(ppPattern(noPrec()), ps))
        
        case FNilP                      => text("Nil")
        case FConsP(hd,tl)              => ppPattern(prec, hd) <<>> text("::") <<>> ppPattern(prec, tl)
    }

    pub def ppExpression(prec: Int32, x: Expression): Doc = match x { 
        case SNameE(s)                          => ppName(s)
        case HoleE(None)                        => char('?')
        case UseE(u, e1)                        => ppUse(u) <> semi() <!> ppExpression(maxPrec(), e1)
        case LitE(l)                            => ppLiteral(prec, l)
        case HoleE(Some(n))                     => char('?') <> ppName(n)
        case ApplyE(e1, es)                     => 
            ppExpression(prec, e1) <> parens(commaSpaceSep(List.map(ppExpression(prec), es)))

        case UnaryE(op, e)                      => text(op) <> ppExpression(prec, e)
        case BinaryE(e1, op, e2)                => ppExpression(prec, e1) <> text(op) <> ppExpression(prec, e2)
        case IfThenElseE(e1, e2, e3)            => 
            text("if") <<>> parens(ppExpression(prec, e1)) <<>> ppExpression(prec, e2) <<>> text("else") <<>> ppExpression(prec, e3)

        case TupleE(es)                         => parens(commaSpaceSep(List.map(ppExpression(prec), es)))
        case RecordLitE(xs)                     => braces(commaSpaceSep(List.map(ppRecordField(prec), xs)))
        case RecordSelectE(e, n)                => ppExpression(prec, e) <> dot() <> ppName(n)
        case RecordOperationE(ops, e)   => 
            braces(commaSpaceSep(List.map(ppRecordOp, ops)) <<>> pipe() <<>> ppExpression(prec, e))

        case ArrayLitE(es)                      => brackets(commaSpaceSep(List.map(ppExpression(prec), es)))
        case ArrayNewE(e1, e2)                  => 
            brackets(ppExpression(prec, e1) <> semi() <<>> ppExpression(prec, e2))

        case ArrayLoadE(e1, e2)                 => 
            ppExpression(prec, e1) <> brackets(ppExpression(prec, e2))

        case ArrayStoreE(e1, es, e2)            => {
            let ixs = hcat(List.map(e -> brackets(ppExpression(maxPrec(), e)), es));
            ppExpression(prec, e1) <> ixs <<>> equals() <<>> ppExpression(prec, e2)
        }

        case ArraySliceE(e1, None, None)        => 
            ppExpression(prec, e1) <> brackets(text(".."))

        case ArraySliceE(e1, None, Some(ee))    => 
            ppExpression(prec, e1) <> brackets(text("..") <> ppExpression(maxPrec(), ee))
        
        case ArraySliceE(e1, Some(eb), None)    => 
            ppExpression(prec, e1) <> brackets(ppExpression(maxPrec(), eb) <> text(".."))
        
        case ArraySliceE(e1, Some(eb), Some(ee))    => 
            ppExpression(prec, e1) <> brackets(ppExpression(maxPrec(), eb) <> text("..") <> ppExpression(maxPrec(), ee))
        

    }

    def ppRecordField(prec: Int32, x: RecordField): Doc = 
        ppName(x.label) <<>> equals() <<>> ppExpression(prec, x.value)

    pub def ppType(x: Type): Doc = match x {
        case UnitT                      => text("Unit")
        case VarT(v)                    => ppName(v)
        case TupleT(ts)                 => tupled(List.map(ppType, ts))
        case RecordT(ts, Some(v))       => braces(commaSpaceSep(List.map(ppRecordFieldType, ts)) <> pipe() <> ppName(v))
        case RecordT(ts, None)          => braces(commaSpaceSep(List.map(ppRecordFieldType, ts)))
        
    }


    pub def ppTyParams(x: TyParams): Doc = match x {
        case ElidedTp           => empty()
        case ExplicitTp(xs)     => brackets(commaSpaceSep(List.map(ppContextBound, xs)))
    }


    def ppRecordFieldType(x: RecordFieldType): Doc = 
        ppName(x.label) <> colon() <<>> ppType(x.tpe)

    def ppContextBound(x: ContextBound): Doc = match x.tparams { 
        case Nil        => ppName(x.ident) 
        case t1 :: Nil  => ppName(x.ident) <> colon() <<>> ppType(t1)
        case xs         => ppName(x.ident) <> colon() <<>> tupled(List.map(ppType, xs))     // Expected to be wrong...
    }


    def pplFormalParam(xs: List[FormalParam]): Doc = 
        parens(commaSpaceSep(List.map(ppFormalParam, xs)))

    def ppFormalParam(x: FormalParam): Doc = match x.tpe {
        case Some(ty)   => pplModifier(x.modifiers) <<>> ppName(x.ident) <> colon() <<>> ppType(ty)
        case None       => pplModifier(x.modifiers) <<>> ppName(x.ident)
    }
        

    pub def pplModifier(xs: List[Modifier]): Doc = hsep(List.map(ppModifier, xs))

    pub def ppModifier(x: Modifier): Doc = 
        let Modifier(x1) = x;
        text(x1)

    def ppString(x: String): Doc = text(x)

    /// TODO - handle name differences betwen static and non-static
    pub def ppJvmOp(x: JvmOp): Doc = match x { 
        case ConstructorJ(name, ts, fname)          => 
            text("import") <<>> text("new") <<>> ppName(name) <> tupled(List.map(ppType, ts)) 
                <<>> text("as") <<>> ppName(fname)

        case MethodJ(name, ts, None)                => 
            text("import") <<>> ppName(name) <> tupled(List.map(ppType, ts)) 
        
        case MethodJ(name, ts, Some(fname))         => 
            text("import") <<>> ppName(name) <> tupled(List.map(ppType, ts)) 
                <<>> text("as") <<>> ppName(fname)

        case StaticMethodJ(name, ts, None)          => 
            text("import") <<>> text("static") <<>> ppName(name) <> tupled(List.map(ppType, ts)) 
        
        case StaticMethodJ(name, ts, Some(fname))   => 
            text("import") <<>> text("static") <<>> ppName(name) <> tupled(List.map(ppType, ts)) 
                <<>> text("as") <<>> ppName(fname)

        case GetFieldJ(name, fname)                 => 
            text("import") <<>> text("get") <<>> ppName(name) <<>> text("as") <<>> ppName(fname)

        case PutFieldJ(name, fname)                 => 
            text("import") <<>> text("set") <<>> ppName(name) <<>> text("as") <<>> ppName(fname)

        case GetStaticFieldJ(name, fname)           => 
            text("import") <<>> text("get") <<>> ppName(name) <<>> text("as") <<>> ppName(fname)

        case PutStaticFieldJ(name, fname)           => 
            text("import") <<>> text("set") <<>> ppName(name) <<>> text("as") <<>> ppName(fname)
    }

    pub def ppRecordOp(x: RecordOp): Doc = match x { 
        case ExtendR(name, e)                   => 
            char('+') <> ppName(name) <<>> equals() <<>> ppExpression(maxPrec(), e)

        case RestrictR(name)                    => char('-') <> ppName(name)

        case UpdateR(name, e)                   => 
            ppName(name) <<>> equals() <<>> ppExpression(maxPrec(), e)
    }

}

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



namespace TemplateFlix/Syntax {

    pub opaque type Name = String


    pub enum Declaration {
        case EnumD(Name, TyParams, List[Case])
        case RelationD(Name, TyParams, List[Attribute])
    }

    pub enum Literal { 
        case UnitL
        case NullL
        case TrueL
        case FalseL
        case CharL(Char)
        case StringL(String)
        case Int8L(Int8)
        case Int16L(Int16)
        case Int32L(Int32)
        case Int64L(Int64)
    }

    pub enum Expression { 
        case SNameE(Name)
        case LitE(Literal)                                          // { 1 } or { "hello"} etc.
        case HoleE(Option[Name])
        case ApplyE(Expression, List[Expression])                   // { max(1, 2) }
        case UnaryE(String, Expression)                             // { !true }
        case BinaryE(Expression, String, Expression)
        case IfThenElseE(Expression, Expression, Expression)        // { if (e1) e2 else e3 }
        case TupleE(List[Expression])
        case RecordLitE(List[RecordField])
        case RecordSelectE(Expression, Name)
        /// RecordSelectLambda ?
        case RecordOperationE(List[RecordOp], Expression)
        case ArrayLitE(List[Expression])
        case ArrayNewE(Expression, Expression)
        case ArrayLoadE(Expression, Expression)
        case ArrayStoreE(Expression, List[Expression], Expression)
        case ArraySliceE(Expression, Option[Expression], Option[Expression])
    }

    pub enum Pattern { 
        case LitP(Literal)
        case VarP(Name)
        case TagP(Name, Option[Pattern])
        case TupleP(List[Pattern])
        case ArrayP(List[Pattern])
        case ArrayTailSpreadP(List[Pattern], Name)
        case ArrayHeadSpreadP(Name, List[Pattern])
        case FNilP
        case FConsP(Pattern, Pattern)
    }

    type alias Case = { ident: Name, tpe: Type }
    type alias Attribute = { ident: Name, tpe: Type }


    pub enum Type {
        case UnitT
        case VarT(Name)
        case TupleT(List[Type])
        case RecordT(List[RecordFieldType], Option[Name])
    }

    pub enum TyParams {
        case Elided()
        case Explicit(List[ContextBound])
    }

    type alias RecordField = { label: Name, value: Expression }

    type alias RecordFieldType = { label: Name, tpe: Type }

    type alias ContextBound = { ident: Name, tparams: List[Type] }

    pub enum JvmOp { 
        case ConstructorJ(Name, List[Type], Name)
        case MethodJ(Name, List[Type], Option[Name])
        case StaticMethodJ(Name, List[Type], Option[Name])
        case GetFieldJ(Name, Name)
        case PutFieldJ(Name, Name)
        case GetStaticFieldJ(Name, Name)
        case PutStaticFieldJ(Name, Name)
    }

    pub enum RecordOp { 
        case ExtendR(Name, Expression)
        case RestrictR(Name)
        case UpdateR(Name, Expression)
    }

    pub enum PredicateType { 
        case PredicateWithAliasT(Name, Option[List[Type]])
        case RelPredicateWithTypesT(Name, Option[List[Type]])
        case LatPredicateWithTypesT(Name, Option[List[Type]])
    }

}

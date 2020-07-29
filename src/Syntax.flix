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


    pub enum Decl {
        case Enum(Name, TyParams, List[Case])
    }

    pub enum Lit { 
        case CharL(Char)
        case StringL(String)
        case Int32L(Int32)
    }

    pub enum Pat { 
        case LitP(Lit)
        case VarP(Name)
        case TagP(Name, Option[Pat])
        case TupleP(List[Pat])

    }

    pub enum Exp { 
        case SNameE(Name)
        case LitE(Lit)
        case ApplyE(Exp, List[Exp])
        case UnaryE(String, Exp)
        case BinaryE(Exp, String, Exp)
        case IfThenElseE(Exp, Exp, Exp)         // { if (e1) e2 else e3 }
        case TupleE(List[Exp])
    }

    pub enum Case {
        case Case(Name, Type)
    }

    pub enum Type {
        case Tunit()
    }

    pub enum TyParams {
        case Elided()
        case Explicit(List[ContextBound])
    }

    type alias ContextBound = { ident: Name, tparams: List[Type] }

}

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

    pub enum Lit { 
        case CharL(Char)
        case StringL(String)
        case Int32L(Int32)
    }

    pub enum Pat { 
        case LitP(Lit)
        case VarP(Name)
    }

    pub enum Exp { 
        case VarE(Name)
        case LitE(Lit)
        case TupE(Option[Exp])
    }
}

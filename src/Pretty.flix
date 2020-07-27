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
use TemplateFlix/PrettyLib.{text, int32, ppName};

use TemplateFlix/Syntax.{Exp};
use TemplateFlix/Syntax.Exp.{SNameE};
use TemplateFlix/Syntax.{Lit};
use TemplateFlix/Syntax.Lit.{CharL, StringL, Int32L};
use TemplateFlix/Syntax.{Pat};
use TemplateFlix/Syntax.Pat.{LitP, VarP};

namespace TemplateFlix/Pretty {

    pub def ppLit(_prec: Int32, x: Lit): Doc = match x { 
        case CharL(c) => text(Char.toString(c))
        case StringL(s) => ppString(s)
        case Int32L(d) => int32(d)
    }

    pub def ppPat(prec: Int32, x: Pat): Doc = match x { 
        case LitP(l) => ppLit(prec, l)
        case VarP(v) => ppName(v)
    }

    pub def ppExp(_prec: Int32, x: Exp): Doc = match x { 
        case SNameE(s) => ppName(s)
        case _ => text("TODO")
    }

    pub def ppString(x: String): Doc = text(x)
}

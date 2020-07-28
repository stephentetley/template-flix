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
use TemplateFlix/QuoteMonad.{return, sequence};

use TemplateFlix/Syntax.{Exp};
use TemplateFlix/Syntax.Exp.{SNameE, LitE, ApplyE,  UnaryE, BinaryE, 
    IfThenElseE, TupleE};
use TemplateFlix/Syntax.{Lit};
use TemplateFlix/Syntax.Lit.{CharL, StringL, Int32L};
use TemplateFlix/Syntax.{Name};
use TemplateFlix/Syntax.Name.{Name};
use TemplateFlix/Syntax.{Pat};
use TemplateFlix/Syntax.Pat.{LitP, VarP};

namespace TemplateFlix/Lib {

    type alias ExpQ = QuoteM[Exp]
    type alias PatQ = QuoteM[Pat]

    pub def charL(x: Char): Lit = CharL(x)
    pub def stringL(x: String): Lit = StringL(x)
    pub def int32L(x: Int32): Lit = Int32L(x)

    pub def litP(x: Lit): PatQ = return(LitP(x))

    pub def varP(x: Name): PatQ = return(VarP(x))

    pub def tupleE(xs: List[ExpQ]): ExpQ = 
        use TemplateFlix/QuoteMonad.flatMap;
        let* es = sequence(xs);
        return(TupleE(es))
}

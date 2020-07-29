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

use TemplateFlix/Syntax.Name;
use TemplateFlix/Syntax.Name.{Name};

namespace TemplateFlix/QuoteMonad {

    pub opaque type QuoteM[a] = State ~> (a, State)
    
    type alias State = Unit

    pub def return(x: a): QuoteM[a] = 
        QuoteM(s -> (x, s) as & Impure)

    def apply1(ma: QuoteM[a], s: State): (a, State) & Impure = 
        let QuoteM(f) = ma;
        f(s) 

    pub def map(f: a -> b, ma: QuoteM[a]): QuoteM[b] = 
        QuoteM(s -> 
            let (a, s1) = apply1(ma, s);
            (f(a), s1)
        )

    pub def ap(mf: QuoteM[a -> b], ma: QuoteM[a]): QuoteM[b] = 
        QuoteM(s -> 
            let (f, s1) = apply1(mf, s);
            let (a, s2) = apply1(ma, s1);
            (f(a), s2)
        )

    pub def bind(ma: QuoteM[a], k: a -> QuoteM[b]): QuoteM[b] = 
        QuoteM(s -> 
            let (a, s1) = apply1(ma, s);
            apply1(k(a), s1)
        )

    pub def flatMap(k: a -> QuoteM[b], ma: QuoteM[a]): QuoteM[b] = bind(ma, k)

    pub def sequence(xs: List[QuoteM[a]]): QuoteM[List[a]] = 
        sequenceHelper(xs, ks -> return(ks))

    ///
    /// Helper function for `sequence`.
    ///
    def sequenceHelper(xs: List[QuoteM[a]], k: List[a] -> QuoteM[List[a]]): QuoteM[List[a]] = match xs {
        case Nil        => k(Nil)
        case mx :: rs   => sequenceHelper(rs, ys -> bind(mx, x-> k(x :: ys)))    
    }

    pub def newName(x: String): QuoteM[Name] = return(Name(x))

    // reify?
}

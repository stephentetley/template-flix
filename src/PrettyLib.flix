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

use TemplateFlix/Syntax.{Name};
use TemplateFlix/Syntax.Name.{Name};

namespace TemplateFlix/PrettyLib {

    type alias State = Map[Name, Name]

    type alias Doc = PPMonad[Text/PrettyPrint.Doc]

    pub opaque type PPMonad[a] = State -> (a, State)

    pub def return(x: a): PPMonad[a] = 
        PPMonad(s -> (x, s))

    def apply1(ma: PPMonad[a], s: State): (a, State) = 
        let PPMonad(f) = ma;
        f(s)

    pub def map(f: a -> b, ma: PPMonad[a]): PPMonad[b] = 
        PPMonad(s -> 
            let (a, s1) = apply1(ma, s);
            (f(a), s1)
        )

    pub def ap(mf: PPMonad[a -> b], ma: PPMonad[a]): PPMonad[b] = 
        PPMonad(s -> 
            let (f, s1) = apply1(mf, s);
            let (a, s2) = apply1(ma, s1);
            (f(a), s2)
        )

    pub def bind(ma: PPMonad[a], k: a -> PPMonad[b]): PPMonad[b] = 
        PPMonad(s -> 
            let (a, s1) = apply1(ma, s);
            apply1(k(a), s1)
        )

    pub def flatMap(k: a -> PPMonad[b], ma: PPMonad[a]): PPMonad[b] = bind(ma, k)


    pub def empty(): Doc = 
        return(Text/PrettyPrint.empty())

    pub def semi(): Doc = 
        return(Text/PrettyPrint.semi())

    pub def text(x: String): Doc = 
        return(Text/PrettyPrint.text(x))

    pub def int32(x: Int32): Doc = 
        return(Text/PrettyPrint.int32(x))

    /// TODO - Haskell is tracking fresh names here?
    pub def ppName(x: Name): Doc = 
        let Name(s) = x;
        text(s)

}
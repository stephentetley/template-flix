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

    pub def runPretty(mx: PPMonad[a]): a = 
        apply1(mx, Map.empty()) |> fst

    pub def show(x: Doc): String = 
        runPretty(x) |> Text/PrettyPrint.prettyPrint(120)

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

    pub def sequence(xs: List[PPMonad[a]]): PPMonad[List[a]] = 
        sequenceHelper(xs, ks -> return(ks))

    ///
    /// Helper function for `sequence`.
    ///
    def sequenceHelper(xs: List[PPMonad[a]], k: List[a] -> PPMonad[List[a]]): PPMonad[List[a]] = match xs {
        case Nil        => k(Nil)
        case mx :: rs   => sequenceHelper(rs, ys -> bind(mx, x-> k(x :: ys)))    
    }
   

    ///
    /// Applies the binary function `f` to the values in `r1` and `r2`.
    ///
    /// Returns the first `Err(e)` value if either of `r1` and `r2` are `Err(e)`.
    ///
    pub def lift2(f: (t1, t2) -> u, r1: PPMonad[t1], r2: PPMonad[t2]): PPMonad[u] =
        ap(map(f, r1), r2)

    ///
    /// Applies the ternary function `f` to the values in `r1`, `r2` and `r3`.
    ///
    /// Returns the first `Err(e)` value if any of `r1`, `r2` and `r3` are `Err(e)`.
    ///
    pub def lift3(f: (t1, t2, t3) -> u, r1: PPMonad[t1], r2: PPMonad[t2], r3: PPMonad[t3]): PPMonad[u] =
        ap(lift2(f, r1, r2), r3)

    ///
    /// Applies the 4-ary function `f` to the values in `r1`, `r2`, `r3` and `r4`.
    ///
    /// Returns the first `Err(e)` value if any of `r1`, `r2`, `r3` and `r4` are `Err(e)`.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u, r1: PPMonad[t1], r2: PPMonad[t2], r3: PPMonad[t3], r4: PPMonad[t4]): PPMonad[u] =
        ap(lift3(f, r1, r2, r3), r4)


    pub def empty(): Doc = return(Text/PrettyPrint.empty())

    pub def ampersand(): Doc = return(Text/PrettyPrint.char('&'))

    pub def semi(): Doc = return(Text/PrettyPrint.semi())

    pub def comma(): Doc = return(Text/PrettyPrint.comma())

    pub def colon(): Doc = return(Text/PrettyPrint.colon())

    pub def dcolon(): Doc = return(Text/PrettyPrint.text("::"))

    pub def space(): Doc = return(Text/PrettyPrint.space())

    pub def equals(): Doc = return(Text/PrettyPrint.equals())

    pub def dot(): Doc = return(Text/PrettyPrint.dot())

    pub def arrow(): Doc = return(Text/PrettyPrint.text("->"))

    pub def pipe(): Doc = return(Text/PrettyPrint.text("|"))

    pub def lparen(): Doc = return(Text/PrettyPrint.lparen())
    
    pub def rparen(): Doc = return(Text/PrettyPrint.rparen())

    pub def lbrace(): Doc = return(Text/PrettyPrint.lbrace())

    pub def rbrace(): Doc = return(Text/PrettyPrint.rbrace())

    pub def lbracket(): Doc = return(Text/PrettyPrint.lbracket())

    pub def rbracket(): Doc = return(Text/PrettyPrint.rbracket())


    pub def text(x: String): Doc = return(Text/PrettyPrint.text(x))
    pub def char(x: Char): Doc = return(Text/PrettyPrint.char(x))

    pub def int8(x: Int8): Doc = return(Text/PrettyPrint.int8(x))

    pub def int16(x: Int16): Doc = return(Text/PrettyPrint.int16(x))

    pub def int32(x: Int32): Doc = return(Text/PrettyPrint.int32(x))

    pub def int64(x: Int64): Doc = return(Text/PrettyPrint.int64(x))

    pub def parens(d: Doc): Doc = map(Text/PrettyPrint.parens, d)

    pub def braces(d: Doc): Doc = map(Text/PrettyPrint.braces, d)

    pub def brackets(d: Doc): Doc = map(Text/PrettyPrint.brackets, d)

    pub def squotes(d: Doc): Doc = map(Text/PrettyPrint.squotes, d)

    pub def dquotes(d: Doc): Doc = map(Text/PrettyPrint.dquotes, d)


    pub def hang(i: Int32, d: Doc): Doc = map(Text/PrettyPrint.hang(i), d)

    /// Always separate with commaSpace
    pub def tupled(docs: List[Doc]): Doc = 
        parens(commaSpaceSep(docs))

    pub def hcat(docs: List[Doc]): Doc = 
        let* ds1 = sequence(docs);
        return(Text/PrettyPrint.hcat(ds1))

    pub def hsep(docs: List[Doc]): Doc = 
        let* ds1 = sequence(docs);
        return(Text/PrettyPrint.hsep(ds1))

    pub def vsep(docs: List[Doc]): Doc = 
        let* ds1 = sequence(docs);
        return(Text/PrettyPrint.vsep(ds1))

    pub def punctuate(sep: Doc, docs: List[Doc]): List[Doc] = punctuateHelper(sep, docs, xs -> xs)
    

    pub def punctuateHelper(sep: Doc, ds:List[Doc], k: List[Doc] -> List[Doc]): List[Doc] = match ds {
        case Nil => k(Nil)
        case d :: Nil => k(d :: Nil)
        case d :: rs    => punctuateHelper(sep, rs, xs -> k((d <> sep) :: xs))
    }

    pub def commaSep(xs: List[Doc]): Doc = hcat(punctuate(comma(), xs))

    pub def commaSpaceSep(xs: List[Doc]): Doc = hcat(punctuate(text(", "), xs))

    pub def <>(d1: Doc, d2: Doc): Doc = 
        use Text/PrettyPrint.{beside};
        lift2(beside, d1, d2)

    pub def <<>>(d1: Doc, d2: Doc): Doc = 
        use Text/PrettyPrint.{besideSpace};
        lift2(besideSpace, d1, d2)

    pub def <!>(d1: Doc, d2: Doc): Doc = 
        use Text/PrettyPrint.{besideSoftline};
        lift2(besideSoftline, d1, d2)

    /// TODO - Haskell is tracking fresh names here?
    pub def ppName(x: Name): Doc = 
        let Name(s) = x;
        text(s)

}
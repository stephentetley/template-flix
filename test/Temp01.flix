use TemplateFlix/QuoteMonad.{runQ};
use TemplateFlix/Pretty.{ppExp};
use TemplateFlix/PrettyLib.{show};
use TemplateFlix/Lib.{ExpQ};
use TemplateFlix/Lib.{tupleE, litE, stringL, int32L};

def exp1(): ExpQ = 
   tupleE(litE(stringL("Haskell")) :: litE(int32L(98)) :: Nil)
 
def main(): String & Impure = 
   let ast = runQ(exp1());
   show(ppExp(10, ast))
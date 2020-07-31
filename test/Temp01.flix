use TemplateFlix/QuoteMonad.{runQ};
use TemplateFlix/Pretty.{ppExpression};
use TemplateFlix/PrettyLib.{show};
use TemplateFlix/Lib.{ExpressionQ};
use TemplateFlix/Lib.{tupleE, litE, stringL, int32L};

def exp1(): ExpressionQ = 
   tupleE(litE(stringL("Haskell")) :: litE(int32L(98)) :: Nil)
 
def main(): String & Impure = 
   let ast = runQ(exp1());
   show(ppExpression(10, ast))
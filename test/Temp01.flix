use TemplateFlix/QuoteMonad.{runQ};
use TemplateFlix/Pretty.{ppExpression, ppLiteral};
use TemplateFlix/PrettyLib.{show};
use TemplateFlix/Lib.{ExpressionQ};
use TemplateFlix/Lib.{tupleE, litE, stringL, int32L};
use TemplateFlix/Parser.{parses, pLiteral, pExpression};

def exp1(): ExpressionQ = 
   tupleE(litE(stringL("Haskell")) :: litE(int32L(98)) :: Nil)
 
def parse1(): Result[Unit, String] & Impure = 
   use Result.flatMap;
   let* ast = parses(pExpression(), "12000");
   let _ = Console.printLine(show(ppExpression(80, ast)));
   Ok()

def main(): Unit & Impure = 
   let _ = Console.printLine("go...");
   let ast1 = runQ(exp1());
   let _ = Console.printLine(show(ppExpression(80, ast1)));
   
   let _ = parse1();

   ()
module Main where

import Lib
import Eval
import Tokens
import Primitives
import FileExec
import Repl
import Env
import System.Environment
import FileExec
import Repl
import System.IO

isRepl :: [String] -> Bool
isRepl ["-i"]   = True
isRepl _        = False

main :: IO ()
main = do
    env <- primBind
    args <- getArgs
    if isRepl args then repl env else readFiles env args


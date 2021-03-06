module CombinedParsers where

import ParserLib
import Control.Applicative
import Data.Char
import Control.Monad

runParser :: Parser a -> String -> Maybe a
runParser p s = case parse p s of
    (Value _ a) -> Just a
    _           -> Nothing

hasOneOf :: String -> Parser Char
hasOneOf x = satisfy $ flip elem x

hasNoneOf :: String -> Parser Char
hasNoneOf x = satisfyNot $ flip elem x

satisfyNot :: (Char -> Bool) -> Parser Char
satisfyNot p = char >>= \c -> if p c then empty else pure c

letter :: Parser Char
letter = satisfy isAlpha

digit :: Parser Char
digit = satisfy isDigit

char :: Parser Char
char = Parser p
    where p []      = Error EOF
          p (x:xs)  = Value xs x

end :: Parser a -> Parser b -> Parser [a]
end a s = many' $ a >>= \ res -> s >> return res
    where   many' p = liftM2 (:) p (many'' p)
            many'' p = many' p <|> return []

sep :: Parser a -> Parser s -> Parser [a]
sep p s = isSepBy p s <|> return []
    where isSepBy p s = liftM2 (:) p (many (s >> p))

has :: Char -> Parser Char
has c = satisfy (c==)

satisfy :: (Char -> Bool) -> Parser Char
satisfy p = char >>= \c -> if p c then pure c else empty

with :: String -> Parser String
with = traverse has

between :: Parser o -> Parser a -> Parser c -> Parser a
between open p close = open >> (p >>= \res -> close >> return res)

spaces :: Parser String
spaces = many $ hasOneOf " \t\r\n"

select :: String -> Parser String
select s = selected $ with s
    where selected p = p >>= \a -> spaces >> return a

combine :: Parser a -> Parser (a -> a -> a) -> Parser a
p `combine` op = p >>= \x -> rest x
    where rest x = (op >>= \f -> p >>= \y -> rest $ f x y) <|> return x


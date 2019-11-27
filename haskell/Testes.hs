module Testes
where
import Controller
import Test.HUnit
import ParserJson
import Tipos
import Data.List (groupBy)
import Test.QuickCheck

result = 92274.23
calcula = calculaCredito 2017 3
nome = "ovo"
teste x = result == (4)

main = do
    quickCheck (teste :: [Int] -> Bool)

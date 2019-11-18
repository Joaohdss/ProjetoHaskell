module ParserJson
(
    getJSON,
    getTransations
) where

import qualified Data.ByteString.Lazy as B  
import Data.Aeson
import Data.Maybe
import Tipos

jsonFile :: FilePath
jsonFile = "bd/transacoes.json"

getJSON :: IO B.ByteString
getJSON = B.readFile jsonFile

getTransations :: IO [Transacao]
getTransations = do
    transations <- (decode <$> getJSON) :: IO (Maybe [Transacao])
    return (fromJust transations)

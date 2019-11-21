{-# LANGUAGE DeriveGeneric #-}
module Tipos 
(
    Transacao (..),
    GregorianCalendar (..)
) where

import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B  

data GregorianCalendar = 
    GregorianCalendar { 
        year :: Int,
        month :: Int,
        dayOfMonth :: Int
    } deriving (Show, Generic)

data Transacao = 
    Transacao {
        datas :: GregorianCalendar,
        textoIdentificador :: String,
        valor :: Double,
        descricao :: String,
        numeroDOC :: String,
        tipos :: [String]
    } deriving (Show, Generic)

instance FromJSON GregorianCalendar
instance ToJSON GregorianCalendar

instance FromJSON Transacao
instance ToJSON Transacao

-- instance FromJSON TipoTransacao
-- instance ToJSON TipoTransacao

instance Eq Transacao where
    Transacao _ id1 _ _ _ _ == Transacao _ id2 _ _ _ _  = id1 == id2
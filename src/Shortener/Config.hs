{-# LANGUAGE OverloadedStrings #-}

module Shortener.Config
    ( readConfig
    , Config(..)
    ) where

import qualified Data.Configurator as C

data Config = Config
  { cPort :: Int
  } deriving (Show, Eq)

readConfig :: FilePath -> IO Config
readConfig cfgFile = do
    cfg  <- C.load [C.Required cfgFile]
    port <- C.require cfg "port"
    return $ Config port
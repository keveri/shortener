{-# LANGUAGE OverloadedStrings #-}

module Shortener.Config
    ( readConfig
    , Config(..)
    , DbConfig(..)
    ) where

import qualified Data.Configurator       as C
import qualified Data.Configurator.Types as T

data Config = Config
  { cPort     :: Int
  , cDbConfig :: DbConfig
  } deriving (Show, Eq)

data DbConfig = DbConfig
  { dbHost :: String
  , dbPort :: Int
  , dbUser :: String
  , dbPass :: String
  , dbName :: String
  } deriving (Show, Eq)

readConfig :: FilePath -> IO Config
readConfig cfgFile = do
    cfg  <- C.load [C.Required cfgFile]
    port <- C.require cfg "port"
    db   <- parseDB cfg
    return $ Config port db

parseDB :: T.Config -> IO DbConfig
parseDB cfg = do
    host <- C.require cfg "db.host"
    port <- C.require cfg "db.port"
    user <- C.require cfg "db.user"
    pass <- C.require cfg "db.pass"
    name <- C.require cfg "db.name"
    return $ DbConfig host port user pass name

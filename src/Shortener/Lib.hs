{-# LANGUAGE OverloadedStrings #-}

module Shortener.Lib
    ( startApp
    , app
    , Env(..)
    ) where

import           Control.Monad.IO.Class      (liftIO)
import           Data.Int                    (Int64)
import           Data.Text
import           Database.Persist.Postgresql (ConnectionString)
import           Network.Wai.Handler.Warp
import           Network.Wai.Logger          (withStdoutLogger)
import           Servant
import           Text.StringRandom

import           Database.Persist            (Entity)
import           Shortener.Api
import           Shortener.Config
import           Shortener.Database
import           Shortener.Schema

newtype Env = Env
  { envConnectionString :: ConnectionString
  }

startApp :: Config -> Env -> IO ()
startApp config env = withStdoutLogger $ \aplogger -> do
        let port = cPort config
            settings = setPort port $ setLogger aplogger defaultSettings
        runSettings settings (app env)

app :: Env -> Application
app = serve api . server

server :: Env -> Server API
server env =
  let connStr = envConnectionString env
  in shortUrlByToken connStr :<|> createShortUrl connStr

randomToken :: IO Text
randomToken = stringRandomIO "[a-zA-Z]{6}"

shortUrlByToken :: ConnectionString -> Text -> Handler ShortUrl
shortUrlByToken connStr token = do
  result <- liftIO $ findUrlPG connStr token
  case result of
    Just r  -> return r
    Nothing -> throwError err404

createShortUrl :: ConnectionString -> OriginalUrl -> Handler ShortUrl
createShortUrl connStr ou@(OriginalUrl url) = do
  token <- liftIO randomToken
  mShortUrl <- liftIO $ createShortUrlPG connStr $ ShortUrl url token
  case mShortUrl of
      Nothing -> createShortUrl connStr ou
      Just r  -> return r

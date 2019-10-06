{-# LANGUAGE LambdaCase #-}

module Shortener.Lib
    ( startApp
    , app
    ) where

import Network.Wai.Handler.Warp
import Servant

import Shortener.Api

startApp :: IO ()
startApp = run 8080 app

app :: Application
app = serve api server

server :: Server API
server = shortUrlById :<|> createShortUrl

shortUrlById :: Id -> Handler ShortUrl
shortUrlById = \ case
  "abc" -> return exampleShortUrl
  _     -> throwError err404

createShortUrl :: OriginalUrl -> Handler ShortUrl
createShortUrl (OriginalUrl url) = return $ ShortUrl url "short_url"

exampleShortUrl :: ShortUrl
exampleShortUrl = ShortUrl "original_url" "short_url"
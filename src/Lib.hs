{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
module Lib
    ( startApp
    , app
    ) where

import Data.Aeson
import Data.Aeson.TH
import Network.Wai
import Network.Wai.Handler.Warp
import Servant

type Url = String

data ShortUrl = ShortUrl
  { originalUrl  :: Url
  , shortenedUrl :: Url
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''ShortUrl)

type API = "short" :> Get '[JSON] ShortUrl

startApp :: IO ()
startApp = run 8080 app

app :: Application
app = serve api server

api :: Proxy API
api = Proxy

server :: Server API
server = return testData

testData :: ShortUrl
testData = ShortUrl "original_url" "short_url"

{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE LambdaCase      #-}
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
type Id = String

data OriginalUrl = OriginalUrl { url :: Url } deriving (Eq, Show)

data ShortUrl = ShortUrl
  { originalUrl  :: Url
  , shortenedUrl :: Url
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''OriginalUrl)
$(deriveJSON defaultOptions ''ShortUrl)

type API = "short" :> Capture "id" Id :> Get '[JSON] ShortUrl
      :<|> "short" :> ReqBody '[JSON] OriginalUrl :> Post '[JSON] ShortUrl

startApp :: IO ()
startApp = run 8080 app

app :: Application
app = serve api server

api :: Proxy API
api = Proxy

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
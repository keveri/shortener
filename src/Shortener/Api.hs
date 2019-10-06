{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}

module Shortener.Api
    ( api
    , API
    , OriginalUrl(..)
    , ShortUrl(..)
    , Id
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

api :: Proxy API
api = Proxy
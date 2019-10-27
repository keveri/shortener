{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}

module Shortener.Api
    ( api
    , jsonApi
    , API
    , JSONAPI
    , OriginalUrl(..)
    ) where

import           Data.Aeson
import           Data.Aeson.TH
import           Data.Text
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Servant

import           Shortener.Schema

type Url = Text

newtype OriginalUrl = OriginalUrl { url :: Url } deriving (Eq, Show)

$(deriveJSON defaultOptions ''OriginalUrl)

type JSONAPI = "short" :> Capture "token" Text :> Get '[JSON] ShortUrl
          :<|> "short" :> ReqBody '[JSON] OriginalUrl :> Post '[JSON] ShortUrl

-- TODO: How to combine JSONAPI and Raw without repeating it here
type API = "short" :> Capture "token" Text :> Get '[JSON] ShortUrl
          :<|> "short" :> ReqBody '[JSON] OriginalUrl :> Post '[JSON] ShortUrl
          :<|> Raw

jsonApi :: Proxy JSONAPI
jsonApi = Proxy

api :: Proxy API
api = Proxy

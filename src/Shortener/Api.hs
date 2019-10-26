{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}

module Shortener.Api
    ( api
    , API
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

type API = "short" :> Capture "token" Text :> Get '[JSON] ShortUrl
      :<|> "short" :> ReqBody '[JSON] OriginalUrl :> Post '[JSON] ShortUrl

api :: Proxy API
api = Proxy

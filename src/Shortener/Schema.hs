{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Shortener.Schema where

import           Data.Aeson
import           Data.Text
import           Database.Persist.TH

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
ShortUrl
  url Text
  token Text
  UniqueToken token
  deriving Eq Read Show
|]

instance FromJSON ShortUrl where
  parseJSON = withObject "ShortUrl" $ \ v ->
    ShortUrl <$> v .: "url"
             <*> v .: "token"

instance ToJSON ShortUrl where
  toJSON (ShortUrl url token) =
    object [ "url"    .= url
           , "token"  .= token  ]

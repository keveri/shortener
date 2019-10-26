{-# LANGUAGE OverloadedStrings #-}

module Shortener.Token
    (randomToken
    ) where

import           Data.Text
import           Text.StringRandom

randomToken :: IO Text
randomToken = stringRandomIO "[a-zA-Z]{6}"

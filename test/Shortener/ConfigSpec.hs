{-# LANGUAGE OverloadedStrings #-}

module Shortener.ConfigSpec
  ( main
  , spec
  ) where

import           Test.Hspec

import           Shortener.Config

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "readAppConfig" $ do
    it "reads valid config file" $ do
      let port = 8081
      conf <- readConfig "test/fixtures/config/valid.cfg"
      cPort conf `shouldBe` port
    it "fails to read invalid config file" $ do
      let path = "test/fixtures/config/invalid.cfg"
      readConfig path `shouldThrow` anyException

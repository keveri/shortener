{-# LANGUAGE OverloadedStrings #-}

module Shortener.ConfigSpec
  ( main
  , spec
  ) where

import Test.Hspec

import Shortener.Config

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "readAppConfig" $ do
    it "reads valid config file" $ do
      let valid = Config 1234
      conf <- readConfig "test/fixtures/config/valid.cfg"
      conf `shouldBe` valid
    it "fails to read invalid config file" $ do
      let path = "test/fixtures/config/invalid.cfg"
      readConfig path `shouldThrow` anyException
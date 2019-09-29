{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Lib (app)
import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON

main :: IO ()
main = hspec spec

spec :: Spec
spec = with (return app) $ do
    describe "GET /short" $ do
        it "responds with 200" $ do
            get "/short/abc" `shouldRespondWith` 200
        it "responds with ShortUrl" $ do
            let testData = "{\"originalUrl\":\"original_url\",\"shortenedUrl\":\"short_url\"}"
            get "/short/abc" `shouldRespondWith` testData
        it "responds with 404 if the short URL does'n exist" $ do
            get "/short/nonexisting" `shouldRespondWith` 404

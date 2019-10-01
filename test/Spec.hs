{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Lib (app)
import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON
import Network.HTTP.Types (methodPost)
import Network.Wai.Test (SResponse)
import Data.ByteString
import qualified Data.ByteString.Lazy as LB

postJson :: ByteString -> LB.ByteString -> WaiSession SResponse
postJson path = request methodPost path headers
    where headers =  [("Content-Type", "application/json")]

main :: IO ()
main = hspec spec

spec :: Spec
spec = with (return app) $ do
    describe "GET /short/:id" $ do
        it "responds with 200" $ do
            get "/short/abc" `shouldRespondWith` 200
        it "responds with ShortUrl" $ do
            let testData = [json|{originalUrl: "original_url", shortenedUrl: "short_url"}|]
            get "/short/abc" `shouldRespondWith` testData
        it "responds with 404 if the short URL does'n exist" $ do
            get "/short/nonexisting" `shouldRespondWith` 404
    describe "POST /short" $ do
        let urlData = [json|{url: "orig"}|]
        it "responds with 200" $ do
            postJson "/short" urlData  `shouldRespondWith` 200
        it "responds with short URL data" $ do
            let shortUrlData = [json|{originalUrl: "orig", shortenedUrl: "short_url"}|]
            postJson "/short" urlData  `shouldRespondWith` shortUrlData
        it "responds with 400 with invalid data" $ do
            let invalidData = [json|{invalid: "will_fail"}|]
            postJson "/short" invalidData  `shouldRespondWith` 400

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Shortener.AppSpec
    ( main
    , spec
    ) where

import           Control.Monad.IO.Class (liftIO)
import           Control.Monad          (void)
import           Data.ByteString
import qualified Data.ByteString.Lazy   as LB
import           Network.HTTP.Types     (methodPost)
import           Network.Wai.Test       (SResponse)
import           Test.Hspec
import           Test.Hspec.Wai
import           Test.Hspec.Wai.JSON

import           Shortener.Database     (createShortUrlPG, resetDB)
import           Shortener.Lib          (Env (..), app)
import           Shortener.Schema

postJson :: ByteString -> LB.ByteString -> WaiSession SResponse
postJson path = request methodPost path headers
    where headers =  [("Content-Type", "application/json")]

insertShortUrl :: ShortUrl -> IO (Maybe ShortUrl)
insertShortUrl = createShortUrlPG (envConnectionString testEnv)

testEnv :: Env
testEnv = Env "host=127.0.0.1 port=54320 user=test dbname=shortener-test password=test"

testSetup :: Env -> IO()
testSetup (Env connStr) = resetDB connStr

insertTestUrl :: IO ()
insertTestUrl = void $ insertShortUrl $ ShortUrl "test-url" "test-token"

main :: IO ()
main = hspec spec

spec :: Spec
spec = before (testSetup testEnv) $ with (return $ app testEnv) $ do
    describe "GET /short/:id" $ do
        it "responds with 200" $ do
            liftIO insertTestUrl
            get "/short/test-token" `shouldRespondWith` 200
        it "responds with ShortUrl" $ do
            let testData = [json|{url: "test-url", token: "test-token"}|]
            liftIO insertTestUrl
            get "/short/test-token" `shouldRespondWith` testData
        it "responds with 404 if the short URL does'n exist" $
            get "/short/nonexisting" `shouldRespondWith` 404
    describe "POST /short" $ do
        let urlData = [json|{url: "url"}|]
        it "responds with 200" $
            postJson "/short" urlData  `shouldRespondWith` 200
        it "responds with 400 with invalid data" $ do
            let invalidData = [json|{invalid: "will_fail"}|]
            postJson "/short" invalidData  `shouldRespondWith` 400

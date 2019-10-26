module Shortener.Lib
    ( startApp
    , app
    , Env(..)
    ) where

import           Control.Monad.IO.Class      (liftIO)
import           Data.Int                    (Int64)
import           Data.Text
import           Database.Persist.Postgresql (ConnectionString)
import           Network.Wai.Handler.Warp
import           Network.Wai.Logger          (withStdoutLogger)
import           Servant

import           Database.Persist            (Entity)
import           Shortener.Api
import           Shortener.Config
import           Shortener.Database
import           Shortener.Schema
import           Shortener.Token             (randomToken)

type TokenGenerator = IO Text

data Env = Env
  { envConnStr  :: ConnectionString
  , envTokenGen :: TokenGenerator
  }

startApp :: Config -> Env -> IO ()
startApp config env = withStdoutLogger $ \aplogger -> do
        let port = cPort config
            settings = setPort port $ setLogger aplogger defaultSettings
        runSettings settings (app env)

app :: Env -> Application
app = serve api . server

server :: Env -> Server API
server env = shortUrlByToken env :<|> createShortUrl env

shortUrlByToken :: Env -> Text -> Handler ShortUrl
shortUrlByToken (Env cStr _) token = do
  result <- liftIO $ findUrlPG cStr token
  case result of
    Just r  -> return r
    Nothing -> throwError err404

createShortUrl :: Env -> OriginalUrl -> Handler ShortUrl
createShortUrl e@(Env cStr tGen) ou@(OriginalUrl url) = do
  token <- liftIO tGen
  mShortUrl <- liftIO $ createShortUrlPG cStr $ ShortUrl url token
  case mShortUrl of
      Nothing -> createShortUrl e ou
      Just r  -> return r

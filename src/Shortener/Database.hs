{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Shortener.Database
    ( fetchConnectionString
    , migrateDB
    , resetDB
    , findUrlPG
    , createShortUrlPG
    ) where

import           Control.Monad.IO.Class      (MonadIO)
import           Control.Monad.Logger        (LoggingT, MonadLogger,
                                              runStdoutLoggingT)
import           Control.Monad.Reader        (runReaderT)
import qualified Data.ByteString.Char8       as B
import           Data.Int                    (Int64)
import           Data.Monoid                 ((<>))
import           Data.String.Interpolate
import           Data.Text
import           Database.Persist            (SelectOpt (..), entityVal, get,
                                              insertBy, checkUnique, selectList, (==.))
import           Database.Persist.Postgresql (ConnectionString, SqlPersistT,
                                              runMigration, withPostgresqlConn)
import           Database.Persist.Sql        (fromSqlKey, rawExecute,
                                              selectFirst, toSqlKey)

import           Shortener.Config            (DbConfig (..))
import           Shortener.Schema

fetchConnectionString :: DbConfig -> ConnectionString
fetchConnectionString (DbConfig host port user pass name) =
    B.pack [i|host=#{host} dbname=#{name} user=#{user} password=#{pass} port=#{port}|]

runAction :: ConnectionString -> SqlPersistT (LoggingT IO) a -> IO a
runAction connectionString action =
  runStdoutLoggingT $ withPostgresqlConn connectionString $ \backend ->
    runReaderT action backend

migrateDB :: ConnectionString -> IO ()
migrateDB connString = runAction connString $ runMigration migrateAll

resetDB :: ConnectionString -> IO ()
resetDB connString = runAction connString $ do
    rawExecute "DROP TABLE IF EXISTS short_url" []
    rawExecute "DROP TABLE IF EXISTS short_url_id_seq" []
    runMigration migrateAll

findUrlPG :: ConnectionString -> Text -> IO (Maybe ShortUrl)
findUrlPG connStr token = runAction connStr $ do
    mShortUrl <- selectFirst [ShortUrlToken ==. token] []
    return $ entityVal <$> mShortUrl

createShortUrlPG :: ConnectionString -> ShortUrl -> IO (Maybe ShortUrl)
createShortUrlPG connStr shortUrl = runAction connStr $ do
    e <- insertBy shortUrl
    case e of
        Left _ -> return Nothing
        Right key -> get key

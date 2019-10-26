module Main where

import           Shortener.Config
import           Shortener.Database
import           Shortener.Lib
import           Shortener.Token    (randomToken)

main :: IO ()
main = do
  config <- readConfig "app.cfg"
  let connectionString = fetchConnectionString (cDbConfig config)
      env = Env connectionString randomToken
  migrateDB connectionString
  startApp config env

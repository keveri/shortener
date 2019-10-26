module Main where

import           Shortener.Config
import           Shortener.Database
import           Shortener.Lib

main :: IO ()
main = do
  config <- readConfig "app.cfg"
  let connectionString = fetchConnectionString (cDbConfig config)
      env = Env connectionString
  migrateDB connectionString
  startApp config env

module Main where

import Shortener.Config
import Shortener.Lib

main :: IO ()
main = do
    config <- readConfig "app.cfg"
    startApp config

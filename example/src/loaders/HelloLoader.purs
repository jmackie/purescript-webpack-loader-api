module HelloLoader (loader) where

import Prelude

import Data.Either (Either(Left, Right))
import Debug.Trace (spy)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Webpack.Loader as Webpack


loader :: Webpack.Loader
loader = Webpack.mkAsyncLoader \ctx _buffer -> liftEffect do
    Console.info "resourcePath:"
    Console.log (Webpack.resourcePath ctx)
    case Webpack.query ctx of
         Left str -> Console.info ("query: " <> str)
         Right obj -> pure (spy "query" obj) $> unit
    output <- Buffer.fromString "hello" Encoding.UTF8
    pure { source: output }

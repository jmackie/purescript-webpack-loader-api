module HelloLoader (loader) where

import Prelude

import Effect.Console as Console
import Effect.Class (liftEffect)
import Webpack.Loader as Webpack
import Node.Buffer as Buffer
import Node.Encoding as Encoding


loader :: Webpack.Loader
loader = Webpack.mkAsyncLoader \ctx _buffer -> liftEffect do
    Console.info "resourcePath:"
    Console.log (Webpack.resourcePath ctx)
    output <- Buffer.fromString "hello" Encoding.UTF8
    pure { source: output }

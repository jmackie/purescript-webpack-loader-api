module Webpack.Loader
    ( Loader
    , mkSyncLoader
    , mkAsyncLoader
    , LoaderContext
    , version
    , context
    , rootContext
    , request
    , query
    , cacheable
    , loaderIndex
    , addDependency
    , addContextDependency
    , resourcePath
    )
where

import Prelude

import Control.Monad.Except (runExcept)
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Array as Array
import Data.Either (Either(Left, Right))
import Data.Foldable (intercalate)
import Data.Tuple (Tuple(Tuple))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (runEffectFn1, EffectFn2, mkEffectFn2)
import Foreign (Foreign, F, unsafeToForeign, unsafeFromForeign)
import Foreign as Foreign
import Foreign.Index as ForeignIndex
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Buffer (Buffer) as Node
import Node.Path (FilePath) as Node
import Partial.Unsafe (unsafeCrashWith)


-- | A webpack loader. It exists only in javascript land.
data Loader


-- | The return type of a webpack `Loader`.
type Result =
    { source :: Node.Buffer
    }


-- | Create a synchronous loader.
-- |
-- | https://webpack.js.org/api/loaders/#synchronous-loaders
mkSyncLoader :: (LoaderContext -> Node.Buffer -> Effect Result) -> Loader
mkSyncLoader f =
    mkSyncLoaderImpl (resultToObject >>> unsafeToForeign) (mkEffectFn2 f)


-- | Create an asynchronous loader.
-- |
-- | https://webpack.js.org/api/loaders/#asynchronous-loaders
mkAsyncLoader :: (LoaderContext -> Node.Buffer -> Aff Result) -> Loader
mkAsyncLoader f =
    mkAsyncLoaderImpl (resultToObject >>> unsafeToForeign)
        (mkEffectFn2 \loaderContext source -> Promise.fromAff (f loaderContext source))


-- | Process a `Result` to something we can use over in javascript land.
resultToObject :: Result -> Object Foreign
resultToObject result = Object.fromFoldable
    [ Tuple "source" (unsafeToForeign result.source) ]


foreign import mkSyncLoaderImpl
    :: (Result -> Foreign)
    -> EffectFn2 LoaderContext Node.Buffer Result
    -> Loader


foreign import mkAsyncLoaderImpl
    :: (Result -> Foreign)
    -> EffectFn2 LoaderContext Node.Buffer (Promise Result)
    -> Loader


-- | https://webpack.js.org/api/loaders/#the-loader-context
data LoaderContext = LoaderContext


-- | https://webpack.js.org/api/loaders/#this-version
version :: LoaderContext -> Int
version = unsafeReadLoaderContext
    (ForeignIndex.readProp "version" >=> Foreign.readInt)
    "Bad version"


-- | https://webpack.js.org/api/loaders/#this-context
context :: LoaderContext -> Node.FilePath
context = unsafeReadLoaderContext
    (ForeignIndex.readProp "context" >=> Foreign.readString)
    "Bad context"


-- | https://webpack.js.org/api/loaders/#this-rootcontext
rootContext :: LoaderContext -> Node.FilePath
rootContext = unsafeReadLoaderContext
    (ForeignIndex.readProp "rootContext" >=> Foreign.readString)
    "Bad rootContext"


-- | https://webpack.js.org/api/loaders/#this-request
request :: LoaderContext -> String
request = unsafeReadLoaderContext
    (ForeignIndex.readProp "request" >=> Foreign.readString)
    "Bad request"


-- | https://webpack.js.org/api/loaders/#this-query
query :: LoaderContext -> Either String (Object Foreign)
query = unsafeReadLoaderContext
    (ForeignIndex.readProp "query" >=> readQuery)
    "Bad query"
  where
    readQuery :: Foreign -> F (Either String (Object Foreign))
    readQuery value =
        case Foreign.typeOf value of
             "string" ->
                Left <$> Foreign.readString value

             "object" ->
                pure (Right (unsafeFromForeign value))

             other    ->
                 Foreign.fail <<< Foreign.ForeignError $
                     "Expecting a string or an object, got " <> other


-- | https://webpack.js.org/api/loaders/#this-cacheable
cacheable :: Boolean -> LoaderContext -> Effect Unit
cacheable flag loaderContext =
    runEffectFn1
        (unsafeReadLoaderContext
            (ForeignIndex.readProp "cacheable" >=> readFunction)
            "Couldn't set cacheable flag"
            loaderContext
        )
        flag


-- | https://webpack.js.org/api/loaders/#this-loaderindex
loaderIndex :: LoaderContext -> Int
loaderIndex = unsafeReadLoaderContext
    (ForeignIndex.readProp "loaderIndex" >=> Foreign.readInt)
    "Bad loaderIndex"


-- | https://webpack.js.org/api/loaders/#this-resourcepath
resourcePath :: LoaderContext -> Node.FilePath
resourcePath = unsafeReadLoaderContext
    (ForeignIndex.readProp "resourcePath" >=> Foreign.readString)
    "Bad resourcePath"


-- | https://webpack.js.org/api/loaders/#this-adddependency
addDependency :: Node.FilePath -> LoaderContext -> Effect Unit
addDependency file loaderContext =
    runEffectFn1
        (unsafeReadLoaderContext
            (ForeignIndex.readProp "addDependency" >=> readFunction)
            "Couldn't add dependency"
            loaderContext
        )
        file


-- | https://webpack.js.org/api/loaders/#this-adddependency
addContextDependency :: Node.FilePath -> LoaderContext -> Effect Unit
addContextDependency directory loaderContext =
    runEffectFn1
        (unsafeReadLoaderContext
            (ForeignIndex.readProp "addContextDependency" >=> readFunction)
            "Couldn't add context dependency"
            loaderContext
        )
        directory


-- UTIL


readFunction :: forall a. Foreign -> F a
readFunction value =
    case Foreign.typeOf value of
         "function" -> pure (unsafeFromForeign value)
         other      -> Foreign.fail (Foreign.TypeMismatch "function" other)


readLoaderContext :: forall a. (Foreign -> F a) -> LoaderContext -> Either Foreign.MultipleErrors a
readLoaderContext reader = runExcept <<< reader <<< unsafeToForeign


unsafeReadLoaderContext :: forall a. (Foreign -> F a) -> String -> LoaderContext -> a
unsafeReadLoaderContext reader errorPrefix loaderContext =
    case readLoaderContext reader loaderContext of
         Right a -> a

         -- Crash with a helpful error
         Left multipleErrors ->
             unsafeCrashWith <<< intercalate ": " $
                 [ "unsafeReadLoaderContext"
                 , errorPrefix
                 ] <>
                 Array.fromFoldable (map Foreign.renderForeignError multipleErrors)

## Module Webpack.Loader

#### `Loader`

``` purescript
data Loader
```

A webpack loader. It exists only in javascript land.

#### `mkSyncLoader`

``` purescript
mkSyncLoader :: (LoaderContext -> Buffer -> Effect Result) -> Loader
```

Create a synchronous loader.

https://webpack.js.org/api/loaders/#synchronous-loaders

#### `mkAsyncLoader`

``` purescript
mkAsyncLoader :: (LoaderContext -> Buffer -> Aff Result) -> Loader
```

Create an asynchronous loader.

https://webpack.js.org/api/loaders/#asynchronous-loaders

#### `Result`

``` purescript
type Result = { source :: Buffer }
```

The return type of a webpack `Loader`.

#### `LoaderContext`

``` purescript
data LoaderContext
```

https://webpack.js.org/api/loaders/#the-loader-context

#### `version`

``` purescript
version :: LoaderContext -> Int
```

https://webpack.js.org/api/loaders/#this-version

#### `context`

``` purescript
context :: LoaderContext -> FilePath
```

https://webpack.js.org/api/loaders/#this-context

#### `rootContext`

``` purescript
rootContext :: LoaderContext -> FilePath
```

https://webpack.js.org/api/loaders/#this-rootcontext

#### `request`

``` purescript
request :: LoaderContext -> String
```

https://webpack.js.org/api/loaders/#this-request

#### `query`

``` purescript
query :: LoaderContext -> Either String (Object Foreign)
```

https://webpack.js.org/api/loaders/#this-query

#### `cacheable`

``` purescript
cacheable :: Boolean -> LoaderContext -> Effect Unit
```

https://webpack.js.org/api/loaders/#this-cacheable

#### `loaderIndex`

``` purescript
loaderIndex :: LoaderContext -> Int
```

https://webpack.js.org/api/loaders/#this-loaderindex

#### `addDependency`

``` purescript
addDependency :: FilePath -> LoaderContext -> Effect Unit
```

https://webpack.js.org/api/loaders/#this-adddependency

#### `addContextDependency`

``` purescript
addContextDependency :: FilePath -> LoaderContext -> Effect Unit
```

https://webpack.js.org/api/loaders/#this-adddependency

#### `resourcePath`

``` purescript
resourcePath :: LoaderContext -> FilePath
```

https://webpack.js.org/api/loaders/#this-resourcepath



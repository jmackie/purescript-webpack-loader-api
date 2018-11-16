'use-strict';

exports.mkSyncLoaderImpl = function(translateResult) {
    return function(purescriptLoader) {
        var loader = function(source) {
            var purescriptResult = purescriptLoader(this, source);
            var result = translateResult(purescriptResult);
            return result.source;
        };
        loader.raw = true;
        return loader;
    };
};

exports.mkAsyncLoaderImpl = function(translateResult) {
    return function(purescriptLoader) {
        var loader = function(source) {
            var callback = this.async();
            purescriptLoader(this, source).then(
                function(purescriptResult) {
                    var result = translateResult(purescriptResult);
                    callback(null, result.source);
                },
                function(error) {
                    callback(error);
                }
            );
        };
        loader.raw = true;
        return loader;
    };
};

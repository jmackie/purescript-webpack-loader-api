var path = require('path');

module.exports = {
    entry: {
        bundle: path.join(__dirname, './src/js/index.js'),
    },
    output: {
        path: path.join(__dirname, 'dist'),
        filename: '[name].[chunkhash].js',
    },
    resolveLoader: {
        modules: ['node_modules', path.resolve(__dirname, './src/loaders')],
    },
    module: {
        rules: [
            {
                test: /\.(js)$/,
                use: [
                    {
                        loader: 'hello-loader',
                        options: { debug: true },
                    },
                ],
                exclude: /(node_modules)/,
            },
        ],
    },
};

const path              = require( 'path' );
const webpack           = require( 'webpack' );
const merge             = require( 'webpack-merge' );
const HtmlWebpackPlugin = require( 'html-webpack-plugin' );
const autoprefixer      = require( 'autoprefixer' );
const ExtractTextPlugin = require( 'extract-text-webpack-plugin' );
const CopyWebpackPlugin = require( 'copy-webpack-plugin' );
const ScriptExtHtmlWebpackPlugin
                      = require( 'script-ext-html-webpack-plugin' );

const prod = 'production';
const dev = 'development';

// determine build env
const TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? prod : dev;
const isDev = TARGET_ENV == dev;
const isProd = TARGET_ENV == prod;

// set entry and output path/filename
const entryPath = path.join(__dirname, 'src/static/index.js');
const outputPath = path.join(__dirname, 'dist');
const outputFilename = isProd ? '[name]-[chunkhash].js' : '[name].js'

// extract css into files
const extractMDL = new ExtractTextPlugin("static/css/mdl-[contenthash].css");
const extractCSS = new ExtractTextPlugin({
  filename: "static/css/[name]-[contenthash].css",
  allChunks: true,
  disable: isDev === true
});

// debug: true
const elmLoaderOptions = isDev ? { verbose: true, warn: true } : {}

console.log('webpack is running...');

// Common webpack config (development and production)
var commonConfig = {

  entry: {
    vendor: [
      "./src/static/js/vendor/d3.custom.min",
      "./src/static/js/vendor/d3.layout.cloud.min",
      "./src/static/js/vendor/dialog-polyfill-0.4.9.min",
      "./src/static/js/vendor/leaflet-1.2.0.min",
      "./src/static/js/vendor/prunecluster-2.1.0.min",
      "./src/static/js/vendor/leaflet.fullscreen-1.0.1.min",
    ],
  },

  output: {
    path:       outputPath,
    filename: `static/js/${outputFilename}`,
    publicPath: '/'
  },

  resolve: {
    extensions: ['.js', '.elm'],
    modules: ['node_modules']
  },

  module: {
    noParse: [/\.elm$/, /src\/static\/js\/vendor/],
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [{
          loader: 'elm-webpack-loader',
          options: elmLoaderOptions
        }]
      },
      {
        test: /\.(png|jpg|gif|svg|eot|ttf|woff|woff2)$/,
        use: [{
          loader: 'url-loader',
          options: {
            limit: 10000
          }
        }]
      },
      {
        test: /\.scss$/,
        use: extractCSS.extract({
          // Adds CSS to the DOM by injecting a <style> tag
          fallback: 'style-loader',
          use: [
            // interprets @import and url() like import/require() and will resolve them.
            { loader: 'css-loader', options: { minimize: true } },
            // process CSS with PostCSS
            'postcss-loader',
            // compiles Sass to CSS
            'sass-loader'
          ]
        })
      },
      {
        test: /\mdl.min.css$/,
        use: extractMDL.extract({
          fallback: "style-loader",
          use: "css-loader"
        })
      }
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: 'src/static/index.html',
      inject:   'body',
      filename: 'index.html',
      chunksSortMode: 'dependency',
    }),

    new CopyWebpackPlugin([
      { from: 'src/static/favicons' },
    ]),

    new webpack.optimize.CommonsChunkPlugin({
      name: ['vendor'],
      minChunks: Infinity
    }),

    new webpack.optimize.CommonsChunkPlugin({
      name: ['manifest']
    }),

    new webpack.LoaderOptionsPlugin({
      options: {
        postcss: [autoprefixer()]
      }
    }),

    extractMDL,

    extractCSS
  ],
}

// Development config
if ( isDev ) {
  console.log('Development build');

  module.exports = merge( commonConfig, {

    entry: {
      app: [
        'webpack-dev-server/client?http://localhost:8080',
        entryPath
      ]
    },

    devServer: {
      // Serve index.html in place of 404 responses,
      historyApiFallback: true,
      contentBase: './src',
      hot: true
    }
  });
}

// Production config
if ( isProd ) {
  console.log('Production build');

  module.exports = merge( commonConfig, {

    entry: {
      app: entryPath
    },

    plugins: [
      new CopyWebpackPlugin([
        {
          from: 'src/static/img/',
          to:   'static/img/'
        },
      ]),

      new ScriptExtHtmlWebpackPlugin({
        inline: /manifest/,
        defaultAttribute: 'defer'
      }),

      new webpack.optimize.UglifyJsPlugin()
    ]
  });
}

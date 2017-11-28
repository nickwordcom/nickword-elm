var path              = require( 'path' );
var webpack           = require( 'webpack' );
var merge             = require( 'webpack-merge' );
var HtmlWebpackPlugin = require( 'html-webpack-plugin' );
var autoprefixer      = require( 'autoprefixer' );
var ExtractTextPlugin = require( 'extract-text-webpack-plugin' );
var CopyWebpackPlugin = require( 'copy-webpack-plugin' );
var InlineChunkWebpackPlugin
                      = require( 'html-webpack-inline-chunk-plugin' );
var entryPath         = path.join( __dirname, 'src/static/index.js' );
var outputPath        = path.join( __dirname, 'dist' );
var extractMDL = new ExtractTextPlugin( 'static/css/mdl-[contenthash].css' );
var extractCSS = new ExtractTextPlugin( 'static/css/[name]-[contenthash].css', { allChunks: true } );

// determine build env
var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';
var outputFilename = TARGET_ENV == 'production' ? '[name]-[chunkhash].js' : '[name].js'

console.log( 'WEBPACK GO!');

// common webpack config
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
    filename:   path.join( 'static/js/', outputFilename ),
    publicPath: '/'
  },

  resolve: {
    extensions: ['', '.js', '.elm']
  },

  module: {
    noParse: [/\.elm$/, /src\/static\/js\/vendor/],
    loaders: [
      {
        test: /\.(png|eot|ttf|woff|woff2|svg)$/,
        loader: 'url-loader?limit=100000'
      },
      {
        test: /\mdl.min.css$/,
        loader: extractMDL.extract( 'style-loader', [ 'css-loader' ])
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

    new webpack.optimize.CommonsChunkPlugin({
      name: ['vendor'],
      minChunks: Infinity
    }),

    new webpack.optimize.CommonsChunkPlugin({
      name: ['manifest']
    }),

    extractMDL
  ],

  postcss: [ autoprefixer( { browsers: ['last 2 versions'] } ) ],

}

// additional webpack settings for local env (when invoked by 'npm run start')
if ( TARGET_ENV === 'development' ) {
  console.log( 'Serving locally...');

  module.exports = merge( commonConfig, {

    entry: {
      app: [
        'webpack-dev-server/client?http://localhost:8080',
        entryPath
      ]
    },

    devServer: {
      // Serve index.html in place of 404 responses,
      // useful when routing without the hash.
      historyApiFallback: true,
    },

    module: {
      loaders: [
        {
          test:    /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          // add '&debug=true' ar the end for debugging mode
          loader:  'elm-hot!elm-webpack?verbose=true&warn=true'
        },
        {
          test: /\.scss$/,
          loaders: [
            'style-loader',
            'css-loader',
            'postcss-loader',
            'sass-loader'
          ]
        }
      ]
    }

  });
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if ( TARGET_ENV === 'production' ) {
  console.log( 'Building for prod...');

  module.exports = merge( commonConfig, {

    entry: {
      app: entryPath
    },

    module: {
      loaders: [
        {
          test:    /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader:  'elm-webpack'
        },
        {
          test: /\.scss$/,
          loader: extractCSS.extract( 'style-loader', [
            'css-loader',
            'postcss-loader',
            'sass-loader'
          ])
        }
      ]
    },

    plugins: [
      new CopyWebpackPlugin([
        {
          from: 'src/static/img/',
          to:   'static/img/'
        },
        { from: 'src/static/favicons' },
        { from: 'src/favicon.ico' },
        { from: 'src/favicon-16x16.png' },
        { from: 'src/favicon-32x32.png' },
        { from: 'src/static/_redirects' },
      ]),

      new webpack.optimize.OccurenceOrderPlugin(),

      extractCSS,

      new InlineChunkWebpackPlugin({
        inlineChunks: ['manifest']
      }),

      // minify & mangle JS/CSS
      new webpack.optimize.UglifyJsPlugin({
          minimize:   true,
          compressor: { warnings: false }
          // mangle:  true
      })
    ]

  });
}

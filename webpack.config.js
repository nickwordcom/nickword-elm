var path              = require( 'path' );
var webpack           = require( 'webpack' );
var merge             = require( 'webpack-merge' );
var HtmlWebpackPlugin = require( 'html-webpack-plugin' );
var autoprefixer      = require( 'autoprefixer' );
var ExtractTextPlugin = require( 'extract-text-webpack-plugin' );
var CopyWebpackPlugin = require( 'copy-webpack-plugin' );
var entryPath         = path.join( __dirname, 'src/static/index.js' );
var outputPath        = path.join( __dirname, 'dist' );

// determine build env
var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';
var outputFilename = TARGET_ENV == 'production' ? '[name]-[hash].js' : '[name].js'

console.log( 'WEBPACK GO!');

// common webpack config
var commonConfig = {

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
      }
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: 'src/static/index.html',
      inject:   'body',
      filename: 'index.html'
    })
  ],

  postcss: [ autoprefixer( { browsers: ['last 2 versions'] } ) ],

}

// additional webpack settings for local env (when invoked by 'npm run start')
if ( TARGET_ENV === 'development' ) {
  console.log( 'Serving locally...');

  module.exports = merge( commonConfig, {

    entry: [
      'webpack-dev-server/client?http://localhost:8080',
      entryPath
    ],

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
          test: /\.(css|scss)$/,
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

    entry: entryPath,

    module: {
      loaders: [
        {
          test:    /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader:  'elm-webpack'
        },
        {
          test: /\.(css|scss)$/,
          loader: ExtractTextPlugin.extract( 'style-loader', [
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

      // extract CSS into a separate file
      new ExtractTextPlugin( 'static/css/[name]-[hash].css', { allChunks: true } ),

      // minify & mangle JS/CSS
      new webpack.optimize.UglifyJsPlugin({
          minimize:   true,
          compressor: { warnings: false }
          // mangle:  true
      })
    ]

  });
}

const path = require("path");
const CopyPlugin = require("copy-webpack-plugin");

module.exports = {
  entry: "./src/Index.mjs",
  mode: "development",
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /(node_modules|bower_components)/,
        loader: "babel-loader",
        options: { presets: ["@babel/env"] }
      }
    ]
  },
  output: {
    path: path.resolve(__dirname, "dist/"),
    publicPath: "/dist/",
    filename: "bundle.js"
  },
  devServer: {
    static: {
      directory: path.resolve(__dirname, "public/"),
    },
    port: 3000,
    hot: "only",
    devMiddleware: {
      publicPath: "http://localhost:3000/dist/",
    },
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: "public", to: "" },
      ],
    }),
  ]
};

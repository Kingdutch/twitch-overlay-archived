let isDevelopment : bool = %raw(`process.env.NODE_ENV === "development"`)
let port : int = %raw(`process.env.PORT || 8080`)
let webpackPort : int = %raw(`process.env.WEBPACK_PORT`)
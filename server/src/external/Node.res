type headers = Js.Dict.t<string>

module ServerResponse = {
  type t

  @send external writeHead : (t, int, headers) => t = "writeHead"
  @send external end : (t) => () = "end"
  @send external endWith : (t, string) => () = "end"
}

module ClientRequest = {
  type t

  @send external end : t => () = "end"
  @send external endWith : (t, string) => () = "end"
}

module IncomingMessage = {
  type t

  @send external onData : (t, string, string => ()) => () = "on" 
  let onData = (request, callback) => request->onData("data", callback)

  @send external onEnd : (t, string, () => ()) => () = "on" 
  let onEnd = (request, callback) => request->onEnd("end", callback)

  @bs.get external statusCode : t => int = "statusCode"
  @bs.get external method : t => string = "method"
  @bs.get external url : t => string = "url"
  @bs.get external headers : t => headers = "headers"

  type pipeOptions = { end: bool }
  @send external pipeToResponse : (t, ServerResponse.t, pipeOptions) => () = "pipe"
  @send external pipeToRequest : (t, ClientRequest.t, pipeOptions) => () = "pipe"
}

module RequestOptions = {
  type t = {
    port: option<int>,
    method: option<string>,
    headers: option<headers>,
  }

  let make = (~port=?, ~method=?, ~headers=?, ()) => {
    port,
    method,
    headers,
  }
}

module Http = {
  type t
  type addressInfo = {
    address: string,
    family: string,
    port: int
  }

  @module("http")
  external createServer : ((IncomingMessage.t, ServerResponse.t) => ()) => t = "createServer"
  @send
  external listen : (t, int, () => ()) => () = "listen"
  @send
  external address : t => addressInfo = "address"

  @module("http")
  external request : (Web.Url.t, RequestOptions.t, IncomingMessage.t => ()) => ClientRequest.t = "request"
}

module Https = {
  @module("https")
  external request : (Web.Url.t, RequestOptions.t, IncomingMessage.t => ()) => ClientRequest.t = "request"
}

module Buffer = {
  type t

  @send
  external toString : (t, string) => string = "toString"
}
module Connection = {
  type t

  @send
  external onPong : (t, string, (@this t, Node.Buffer.t) => ()) => () = "on"
  let onPong = (ws, cb) => ws->onPong("pong", cb)
  @send
  external oncePong : (t, string, (@this t, Node.Buffer.t) => ()) => () = "once"
  let oncePong = (ws, cb) => ws->oncePong("pong", cb)

  @send
  external onMessage : (t, string, (@this t, Node.Buffer.t) => ()) => () = "on"
  let onMessage = (ws, cb) => ws->onMessage("message", cb)
  @send
  external onceMessage : (t, string, (@this t, Node.Buffer.t) => ()) => () = "once"
  let onceMessage = (ws, cb) => ws->onceMessage("message", cb)

  @send
  external onClose : (t, string, (@this t, int, string) => ()) => () = "on"
  let onClose = (ws, cb) => ws->onClose("close", cb)

  @send
  external ping : (t, string) => () = "ping"
  @send 
  external send : (t, string) => () = "send"

  @send
  external terminate : t => () = "terminate"
}

type t

@module("ws") @new
external make : 'a => t = "WebSocketServer"

@send
external onConnection : (t, string, Connection.t => ()) => () = "on"
let onConnection = (ws, cb) => ws->onConnection("connection", cb)

@get
external clients : t => array<Connection.t> = "clients"

@send
external onClose : (t, string, () => ()) => () = "on"
let onClose = (ws, cb) => ws->onClose("close", cb)

let config = Config.load()

////////////////////////////////////
// Twitch Client setup
////////////////////////////////////
let twitchClient = TwitchClient.make(config.Config.twitch.client_id, config.Config.twitch.client_secret)

////////////////////////////////////
// Webserver Setup
////////////////////////////////////
let server = Node.Http.createServer(HttpServer.makeRouter(config))

////////////////////////////////////
// Websocket Setup
////////////////////////////////////
let wss = WebSocketServer.make({
  "server": server,
  "perMessageDeflate": {
    "zlibDeflateOptions": {
      // See zlib defaults.
      "chunkSize": 1024,
      "memLevel": 7,
      "level": 3
    },
    "zlibInflateOptions": {
      "chunkSize": 10 * 1024
    },
    // Other options settable:
    "clientNoContextTakeover": true, // Defaults to negotiated value.
    "serverNoContextTakeover": true, // Defaults to negotiated value.
    "serverMaxWindowBits": 10, // Defaults to negotiated value.
    // Below options specified as default values.
    "concurrencyLimit": 10, // Limits zlib concurrency for perf.
    "threshold": 1024 // Size (in bytes) below which messages
                      // should not be compressed if context takeover is disabled.
  }
})

////////////////////////////////////
// Server start
////////////////////////////////////
server->Node.Http.listen(
  Env.port,
  () => {
    let { address, family, port } = server->Node.Http.address
    let host = (family === "IPv6" && address === "::") ? "0.0.0.0" : address
    let url = host === "0.0.0.0" || host === "127.0.0.1" ? "localhost" : host
    let secure = port === 443 ? "s" : ""
    Js.Console.log(`started server on ${host}:${string_of_int(port)}, url: http${secure}://${url}${port !== 80 && port !== 443 ? `:${string_of_int(port)}` : ""}`)
  }
)

////////////////////////////////////
// Websocket Heartbeat
////////////////////////////////////
@get
external isAlive : WebSocketServer.Connection.t => bool = "isAlive"
@set
external setAlive : (WebSocketServer.Connection.t, bool) => () = "isAlive"

let heartbeat = (ws, _) => {
  ws->setAlive(true)
}

wss->WebSocketServer.onConnection(ws => {
  ws->setAlive(true)
  ws->WebSocketServer.Connection.onPong(heartbeat)
})

let wsHeartbeatInterval = Js.Global.setInterval(
  () => {
      wss->WebSocketServer.clients->Js.Array2.forEach(ws => {
        switch (ws->isAlive) {
          | false => ws->WebSocketServer.Connection.terminate
          | true => {
            ws->setAlive(true)
            ws->WebSocketServer.Connection.ping("")
          }
        }
      })
  },
  30000
)

wss->WebSocketServer.onClose(() => {
  Js.Global.clearInterval(wsHeartbeatInterval)
})


////////////////////////////////////
// Control server functionality
////////////////////////////////////
let serverState = ref(StateMachine.make())

Js.Global.setInterval(() => {
  open StateMachine
  serverState := (serverState.contents->isStandby ? serverState.contents->toOverlay : serverState.contents->toStandby)

  let updatedState = serverState.contents->StateMachine.stringify
  wss
    ->WebSocketServer.clients
    ->Js.Array2.forEach(
      ws => ws->WebSocketServer.Connection.send(updatedState)
    )
}, 5000)->ignore
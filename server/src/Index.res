let config = Config.load()
let serverState = ServerState.make()

////////////////////////////////////
// Twitch Client setup
////////////////////////////////////
let twitchClient = TwitchClient.make(config.Config.twitch.client_id, config.Config.twitch.client_secret)

////////////////////////////////////
// Webserver Setup
////////////////////////////////////
let server = Node.Http.createServer(HttpServer.makeRouter(config, serverState))

////////////////////////////////////
// Websocket Setup
////////////////////////////////////
let viewerWss = WebSocketServer.make({
  "noServer": true,
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
let controllerWss = WebSocketServer.make({
  "noServer": true,
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
// HTTP Server Upgrade
////////////////////////////////////
server->Node.Http.onUpgrade((request, socket, head) => {
  open Node
  open Web

  let requestUrl = Url.make(
    request->IncomingMessage.url,
    "http://" ++ request->Node.IncomingMessage.headers->Js.Dict.unsafeGet("host")
  )

  // Depending on where the client connects we have different authentication mechanisms.
  // The controller must be authenticated with a cookie that contains the session.
  // The viewer will be verified by a secret URL that is used to load the client data.
  switch (requestUrl->Url.pathname) {
    | "/controller" => {
     switch(request->Node.IncomingMessage.headers->Js.Dict.get("cookie")) {
        | None => {
          socket->Socket.write("HTTP 1.1 401 Unauthorized\r\n\r\n")
          socket->Socket.destroy
        }
        | Some(cookieHeader) => {
          switch (cookieHeader->Cookie.parse->Js.Dict.get("access-token")) {
            | None => {
              socket->Socket.write("HTTP 1.1 401 Unauthorized\r\n\r\n")
              socket->Socket.destroy
            }
            | Some(userId) => {
              let client = serverState->ServerState.getClient(userId)
              switch (client) {
                | None => {
                  socket->Socket.write("HTTP 1.1 401 Unauthorized\r\n\r\n")
                  socket->Socket.destroy
                }
                | Some(client) => {
                  // TODO: Associate the client object with the connection.
                  controllerWss->WebSocketServer.handleUpgrade(request, socket, head, (ws) => {
                    controllerWss->WebSocketServer.emitConnection(ws, request, client)
                  })
                }
              }
            }
          }
        }
      }
    }
    // TODO: Replace hardocded ID with dynamic secret stored in server data.
    | "/viewer/82849734" => {
      let client = serverState->ServerState.getClient("82849734")
      switch (client) {
        | None => {
          socket->Socket.write("HTTP 1.1 401 Unauthorized\r\n\r\n")
          socket->Socket.destroy
        }
        | Some(client) => {
          viewerWss->WebSocketServer.handleUpgrade(request, socket, head, (ws) => {
            viewerWss->WebSocketServer.emitConnection(ws, request, client)
          })

          // TODO: Register viewers in server state.
        }
      }

    }
    | _ => socket->Socket.destroy
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

let heartbeat = @this ((ws, _) => {
  ws->setAlive(true)
})

// Heartbeat for the viewer connection.
viewerWss->WebSocketServer.onConnection(ws => {
  ws->setAlive(true)
  ws->WebSocketServer.Connection.onPong(heartbeat)
})

// Heartbeat for the controller connection.
controllerWss->WebSocketServer.onConnection(ws => {
  ws->setAlive(true)
  ws->WebSocketServer.Connection.onPong(heartbeat)
})

let wsHeartbeatInterval = Js.Global.setInterval(
  () => {
      let ping = ws => {
        switch (ws->isAlive) {
          | false => ws->WebSocketServer.Connection.terminate
          | true => {
            ws->setAlive(true)
            ws->WebSocketServer.Connection.ping("")
          }
        }
      }

      viewerWss->WebSocketServer.clients->Js.Array2.forEach(ping)
      controllerWss->WebSocketServer.clients->Js.Array2.forEach(ping)
  },
  30000
)

// We only need to clear this when the viewer closes because we use
// a single interval for both viewer and controller server.
viewerWss->WebSocketServer.onClose(() => {
  Js.Global.clearInterval(wsHeartbeatInterval)
})

////////////////////////////////////
// Controller server functionality
////////////////////////////////////
let serverState = ref(StreamState.make())

controllerWss->WebSocketServer.onConnection(ws => {
  ws->WebSocketServer.Connection.onMessage(@this ((ws, message) => {
    open StreamState
    let message = message->Node.Buffer.toString("utf-8")

    let updateClient = (state) => {
      let updatedState = state.contents->StreamState.stringify
      viewerWss
        ->WebSocketServer.clients
        ->Js.Array2.forEach(
          ws => ws->WebSocketServer.Connection.send(updatedState)
        )
    }

    switch (message) {
      | "overlay" => {
        serverState := serverState.contents->toOverlay
        updateClient(serverState)
      }
      | "standby" => { 
        serverState := serverState.contents->toStandby
        updateClient(serverState)
      }
      | "brb" => {
        serverState := serverState.contents->toBrb
        updateClient(serverState)
      }
      | _ => ws->WebSocketServer.Connection.terminate
    }
  }))
})

import http from "http";
import { WebSocketServer } from 'ws';
import staticFileHandler from "serve-handler";
import { make as makeStateMachine, isStandby, toStandby, toOverlay } from "./server/StateMachine.mjs"
import config from "./config.mjs";

////////////////////////////////////
// Webserver Setup
////////////////////////////////////
const port = 8080;

const isDevelopment = process.env.NODE_ENV === "development"

let handler = null;
// In development we proxy all requests to webpack.
if (isDevelopment) {
  handler = (request, response) => {
    const proxy = http.request(
      {
        hostname: 'localhost',
        port: process.env.WEBPACK_PORT,
        path: request.url,
        method: request.method,
        headers: request.headers,
      },
      (proxyResponse) => {
        response.writeHead(proxyResponse.statusCode, proxyResponse.headers);
        // Pipe the response from the proxy to the client.
        proxyResponse.pipe(response, { end: true });
      }
    )
    // Forward the actual request.
    request.pipe(proxy, { end: true });
  };
}
// Otherwise we serve static files.
else {
  const serveOptions = {
    "public": "dist",
    "directoryListing": false,
  }
  handler = (request, response) => {
    return staticFileHandler(request, response, serveOptions);
  };
}

const server = http.createServer(handler);

////////////////////////////////////
// Websocket Setup
////////////////////////////////////
const wss = new WebSocketServer({
  server,
  perMessageDeflate: {
    zlibDeflateOptions: {
      // See zlib defaults.
      chunkSize: 1024,
      memLevel: 7,
      level: 3
    },
    zlibInflateOptions: {
      chunkSize: 10 * 1024
    },
    // Other options settable:
    clientNoContextTakeover: true, // Defaults to negotiated value.
    serverNoContextTakeover: true, // Defaults to negotiated value.
    serverMaxWindowBits: 10, // Defaults to negotiated value.
    // Below options specified as default values.
    concurrencyLimit: 10, // Limits zlib concurrency for perf.
    threshold: 1024 // Size (in bytes) below which messages
    // should not be compressed if context takeover is disabled.
  }
});

////////////////////////////////////
// Server start
////////////////////////////////////
server.listen(
  port,
  () => {
    const { address, family, port } = server.address();
    const host = (family === "IPv6" && address === "::") ? "0.0.0.0" : address;
    const url = host === "0.0.0.0" || host === "127.0.0.1" ? "localhost" : host;
    const secure = port === 443 ? "s" : "";
    console.info(`started server on ${host}:${port}, url: http${secure}://${url}${port !== 80 && port !== 443 ? `:${port}` : ""}`)
  }
);

////////////////////////////////////
// Websocket Heartbeat
////////////////////////////////////
// Mark the connection as alive.
function heartbeat() {
  this.isAlive = true;
}

wss.on('connection', function connection(ws) {
  ws.isAlive = true;
  ws.on('pong', heartbeat);
});

const wsHeartbeatInterval = setInterval(function ping() {
  wss.clients.forEach(function each(ws) {
    if (ws.isAlive === false) return ws.terminate();

    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

wss.on('close', function close() {
  clearInterval(wsHeartbeatInterval);
});

////////////////////////////////////
// Control server functionality
////////////////////////////////////

let serverState = makeStateMachine()

wss.on('connection', function connection(ws, req) {
  console.info("New client connected from", req.socket.remoteAddress);
  
  ws.send(JSON.stringify(serverState));

  ws.on('close', (code, reason) => console.info(`Client from ${req.socket.remoteAddress} disconnected (${code}): ${reason}`))
});

setInterval(() => {
  serverState = isStandby(serverState) ? toOverlay(serverState) : toStandby(serverState);

  const updatedState = JSON.stringify(serverState);
  wss.clients.forEach(ws => ws.send(updatedState));
}, 5000)

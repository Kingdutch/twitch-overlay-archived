type t
type event

type eventCallback = event => unit

@new
external make : string => t = "WebSocket"

@send
external addEventListener : (t, string, eventCallback) => unit = "addEventListener"

@send
external close : (t, int, string) => unit = "close"

// Application specific
type messageEvent = { data: string }

type serverMessage = { data: StreamState.t }
external asMessageEvent : event => messageEvent = "%identity"

let onMessage = (ws, callback: StreamState.t => ()) => {
  let callback = (event) => {
    asMessageEvent(event).data->Js.Json.deserializeUnsafe->callback
  }

  ws->addEventListener("message", callback)
}




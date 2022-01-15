let useServerControl = (viewerCode) => {
  let (serverState, updateServerState) = React.useState(() => None)

  React.useEffect2(() => {
    open Window.Location;

    let ws = WebSocket.make((protocol === "https" ? "wss" : "ws") ++ "://" ++ host ++ "/viewer/" ++ viewerCode)

    // Update the server state whenever we receive new.
    ws->WebSocket.onMessage(newState => updateServerState(_ => Some(newState)))

    ws->WebSocket.addEventListener("close", _ => updateServerState(_ => None))

    Some(() => ws->WebSocket.close(-1, "component unmounted"))
  }, (updateServerState, viewerCode))

  serverState
}

@react.component
let make = (~viewerCode) => {
  let serverState = useServerControl(viewerCode);

  switch (serverState) {
    | None => <div>{React.string("Connecting.....")}</div>
    | Some(state) => switch(state.scene) {
      | StreamState.Overlay => <Kingdutch__TwitchOverlay__Scenes__Overlay title={state.streamTitle} />
      | StreamState.Brb => <Kingdutch__TwitchOverlay__Scenes__BeRightBack />
      | StreamState.Standby => <Kingdutch__TwitchOverlay__Scenes__Standby title={state.streamTitle} />
    } 
  }
}

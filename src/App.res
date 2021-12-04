@scope(("window", "location")) @val
external hash: option<string> = "hash"

@scope(("window", "location")) @val
external protocol : string = "protocol"

@scope(("window", "location")) @val
external host: string = "host"

let useServerControl = () => {
  let (serverState, updateServerState) = React.useState(() => None)

  React.useEffect1(() => {
    let ws = WebSocket.make((protocol === "https" ? "wss" : "ws") ++ "://" ++ host)

    // Update the server state whenever we receive new.
    ws->WebSocket.onMessage(newState => updateServerState(_ => Some(newState)))

    ws->WebSocket.addEventListener("close", _ => updateServerState(_ => None))

    Some(() => ws->WebSocket.close(-1, "component unmounted"))
  }, [updateServerState])

  serverState
}

@react.component
let make = () => {
  let serverState = useServerControl();

  switch serverState {
    | None => <div>{React.string("Connecting.....")}</div>
    | Some(state) => switch (state.scene) {
      | StateMachine.Overlay => <Kingdutch__TwitchOverlay__Scenes__Overlay />
      | StateMachine.Brb => <Kingdutch__TwitchOverlay__Scenes__BeRightBack />
      | StateMachine.Standby => <Kingdutch__TwitchOverlay__Scenes__Standby />
    }
  }
}

let useServerControl = () => {
  let (ws, updateWs) =  React.useState(() => None)

  React.useEffect1(() => {
    open Window.Location;

    let ws = WebSocket.make((protocol === "https" ? "wss" : "ws") ++ "://" ++ host ++ "/controller")

    updateWs(_ => Some(ws))
    // Update the server state whenever we receive new.
    ws->WebSocket.onMessage(newState => Js.Console.log(newState))

    ws->WebSocket.addEventListener("close", message => Js.Console.log(message))

    Some(() => {
      ws->WebSocket.close(-1, "component unmounted")
      updateWs(_ => None)
    })
  }, [updateWs])

  let setStandby = React.useCallback1(
    _ => switch (ws) {
      | None => ()
      | Some(ws) => {
        ws->WebSocket.send("standby")
      }
    },
    [ws]
  )
  let setBrb = React.useCallback1(
    _ => switch (ws) {
      | None => ()
      | Some(ws) => {
        ws->WebSocket.send("brb")
      }
    },
    [ws]
  )
  let setOverlay = React.useCallback1(
    _ => switch (ws) {
      | None => ()
      | Some(ws) => {
        ws->WebSocket.send("overlay")
      }
    },
    [ws]
  )

  (setStandby, setBrb, setOverlay)
}

@react.component
let make = () => {
  let (setStandby, setBrb, setOverlay) = useServerControl();
 
  <div>
    <h1>{React.string("Control your stream")}</h1>
    <button onClick=setStandby>{React.string("Standby")}</button>
    <button onClick=setBrb>{React.string("Brb")}</button>
    <button onClick=setOverlay>{React.string("Overlay")}</button>
  </div>
}

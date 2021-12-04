type scene = 
  | Standby 
  | Brb 
  | Overlay

type t = {
  scene: scene,
  streamTitle: string
}

let make = () => {
  scene: Standby,
  streamTitle: ""
}

let setScene = (state, scene) => {...state, scene}

let toStandby = (state) => state->setScene(Standby)
let toBrb = (state) => state->setScene(Brb)
let toOverlay = (state) => state->setScene(Overlay)

let isStandby = (state) => state.scene === Standby
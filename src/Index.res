// Create bindings for functions to create a React root element.
@scope("document") @val
external createElement: string => Dom.element = "createElement"

@scope(("document", "body")) @val
external appendChild: Dom.element => Dom.element = "appendChild"

@send
external setAttribute: (Dom.element, string, string) => unit = "setAttribute"

@scope(("window", "location")) @val
external hash: option<string> = "hash"

// Create a root div that React can use in rendering.
let root = createElement("div")
root->setAttribute("id", "root")

// Append it to the body.
appendChild(root) |> ignore

let app = switch hash {
| Some("#overlay") => <Kingdutch__TwitchOverlay__Scenes__Overlay />
| Some("#brb") => <Kingdutch__TwitchOverlay__Scenes__BeRightBack />
| _ => <Kingdutch__TwitchOverlay__Scenes__Standby />
}

// Render in our newly created element.
ReactDOM.render(app, root)

// Create bindings for functions to create a React root element.
@scope("document") @val
external createElement: string => Dom.element = "createElement"

@scope(("document", "body")) @val
external appendChild: Dom.element => Dom.element = "appendChild"

@send
external setAttribute: (Dom.element, string, string) => unit = "setAttribute"

// Create a root div that React can use in rendering.
let root = createElement("div")
root->setAttribute("id", "root")

// Append it to the body.
appendChild(root) |> ignore

// Render in our newly created element.
ReactDOM.Experimental.createRoot(root)
  ->ReactDOM.Experimental.render(<App />)
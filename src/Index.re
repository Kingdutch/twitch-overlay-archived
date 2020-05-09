// Create bindings for functions to create a React root element.
[@bs.scope "document"] [@bs.val]
external createElement: string => Dom.element = "createElement";

[@bs.scope ("document", "body")] [@bs.val]
external appendChild: Dom.element => Dom.element = "appendChild";

[@bs.send.pipe: Dom.element]
external setAttribute: (string, string) => unit = "setAttribute";

[@bs.scope ("window", "location")] [@bs.val]
external hash: option(string) = "hash";

// Create a root div that React can use in rendering.
let root = createElement("div");
setAttribute("id", "root", root);

// Append it to the body.
appendChild(root);

let app =
  switch (hash) {
  | Some("#overlay") => <Kingdutch__TwitchOverlay__Scenes__Overlay />
  | Some("#brb") => <Kingdutch__TwitchOverlay__Scenes__BeRightBack />
  | _ => <Kingdutch__TwitchOverlay__Scenes__Standby />
  };

// Render in our newly created element.
ReactDOMRe.renderToElementWithId(app, "root");
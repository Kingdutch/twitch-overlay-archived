let isUndefined = Js.Undefined.testAny

let isModifiedEvent = event => {
  open ReactEvent.Mouse
  let target = (event->currentTarget)["target"]
  Js.Console.log2("target", target)
  Js.Console.log2("metaKey", event->metaKey)
  Js.Console.log2("ctrlKey", event->ctrlKey)
  Js.Console.log2("shiftKey", event->shiftKey)
  Js.Console.log2("altKey", event->altKey)
  Js.Console.log2("nativeEvent", event->nativeEvent)

  (target != "" && target != "_self") ||
  event->metaKey ||
  event->ctrlKey ||
  event->shiftKey ||
  event->altKey || // triggers resource download
  (event->nativeEvent->isUndefined && (event->nativeEvent)["which"] == 2)
}

// TODO: This pushes into history when we're already on the page which shouldn't happen.
let linkClicked = (
  e : ReactEvent.Mouse.t,
  href
) => {
  let nodeName = (e->ReactEvent.Mouse.currentTarget)["nodeName"]

  switch (nodeName == "A" && (isModifiedEvent(e) || !Router.isLocalURL(href))) {
    // ignore click for browser’s default behavior
    | true => ()
    | false => {

      e->ReactEvent.Mouse.preventDefault

      RescriptReactRouter.push(href)
    }
  }
}


@react.component
let make = (~href, ~children) => {
  let onClick = e => linkClicked(e, href)

  <a href onClick>{children}</a>
}
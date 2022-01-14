let pathNoQueryHash = path => {
  let queryIndex = path->Js.String2.indexOf("?")
  let hashIndex = path->Js.String2.indexOf("#")
  switch (queryIndex > -1 || hashIndex > -1) {
    | true => path->Js.String2.substring(~from=0, ~to_=queryIndex > -1 ? queryIndex : hashIndex)
    | false => path
  }
}


let hasBasePath = path => {
  path
    ->pathNoQueryHash
    ->Js.String2.startsWith("/")
}

/**
 * Detects whether a given url is routable by the router (browser only).
 */
let isLocalURL = url => {
  // prevent a hydration mismatch on href for url with anchor refs
  switch (url->Js.String2.startsWith("/") || url->Js.String2.startsWith("#") || url->Js.String2.startsWith("?")) {
    | true => true
    | false => {
      try {
        open Web
        // absolute urls can be local if they are on the same origin
        let locationOrigin = Window.Location.getOrigin()
        let resolved = Url.make(url, locationOrigin)
        resolved->Url.origin === locationOrigin && hasBasePath(resolved->Url.pathname)
      }
      catch {
        | _ => false
      }
       
    }
  }
}
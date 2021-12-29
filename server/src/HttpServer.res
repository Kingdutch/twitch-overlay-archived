open Web
open Node

type oauthToken = {
  accessToken: string,
  refreshToken: string,
  expiresIn: int,
  scope: array<string>,
  tokenType: string,
}

type validateToken = {
  clientId: string,
  login: string,
  scopes: array<string>,
  userId: string,
  expiresIn: int,
}

module Decode = {
  open Json.Decode

  let oauthToken = json => {
    accessToken: json |> field("access_token", string),
    refreshToken: json |> field("refresh_token", string),
    expiresIn: json |> field("expires_in", int),
    scope: json |> field("scope", array(string)),
    tokenType: json |> field("token_type", string),
  }
  

  let validateToken = json => {
    clientId: json |> field("client_id", string),
    login: json |> field("login", string),
    scopes: json |> field("scopes", array(string)),
    userId: json |> field("user_id", string),
    expiresIn: json |> field("expires_in", int),
  }
 
}

let makeOAuthHandler = (config) => 
  (request, response) => {
    let requestUrl = Url.make(
      request->IncomingMessage.url,
      "http://" ++ request->IncomingMessage.headers->Js.Dict.unsafeGet("host")
    )

    switch (requestUrl->Url.pathname) {
      | "/login" => {
        let returnRedirectUri = Url.make("/oauth2/complete", requestUrl->Url.toString)

        let requestRedirectUri = Url.make("/oauth2/authorize", "https://id.twitch.tv")
        requestRedirectUri->Url.searchParamsAppend("client_id", config.Config.twitch.client_id)
        requestRedirectUri->Url.searchParamsAppend("redirect_uri", returnRedirectUri->Url.toString)
        requestRedirectUri->Url.searchParamsAppend("response_type", "code")
        requestRedirectUri->Url.searchParamsAppend("scope", config.Config.twitch.scopes|>Js.Array.joinWith(" "))

        response
          ->ServerResponse.writeHead(302, Js.Dict.fromArray([("Location", requestRedirectUri->Url.toString)]))
          ->ServerResponse.end
      }
      | "/oauth2/complete" => {
        switch (requestUrl->Url.searchParamsGet("code")) {
          | None =>  response->ServerResponse.writeHead(400, Js.Dict.empty())->ServerResponse.end
          | Some(code) => {
            let returnRedirectUri = Url.make("/oauth2/complete", requestUrl->Url.toString)
            let codeRequestUri = Url.make("/oauth2/token", "https://id.twitch.tv")
            codeRequestUri->Url.searchParamsAppend("client_id", config.Config.twitch.client_id)
            codeRequestUri->Url.searchParamsAppend("client_secret", config.Config.twitch.client_secret)
            codeRequestUri->Url.searchParamsAppend("code", code)
            codeRequestUri->Url.searchParamsAppend("grant_type", "authorization_code")
            codeRequestUri->Url.searchParamsAppend("redirect_uri", returnRedirectUri->Url.toString)

            Https.request(
              codeRequestUri,
              RequestOptions.make(~method="POST", ()),
              (codeResponse) => {
                let data = [];

                codeResponse->IncomingMessage.onData(chunk => data->Js.Array2.push(chunk)->ignore)
                codeResponse->IncomingMessage.onEnd(() => {
                  let data = data->Js.Array2.joinWith("")
                  switch (data->Json.parse) {
                    | None => {
                      Js.Console.error2("Could not decode access_token.", data)
                      response
                        ->ServerResponse.writeHead(500, Js.Dict.empty())
                        ->ServerResponse.endWith("Error retrieving access token")
                    }
                    | Some(json) => {
                      let authData = json -> Decode.oauthToken
                      Https.request(
                        Url.make("/oauth2/validate", "https://id.twitch.tv"),
                        RequestOptions.make(~headers=Js.Dict.fromArray([
                          ("Authorization", "Bearer " ++ authData.accessToken)
                        ]), ()),
                        (validateResponse) => {
                          let validateData = [];

                          validateResponse->IncomingMessage.onData(chunk => validateData->Js.Array2.push(chunk)->ignore)
                          validateResponse->IncomingMessage.onEnd(() => {
                            let validateData = validateData->Js.Array2.joinWith("")
                            switch(validateData->Json.parse) {
                              | None => {
                                Js.Console.error2("Could not decode validation response.", validateData)
                                response
                                  ->ServerResponse.writeHead(500, Js.Dict.empty())
                                  ->ServerResponse.endWith("Error validatinng access token")
                              }
                              | Some(json) => {
                                let validation = json -> Decode.validateToken
                                Js.Console.log2("User ID", validation.userId)
                                Js.Console.log2("Login", validation.login)

                                response
                                  ->ServerResponse.writeHead(200, Js.Dict.empty())
                                  ->ServerResponse.endWith("Authenticated")
                              }
                            }
                          })
                        }
                      )->ClientRequest.end
                    }
                  }
                })
              }
            )->ClientRequest.end
          }
        }
      }
      | route => Js.Console.error("oAuthHandler was asked to handle '" ++ route ++ "' but doesn't know how to do this.")
    }
  }

@module("serve-handler")
external staticFileHandler : (IncomingMessage.t, ServerResponse.t, 'a) => () = "default"

let makeFileHandler = (config) => {
  let serveOptions = {
    "public": config.Config.public_dir,
    "rewrites": [
      { "source": "/assets/:asset", "destination": "/:asset" }
    ],
    "directoryListing": false,
    "trailingSlash": true,
  }
  (request, response) => {
    staticFileHandler(request, response, serveOptions)
  }
}

let indexHandler = (_request, response) => {
  open Node.FileSystem;

  let fileStream = createReadStream(
    "./server/src/index.html", 
    Js.Dict.fromArray([("encoding", "utf-8")])
  )

  fileStream->ReadStream.onOpen(() => {
    response->ServerResponse.writeHead(
      200, 
      Js.Dict.fromArray([
        ("Content-Type", "text/html; charset=UTF-8"),
      ])
    )->ignore
    fileStream->ReadStream.pipeAsHttpResponse(response, { end: true })
  })

  fileStream->ReadStream.onError(error => {
    Js.Console.error2("Error encountered while trying to read index.html", error)

      response->ServerResponse.writeHead(
        500, 
        Js.Dict.fromArray([
          ("Content-Type", "text/plain; charset=UTF-8"),
        ])
      )
      ->ServerResponse.endWith("Internal Server Error")
  })
}

let makeRouter = (config) => {
  let oAuthHandler = makeOAuthHandler(config)
  let fileHandler = makeFileHandler(config)

  (request, response) => {
    let requestUrl = Url.make(
      request->IncomingMessage.url,
      "http://" ++ request->IncomingMessage.headers->Js.Dict.unsafeGet("host")
    )

    switch (requestUrl->Url.pathname) {
      // Login and oAuth related requests.
      | "/login"
      | "/oauth2/complete" => oAuthHandler(request, response)
      // Static assets like JavaScript bundles or images.
      | maybeAssetPath when maybeAssetPath->Js.String2.startsWith("/assets/") => fileHandler(request, response)
      // All other requests are handled client side.
      | _ => indexHandler(request, response)
    }
  }
}
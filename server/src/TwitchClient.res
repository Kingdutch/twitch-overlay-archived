type unauthenticated
type authenticated

type t<'a> = {
  client_id: string,
  client_secret: string,
  token: string
}

// TODO: Store expires and refresh.

let make = (client_id, client_secret) => {client_id, client_secret, token: ""}

let authenticateClient = (client, token) => {
  client_id: client.client_id, 
  client_secret: client.client_secret, 
  token
}

let getClientId = client => client.client_id
let getClientSecret = client => client.client_secret
let getToken = client => client.token

// let fetchStreamTitle = (client, streamer_login) => {
//   fetch(
//     ~init=Init.t(
//       ~headers=Headers.makeFromObject({
//         "Client-ID": client.client_id,
//         "Authorization": "Bearer " ++ client.token
//       }),
//       (),
//     ),
//     "https://api.twitch.tv/helix/streams?user_login=" ++ streamer_login,
//   )
//   ->Promise.flatMapOk(Response.json)
//   ->Promise.mapOk(json => {
//     open Belt.Option
//     open Js.Json
//     decodeObject(json)
//     ->flatMap(Js.Dict.get(_, "data"))
//     ->flatMap(decodeArray)
//     ->flatMap(Belt.Array.get(_, 0))
//     ->flatMap(decodeObject)
//     ->flatMap(Js.Dict.get(_, "title"))
//     ->flatMap(decodeString)
//   })
//   ->Promise.mapError(fetchErrorToString)
//   ->Promise.map(result => switch (result) {
//     | Ok(maybeString) => switch (maybeString) {
//       | Some(title) => Ok(title)
//       | None => Error("No title set")
//     }
//     | Error(e) => Error(e)
//   })
// }


type t = {
  id: string,
  login: string,
  display_name: string,
  broadcaster_type: string,
  description: string,
  profile_image_url: string,
  offline_image_url: string,
  view_count: int,
  created_at: string,
}

module Decode = {
  open Json.Decode;
  let t = json => {
    id: json |> field("id", string),
    login: json |> field("login", string),
    display_name: json |> field("display_name", string),
    broadcaster_type: json |> field("broadcaster_type", string),
    description: json |> field("description", string),
    profile_image_url: json |> field("profile_image_url", string),
    offline_image_url: json |> field("offline_image_url", string),
    view_count: json |> field("view_count", int),
    created_at: json |> field("created_at", string),
  }
}

// let fetch = (client: TwitchClient.t<TwitchClient.authenticated>) => {
//   open Kingdutch.Fetch;
//   fetch(
//     ~init=Init.t(
//       ~headers=Headers.makeFromObject({
//         "Client-ID": client->TwitchClient.getClientId,
//         "Authorization": "Bearer " ++ client->TwitchClient.getToken,
//       }),
//       (),
//     ),
//     "https://api.twitch.tv/helix/users",
//   )
//   ->Promise.flatMapOk(Response.json)
//   ->Promise.mapOk(Decode.t)
//   ->Promise.mapError(fetchErrorToString)
//   ->Promise.map(result => switch (result) {
//     | Ok(user) => Ok(user)
//     | Error(e) => Error(e)
//   })
// }

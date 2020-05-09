open Kingdutch.Fetch;

type twitchConfigType = {
  streamer_login: string,
  client_id: string,
};
type configType = {twitch: twitchConfigType};

[@bs.module "../../config"] [@bs.val] external config: configType = "default";

let useStreamTitle = () => {
  let (title, setTitle) = React.useState(() => React.null);

  React.useEffect1(
    () => {
      let updateStreamTitle = () =>
        fetch(
          ~init=
            Init.t(
              ~headers=
                Headers.makeFromObject({
                  "Client-ID": config.twitch.client_id,
                }),
              (),
            ),
          "https://api.twitch.tv/helix/streams?user_login="
          ++ config.twitch.streamer_login,
        )
        ->Promise.flatMapOk(Response.json)
        ->Promise.mapOk(json =>
            Belt.Option.(
              Js.Json.(
                decodeObject(json)
                ->flatMap(Js.Dict.get(_, "data"))
                ->flatMap(decodeArray)
                ->flatMap(Belt.Array.get(_, 0))
                ->flatMap(decodeObject)
                ->flatMap(Js.Dict.get(_, "title"))
                ->flatMap(decodeString)
                ->getWithDefault("Offline")
              )
            )
          )
        ->Promise.mapOk(title => setTitle(_ => React.string(title)))
        ->Promise.mapError(fetchErrorToString)
        ->Promise.getError(title => setTitle(_ => React.string(title)));

      // Initially set the stream title.
      updateStreamTitle();

      // Update the stram title every 60 seconds.
      let interval = Js.Global.setInterval(updateStreamTitle, 60000);
      Some(() => Js.Global.clearInterval(interval));
    },
    [|setTitle|],
  );

  title;
};
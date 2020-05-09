open Kingdutch;

type twitchConfigType = {
  streamer_login: string,
  client_id: string,
};
type configType = {twitch: twitchConfigType};

[@bs.module "../../config"] [@bs.val] external config: configType = "default";

[@react.component]
let make = () => {
  let (title, setTitle) = React.useState(() => React.null);

  React.useEffect1(
    () => {
      let updateStreamTitle = () =>
        Fetch.(
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
          ->Promise.getError(title => setTitle(_ => React.string(title)))
        );

      // Initially set the stream title.
      updateStreamTitle();

      // Update the stram title every 60 seconds.
      let interval = Js.Global.setInterval(updateStreamTitle, 60000);
      Some(() => Js.Global.clearInterval(interval));
    },
    [|setTitle|],
  );

  <Kingdutch__TwitchOverlay__Components__Container>
    <Kingdutch__TwitchOverlay__Components__Header>
      <Kingdutch__TwitchOverlay__Components__StreamerName>
        {ReasonReact.string("Kingdutch")}
      </Kingdutch__TwitchOverlay__Components__StreamerName>
      <h2> title </h2>
    </Kingdutch__TwitchOverlay__Components__Header>
    <Kingdutch__TwitchOverlay__Components__MiddleFrame>
      <Kingdutch__TwitchOverlay__Components__StreamInfo>
        <table>
          <tbody>
            <tr>
              <td> <Kingdutch__TwitchOverlay__Icons__Twitter /> </td>
              <td> {ReasonReact.string("@Kingdutch")} </td>
            </tr>
            <tr>
              <td> <Kingdutch__TwitchOverlay__Icons__GitHub /> </td>
              <td> {ReasonReact.string("github.com/Kingdutch/")} </td>
            </tr>
          </tbody>
        </table>
      </Kingdutch__TwitchOverlay__Components__StreamInfo>
    </Kingdutch__TwitchOverlay__Components__MiddleFrame>
    <Kingdutch__TwitchOverlay__Components__Footer />
  </Kingdutch__TwitchOverlay__Components__Container>;
};
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
        Js.Promise.(
          Fetch.fetchWithInit(
            "https://api.twitch.tv/helix/streams?user_login="
            ++ config.twitch.streamer_login,
            Fetch.RequestInit.make(
              ~headers=
                Fetch.HeadersInit.make({
                  "Client-ID": config.twitch.client_id,
                }),
              (),
            ),
          )
          |> then_(Fetch.Response.json)
          |> then_(json => Js.Json.decodeObject(json) |> resolve)
          |> then_(opt => Belt.Option.getExn(opt) |> resolve)
          |> then_(stream =>
               stream.data.length ? "Offline" : stream.data[0].title
             )
          |> then_(setTitle)
        );
      None;
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
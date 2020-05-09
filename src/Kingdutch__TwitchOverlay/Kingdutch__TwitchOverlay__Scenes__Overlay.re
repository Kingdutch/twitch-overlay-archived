open Kingdutch;

[@react.component]
let make = () => {
  let title = Kingdutch__TwitchOverlay__Hooks.useStreamTitle();

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
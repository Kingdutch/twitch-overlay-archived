@react.component
let make = (~title) => {
  <Kingdutch__TwitchOverlay__Components__Container>
    <Kingdutch__TwitchOverlay__Components__Header>
      <Kingdutch__TwitchOverlay__Components__StreamerName>
        {React.string("Kingdutch")}
      </Kingdutch__TwitchOverlay__Components__StreamerName>
      <h2> {React.string(title)} </h2>
    </Kingdutch__TwitchOverlay__Components__Header>
    <Kingdutch__TwitchOverlay__Components__MiddleFrame>
      <Kingdutch__TwitchOverlay__Components__StreamInfo>
        <table>
          <tbody>
            <tr>
              <td> <Kingdutch__TwitchOverlay__Icons__Twitter /> </td>
              <td> {React.string("@Kingdutch")} </td>
            </tr>
            <tr>
              <td> <Kingdutch__TwitchOverlay__Icons__GitHub /> </td>
              <td> {React.string("github.com/Kingdutch/")} </td>
            </tr>
          </tbody>
        </table>
      </Kingdutch__TwitchOverlay__Components__StreamInfo>
    </Kingdutch__TwitchOverlay__Components__MiddleFrame>
    <Kingdutch__TwitchOverlay__Components__Footer />
  </Kingdutch__TwitchOverlay__Components__Container>
}

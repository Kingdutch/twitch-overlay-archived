@react.component
let make = (~title) => {
  <Kingdutch__TwitchOverlay__Components__RippleScreen>
    <div className="font-serif text-6xl pb-4"> {React.string("Kingdutch")} </div>
    <div className="text-5xl"> {React.string("Coming soon: " ++ title)} </div>
  </Kingdutch__TwitchOverlay__Components__RippleScreen>
}

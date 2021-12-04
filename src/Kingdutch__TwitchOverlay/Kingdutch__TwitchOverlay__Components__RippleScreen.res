@react.component
let make = (~children) =>
  <div
    className="w-full h-full flex flex-column items-center justify-center text-center text-primary background-overlay">
    <Kingdutch__TwitchOverlay__Effects__Ripples /> children
  </div>

@react.component
let make = () => {
  <div>
    {React.string("Welcome to Kingdutch's stream overlay.")}
    <br/>
    <Link href="/control/">{React.string("Control Panel")}</Link>
    <br/>
    <Link href="/viewer/82849734">{React.string("Viewer")}</Link>
  </div>
}
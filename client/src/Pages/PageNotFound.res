@react.component
let make = () => {
  <div>
    {React.string("The page you are looking for could not be found.")}
    <br/>
    <Link href="/">{React.string("Go home")}</Link>
  </div>
}
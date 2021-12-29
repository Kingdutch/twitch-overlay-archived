@react.component
let make = (~children) =>
  <div
    className="h-27 flex items-center justify-between px-6 text-4xl text-primary background-overlay shadow">
    children
  </div>

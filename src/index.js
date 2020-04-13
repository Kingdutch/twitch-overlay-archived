import React from "react";
import ReactDOM from "react-dom";
import Overlay from './Overlay';
import Standby from "./Standby";

// Render a different element depending on what's requested.
switch (window.location.hash.substr(1)) {
  case "overlay":
    ReactDOM.render(<Overlay />, document.getElementById("root"));
    break;
  default:
    ReactDOM.render(<Standby />, document.getElementById("root"));
}

import React from "react";
import styled from 'styled-components';
import {hot} from "react-hot-loader";

import RippleScreen from "./Components/RippleScreen";

const StreamerName = styled.h1`
  font-family: 'Paytone One', sans-serif;
  font-size: 4em;
  padding-bottom: 1em;
`;

const Announcement = styled.h2`
  font-size: 3em;
`;

function Standby() {
  return (
    <RippleScreen>
      <StreamerName>Kingdutch</StreamerName>
      <Announcement>Be Right Back</Announcement>
    </RippleScreen>
  )
}

export default hot(module)(Standby);

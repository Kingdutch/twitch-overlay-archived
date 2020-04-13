import React, {useEffect, useState} from "react";
import styled from 'styled-components';
import {hot} from "react-hot-loader";

import config from '../config.js';
import Ripples from "./Effects/Ripples";

const FONT_COLOR = 'whitesmoke';
const OVERLAY_COLOR = 'royalblue';
const BACKGROUND_COLOR = 'black';

const Container = styled.div`
  width: 100%;
  height: 100%;
  font-family: 'Roboto', sans-serif;
  
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  
  color: ${FONT_COLOR};
  background: ${OVERLAY_COLOR};
`;


const StreamerName = styled.h1`
  font-family: 'Paytone One', sans-serif;
  font-size: 4em;
  padding-bottom: 1em;
`;

const Announcement = styled.h2`
  font-size: 3em;
`;

function Standby() {
  const [title, setTitle] = useState(null);

  useEffect(() => {
    const updateStreamTitle = () => fetch(
      'https://api.twitch.tv/helix/streams?user_login=' + config.twitch.streamer_login,
      { headers: { 'Client-ID': config.twitch.client_id }}
    )
      .then(response => {
        if (response.status === 429) {
          throw new Error("Rate limit exceeded")
        }
        return response.json()
      })
      .then(stream => !stream.data.length  ? "Offline" : stream.data[0].title)
      .catch(error => `[${error.message}]`)
      .then(setTitle);

    // Initially set the stream title.
    updateStreamTitle();

    // Update the stream title every 60 seconds.
    const interval = setInterval(updateStreamTitle, 60000);
    return () => clearInterval(interval);
  }, [setTitle]);

  return(
    <Container>
      <Ripples />
      <StreamerName>Kingdutch</StreamerName>
      <Announcement>Coming soon: {title}</Announcement>
    </Container>
  );
}

export default hot(module)(Standby);

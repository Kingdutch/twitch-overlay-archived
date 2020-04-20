import React, {useEffect, useState} from "react";
import styled from 'styled-components';
import {hot} from "react-hot-loader";

import RippleScreen from "./Components/RippleScreen";

import config from '../config.js';

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

  return (
    <RippleScreen>
      <StreamerName>Kingdutch</StreamerName>
      <Announcement>Coming soon: {title}</Announcement>
    </RippleScreen>
  )
}

export default hot(module)(Standby);

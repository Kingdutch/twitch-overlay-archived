import React, {useEffect, useState} from "react";
import styled from 'styled-components';
import {hot} from "react-hot-loader";
import TwitterIcon from "./Icons/Twitter";
import GitHubIcon from "./Icons/GitHub";

import config from '../config.js';

const FONT_COLOR = 'whitesmoke';
const OVERLAY_COLOR = 'royalblue';
const BACKGROUND_COLOR = 'black';

const HEIGHT_HEADER = '110px';
const HEIGHT_FOOTER = '25px';

const Container = styled.div`
  width: 100%;
  height: 100%;
  font-family: 'Roboto', sans-serif;
`;

const Header = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.5em;
  font-size: 2em;
  height: ${HEIGHT_HEADER};
  
  color: ${FONT_COLOR};
  background: ${OVERLAY_COLOR};
  box-shadow: ${BACKGROUND_COLOR} 1px 5px 5px;
`;

const MiddleFrame = styled.div`
  height: calc(100% - ${HEIGHT_HEADER} - ${HEIGHT_FOOTER});
  background: linear-gradient(to right, 
      ${OVERLAY_COLOR} 0 25px, 
      ${BACKGROUND_COLOR} 0 25px,
      transparent 40px 720px, 
      ${BACKGROUND_COLOR} 725px 725px,
      ${OVERLAY_COLOR} 0 750px,
      ${BACKGROUND_COLOR} 0 750px,
      transparent 765px calc(100vw - 30px), 
      ${BACKGROUND_COLOR} calc(100vw - 25px) calc(100vw - 25px),
      ${OVERLAY_COLOR} calc(100vw - 25px)
    );
`;

const StreamInfo = styled.div`
  position: absolute;
  top: 540px;
  width: 750px;
  display: flex;
  justify-content: center;
  border: 25px solid ${OVERLAY_COLOR};
  padding: 1rem 0;
  
  font-size: 3em;
  
  color: ${FONT_COLOR};
  background: ${BACKGROUND_COLOR};
`;

const Footer = styled.div`
  position: absolute;
  bottom: 0;
  width: 100%;
  height: ${HEIGHT_FOOTER};
  color: ${FONT_COLOR};
  background: ${OVERLAY_COLOR};
`;

const StreamerName = styled.h1`
  font-family: 'Paytone One', sans-serif;
  font-size: 2em;
  padding-bottom: .25em;
`;

function Overlay() {
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
      <Header>
        <StreamerName>Kingdutch</StreamerName>
        <h2>{title}</h2>
      </Header>
      <MiddleFrame>
        <StreamInfo>
          <table>
            <tbody>
            <tr>
              <td><TwitterIcon/></td>
              <td>@Kingdutch</td>
            </tr>
            <tr>
              <td><GitHubIcon/></td>
              <td>github.com/Kingdutch/</td>
            </tr>
            </tbody>
          </table>

        </StreamInfo>
      </MiddleFrame>
      <Footer>

      </Footer>
    </Container>
  );
}

export default hot(module)(Overlay);

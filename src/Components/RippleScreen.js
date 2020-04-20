import React from "react";
import styled from 'styled-components';

import Ripples from "../Effects/Ripples";

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


function RippleScreen({ children }) {
  return(
    <Container>
      <Ripples />
      {children}
    </Container>
  );
}

export default RippleScreen;
